module protocol.messages.params.text_doc_did_open;
import protocol.messages.notification;
import common.hipjson;
import std.typecons;
import protocol.base.types;

struct TextDocumentItem {
    string uri;
    string languageId;
    int version_;
    string text;
}

struct DidOpenTextDocumentParams {
    TextDocumentItem textDocument;
}

struct DidOpenTextDocumentNotification {
    mixin Notification;
    DidOpenTextDocumentParams params;

    this(string method, string content) {
        this.method = method;
        JSONValue json = parseJSON(content);
        this.params.textDocument.uri        = json["params"]["textDocument"]["uri"].str;
        this.params.textDocument.languageId = json["params"]["textDocument"]["languageId"].str;
        this.params.textDocument.version_   = json["params"]["textDocument"]["version"].integer;
        this.params.textDocument.text       = json["params"]["textDocument"]["text"].str;
    }
}