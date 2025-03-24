module types.capabilities.server_capabilities;
import types.capabilities.text_doc_sync_options;
import std.typecons;
import std.variant;
import std.json;

class ServerCapabilities {
    string positionEncoding = "utf-16";
    Nullable!TextDocumentSyncOptions textDocumentSync;
}