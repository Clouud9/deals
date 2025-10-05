module analysis.state;
import protocol.base.error_codes;
import std.algorithm.mutation;
import hipjson;
import protocol.base;
import std.file;
import std.path;
import std.string;
import std.algorithm;
import std.logger;
import util;
import dmd.frontend;
import std.string;
import std.stdio;
import core.thread;
import std.algorithm;
import std.array;
import dub.dub;
import dub.dependency;
import dub.generators.build;
import dub.recipe.packagerecipe;
import dub.packagemanager;
import dub.project;
import dub.internal.vibecompat.inet.path;
import std.algorithm.iteration;
import std.range;
import dmd.astbase;
import analysis.hover;
import dmd.root.string : toCString;
import dmd.dmodule;
import dmd.dsymbol;
import dmd.location;
import dmd.dsymbolsem;
import dmd.identifier;
import analysis.project_manager;
import dmd.errors;
import dmd.console;
import core.stdc.stdarg;
import dmd.globals;
import dmd.compiler;

enum SessionType {
    Single,
    Project,
    Workspaces
}

struct State {
    // Map of filenames to contents
    string[string] documents;
    ProjectManager manager;

    this(JSONValue json) {
        // TODO: Handle different project types
        manager = new DubManager(json["params"]["rootPath"].str());
    }

    public void resetDMD() {
        deinitializeDMD();
        initDMD(fatalErrorHandler: cast(FatalErrorHandler) fatal_error_sink); 
        global.params.v.errorLimit = 0;
        foreach(path; chain(manager.import_paths, manager.source_paths, manager.stdlib_paths))
            addImport(path);
    }
}

void openDocument(ref State state, string uri, string text) {
    // TODO: Add indexing implementation
    state.documents[uri] = text;
}

void closeDocument(ref State state, string uri) {
    // TODO: Closed documents should be removed from the active index
    state.documents.remove(uri);
}

void updateDocument(ref State state, string uri, string text) {
    // TODO: Re-update the entry within every index that this file belongs to
    state.documents[uri] = text;
}

void analyze(ref State state) {

}

string serveHover(ref State state, string uri, Position position) {
    state.resetDMD();
    logf("Hover at Position: Line %d, Char %d", position.line, position.character);

    auto result = findIdentifierAt(state, position, uri);
    logf("RESULT NULL?: %s", result is null);

    if (result is null) // No identifier found at location, so no reason to continue
        return "";

    // TODO: Only add if not already added as a module. Otherwise will produce error.
    auto modTuple = parseModule(uri.normalizeUri(), state.documents[uri]);
    Module mod = modTuple.module_;
    // mod.clearCache();

    fullSemantic(mod);
    Position hoverPos = { line: result.loc.linnum, character: result.loc.charnum };
    auto vis = new HoverVisitor(hoverPos, uri.normalizeUri.toCString().ptr);
    mod.accept(vis);

    if (vis.sym)
        logf("Symbol %s found", vis.sym.ident.toString());
    else logf("Symbol %s not found", result.ident.toString());

    return "";
}

// TODO: Check if this works for Windows, Linux, etc.
string normalizeUri(string uri) {
    return uri.stripLeft("file:///").asNormalizedPath().array;
}

// Lambda to push on with errors
bool delegate() fatal_error_sink = () nothrow => true;
DiagnosticHandler diagnostic_sink = (const ref SourceLoc location, Color headerColor,
  const(char)* header, const(char)* messageFormat,
  va_list args, const(char)* prefix1, const(char)* prefix2) nothrow => false;