module protocol.messages.params.init;
import protocol.base;
import std.typecons;
import hipjson;

struct InitParams {
    Nullable!int procId;
    JSONValue clientInfo;
    Nullable!string locale;
    Nullable!string rootURI; // Useable as rootPath too
    JSONValue initOptions = JSONValue.init;
    JSONValue clientCapabilities;
    Nullable!TraceValue trace;
    Nullable!(WorkspaceFolder[]) workspaceFolders;
}
