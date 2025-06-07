module protocol.messages.results.initialize_result;
import protocol.capabilities.server;
import protocol.base.types; 

struct InitializeResult {
    ServerCapabilities capabilities;
    Optional!ServerInfo serverInfo;

    struct ServerInfo {
        string name;
        Optional!string version_;
    }
}