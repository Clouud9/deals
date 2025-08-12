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
import std.algorithm;
import std.array;
import dub.dub;
import dub.dependency;
import dub.package_;
import dub.generators.build;
import dub.recipe.packagerecipe;
import dub.packagemanager;
import dub.project;
import dub.internal.vibecompat.inet.path;
import std.algorithm.iteration;
import std.range;

enum SessionType {
    Single,
    Project,
    Workspaces
}

struct State {
    // Map of filenames to contents
    string[string] documents;
    string project_root;
    bool is_dub_project;
    string[] import_paths;
    string[] source_paths;
}

// Return Error? 
void openDocument(ref State state, string uri, string text) {
    state.documents[uri] = text;
}

void closeDocument(ref State state, string uri) {
    state.documents.remove(uri);
}

void updateDocument(ref State state, string uri, string text) {
    state.documents[uri] = text;
}

// Text may or may not be there, should check what NeoVim does.
void documentWasSaved(ref State state, string uri, string text) {
    // Perform analysis on save. Start with single files.
}

void analyze(ref State state) {

}

void initializeState(ref State state, JSONValue json) {
    initDMD();
    auto phobos_paths = findImportPaths();
    foreach(path; phobos_paths)
        addImport(path);

    // TODO: Base Path should be determined by where the dub file is, later
    state.project_root = json["params"]["rootPath"].str();
    string dub_root = findProjectRoot(state.project_root);

    if (dub_root != null) {
        stderr.writeln("DUB ROOT: " ~ dub_root);
        state.project_root = dub_root;
        state.is_dub_project = true;
        state.configureDubProject();
        foreach(path; chain(state.import_paths, state.source_paths))
            addImport(path);
    } else {
        stderr.writeln("No dub project found");
    }
}

/** 
 * Adds the source paths and import paths to the state,
 *  so that these can be later added to the dmd path
 */
void configureDubProject(ref State state) {
    auto pkg = new Dub(state.project_root);
    pkg.loadPackage();
    Project project = pkg.project();
    Package rootPackage = project.rootPackage();
    const PackageRecipe recipe = rootPackage.rawRecipe();
    auto dependencyList = recipe.dependencies;
    PackageManager pm = pkg.packageManager();

    foreach (string depName, Dependency dep; dependencyList) {
        dep.visit!(
            (VersionRange vr) { 
                Package pk = pm.getBestPackage(PackageName(depName), vr); 
                NativePath path = pk.path();
                /* 
                 * TODO: Add null check later, and may want to consider using NativePath data structure anyways, 
                 *  to differentiate between local and absolute paths
                 */
                state.import_paths ~= path.toNativeString();
            },
            (NativePath np) { state.import_paths ~= np.toNativeString(); },
            // I do not expect a repository URL to work right now, I will handle it later
            (Repository rp) { state.import_paths ~= rp.remote(); assert(0, "Repository Support will come later"); } 
        );
    }

    /** 
     * The `string` key seems to represent what type of configuration is desired. 
     *  Will deal with that later.
     */
    const string[][string] sourcePaths = recipe.sourcePaths;
    foreach(const string[] paths; sourcePaths) {
        foreach (string path; paths) {
            state.source_paths ~= (state.project_root ~ "\\" ~ path);
		}
    }
}

string hoverRequest(ref State state, string uri, Position position) {
    return "";
}

string serveHover(ref State state, string uri, Position position) {
    auto mod = parseModule(uri, state.documents[uri]);
    fullSemantic(mod.module_);
    /*
    auto id = Identifier.idPool(uri);
    auto m = new ASTBase.Module(&(uri.dup)[0], id, false, false);
    auto input = state.documents[uri] ~ "\0";

    scope p = new Parser!ASTBase(m, input, false, new ErrorSinkStderr(), null, false);
    p.nextToken();
    m.members = p.parseModule();

    scope vis = new ImportVisitor2!ASTBase();
    m.accept(vis);
    */

    return "";
}

import dmd.visitor;
import dmd.visitor.permissive;
import dmd.visitor.parsetime;
import dmd.visitor.transitive;

extern (C++) class ImportVisitor(AST) : PermissiveVisitor!AST {
    alias visit = PermissiveVisitor!AST.visit;

    override void visit(AST.Module m) {
        foreach (s; *m.members) {
            s.accept(this);
        }
    }

    override void visit(AST.Import i) {
        import std.stdio;

        stderr.writefln("import %s", i.toString());
    }

    override void visit(AST.ImportStatement s) {
        foreach (imp; *s.imports) {
            imp.accept(this);
        }
    }
}

extern (C++) class ImportVisitor2(AST) : ParseTimeTransitiveVisitor!AST {
    import std.stdio;

    alias visit = ParseTimeTransitiveVisitor!AST.visit;

    override void visit(AST.Import imp) {
        if (imp.isstatic)
            stderr.writef("static ");

        stderr.writef("import ");

        foreach (const pid; imp.packages)
            stderr.writef("%s.", pid.toString());

        stderr.writef("%s", imp.id.toString());

        if (imp.names.length) {
            stderr.writef(" : ");
            foreach (const i, const name; imp.names) {
                if (i)
                    stderr.writef(", ");
                stderr.writef("%s", name.toString());
            }
        }

        stderr.writef(";");
        stderr.writef("\n");
    }
}
