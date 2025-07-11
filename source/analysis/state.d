module analysis.state;
import protocol.base.error_codes;
import std.algorithm.mutation;
import hipjson;
import protocol.base;
import std.file;
import std.path;
import std.string;
import std.algorithm;

enum SessionType {
    Single,
    Project,
    Workspaces
}

struct State {
    // Map of filenames to contents
    string[string] documents;
    string base_path;
}

// Return Error? 
void openDocument(ref State state, string uri, string text) {
    import std.stdio;
    stderr.writeln("TESTING");
    stderr.writeln(text);
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
   
}

string serveHover(ref State state, string uri, Position position) {
    import dmd.lexer;
    import dmd.compiler;
    import dmd.errorsink;
    import std.conv : to;
    import dmd.globals;
    import dmd.tokens;

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
    while (token.value != TOK.endOfFile) {
        lexer.scan(&token);

        if (token.loc.linnum == position.line &&
            token.loc.charnum <= position.character &&
            token.loc.charnum + token.toString().length > position.character
        ) {
            return token.toString().to!string;
        }
    }

    return "";
}
