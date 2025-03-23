module types.messages.initialize_params;
import types.messages.wdp_params;
import types.messages.lsp_params;
import std.variant;
import std.typecons;

class InitializeParams : WorkDoneProgessParams, LSPParams {
    Nullable!int processId;
    Nullable!ClientInfo clientInfo;
    Nullable!string locale;
    Nullable!string rootPath;
    Nullable!string rootUri;
    

    override void validate() {

    }
}

class ClientInfo {
    string name;
    Nullable!string version_str;
}