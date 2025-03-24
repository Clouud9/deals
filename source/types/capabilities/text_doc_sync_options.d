module types.capabilities.text_doc_sync_options;
import std.typecons;
import std.variant;
import std.json;

class TextDocumentSyncOptions {
    Nullable!bool openClose;
    Nullable!int textDocumentSyncKind; // Enum null, full, incremental
}