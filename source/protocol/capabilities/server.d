module protocol.capabilities.server;
import protocol.base;
import std.typecons;
import std.sumtype;

// TODO: Finish
struct ServerCapabilities {
    PositionEncodingKind positionEncoding;
    Nullable!(SumType!(TextDocSyncOptions, TextDocSyncKind, EmptyObject)) textDocumentSync;

    struct TextDocSyncOptions {
        Nullable!bool openClose;
        Nullable!TextDocSyncKind change;
    }

    struct EmptyObject {}
}
