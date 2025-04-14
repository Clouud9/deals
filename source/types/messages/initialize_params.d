module types.messages.initialize_params;
import types.messages.wdp_params;
import types.messages.lsp_params;
import types.capabilities.client_capabilities;
import std.variant;
import std.typecons;
import std.json;

class InitializeParams : WorkDoneProgessParams, LSPParams {
    Nullable!long processId;
    Nullable!ClientInfo clientInfo;
    Nullable!string locale;
    Nullable!string rootPath;
    Nullable!string rootURI;
    Nullable!JSONValue initializationOptions;
    ClientCapabilities capabilities;
    Nullable!TraceValue trace;
    Nullable!(JSONValue) workspaceFolders;

    this(JSONValue params) {
        // TODO: Validate and then assign? 
        if (params["processId"].isNull == false)
            processId = params["processId"].integer;
        clientInfo = new ClientInfo(params["clientInfo"]);
        
        locale   = ("locale" in params)   ? params["locale"].str   : null;
        rootPath = ("rootPath" in params) ? params["rootPath"].str : null;
        rootURI  = ("rootUri" in params)  ? params["rootUri"].str  : null;

        initializationOptions = ("initializationOptions" in params) ? params["initializationOptions"] : JSONValue.init; 
        capabilities = new ClientCapabilities(params["capabilities"]);
        
        if ("trace" in params) {
            switch (params["trace"].str) {
                case "off":      trace = TraceValue.off; break;
                case "messages": trace = TraceValue.messages; break;
                case "verbose":  trace = TraceValue.verbose; break;
                default: assert(false, "Trace Value found, but improper");
            }
        }

        // TODO: Handle Workspace Folders
    }

    override void validate() {

    }
}

class ClientInfo {
    string name;
    Nullable!string version_str;

    this(JSONValue clientInfo) { 
        name = clientInfo["name"].str;
        
        if ("version" in clientInfo)
            version_str = clientInfo["version"].str;
    }
}


enum TraceValue : string {off = "off", messages = "messages", verbose = "verbose"}

class WorkspaceFolder {
    string uri;
    string name;
}