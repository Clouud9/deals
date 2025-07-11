module protocol.messages.params.text_doc_did_change;
import protocol.messages.notification;
import protocol.base.types;
import std.sumtype;
import hipjson;

struct DidChangeTextDocumentParams {
    VersionedTextDocumentIdentifier textDocument;
    TextDocumentContentChangeEvent[] contentChanges;
}

struct DidChangeTextDocumentNotification {
    mixin Notification;
    DidChangeTextDocumentParams params;

    this(string method, string content) {
        this.method = method;
        JSONValue json = parseJSON(content);
        params.textDocument.uri      = json["params"]["textDocument"]["uri"].str;
        params.textDocument.version_ = json["params"]["textDocument"]["version"].integer;
        
        // For now we only need a RangeSingle, but I will need to know the server capabilities to dynamically adjust later
        JSONValue changes = json["params"]["contentChanges"];
        foreach (JSONValue val; changes.array) {
            auto event = new ChangeEventSingle;
            event.text = val["text"].str;
            params.contentChanges ~= event;
        }
    }
}

class TextDocumentContentChangeEvent {
    string text;
}

class ChangeEventMulti : TextDocumentContentChangeEvent {
    Range range;
    Optional!ulong rangeLength;
}

class ChangeEventSingle : TextDocumentContentChangeEvent {}
// TODO: Need TextDocumentChangeRegistrationOptions and associated types


// TODO: Put all textDocument params and methods into one file

struct DidCloseTextDocumentNotification {
    mixin Notification;
    DidCloseTextDocumentParams params;
    
    this(string method, string contents) {
        this.method = method;
        JSONValue json = parseJSON(contents);
        params.textDocument = json["params"]["textDocument"].str;
    }
}

struct DidCloseTextDocumentParams {
    import protocol.messages.params.text_doc_did_open;
    string textDocument;
}