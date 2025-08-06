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
    // TODO: Base Path should be determined by where the dub file is, later
    state.project_root = json["params"]["rootPath"].str();
    string dub_root = findProjectRoot(state.project_root);

    if (dub_root != null) {
        log("DUB ROOT: " ~ dub_root);
        state.project_root = dub_root;
        state.configureDubProject();
    } else {
        log("No dub project found");
    }
}

void configureDubProject(ref State state) {
    import dub.dub;
    import dub.dependency;
    import dub.package_;
    import dub.generators.build;
    import dub.recipe.packagerecipe;

    auto pkg = new Dub(state.project_root);
    pkg.loadPackage();

    auto project = pkg.project;
    const Package[] packages = project.dependencies();
}

string hoverRequest(ref State state, string uri, Position position) {
    return "";
}

string serveHover(ref State state, string uri, Position position) {
    import dmd.lexer;
    import dmd.compiler;
    import dmd.errorsink;
    import std.conv : to;
    import dmd.globals;
    import dmd.tokens;
    import dmd.identifier;

    global._init();

    // Will have to deal with working around errors later. 
    Lexer lexer = new Lexer(
        uri.to!(char[]).ptr, // const(char)* filename
        state.documents[uri].toStringz, // const(char)* base  
        0, // ulong begoffset
        state.documents[uri].length, // ulong endoffset
        true, // bool doDocComment
        true, // bool commentToken
        true, // bool whitespaceToken
        new ErrorSinkNull(), // ErrorSink errorSink
        &global.compileEnv // const(CompileEnv*) compileEnv  
    );

    Token token;
    string new_str;
    while (token.value != TOK.endOfFile) {
        lexer.scan(&token);

        // Get actual token text
        string tokenText;
        if (token.value == TOK.identifier && token.ident) {
            tokenText = token.ident.toString().to!string;
        } else {
            continue;
        }

        new_str ~= tokenText ~ "\n";

        if (token.loc.linnum == (position.line + 1)) {
            uint tokenStart = token.loc.charnum;
            uint tokenEnd = tokenStart + cast(uint) tokenText.length;
            uint cursorPos = cast(uint)(position.character + 1); // Adjust for 0/1-based indexing

            // Check if cursor is WITHIN the token bounds
            if (cursorPos >= tokenStart && cursorPos <= tokenEnd) {
                return tokenText;
            }
        }
    }

    return "";
}
