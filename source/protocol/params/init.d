module protocol.params.init;
import protocol.base.trace;
import protocol.base.workspace_folder;
import std.typecons;
import std.json;

struct InitParams {
    Nullable!int procId;
    JSONValue clientInfo = JSONValue.emptyObject;
    Nullable!string locale;
    Nullable!string rootURI; // Useable as rootPath too
    JSONValue initOptions = JSONValue.init;
    JSONValue clientCapabilities;
    Nullable!TraceValue trace;
    Nullable!(WorkspaceFolder[]) workspaceFolders;
}
