module analysis.state;
import protocol.base.error_codes;
import std.algorithm.mutation;

struct State {
    // Map of filenames to contents
    string[string] documents;
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