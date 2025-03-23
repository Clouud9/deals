module types.messages.initalize;
import types.messages.request;
import std.json;

// TODO: Finish Implementing Constructor And Params Fields.
class InitializeRequest : Request {
    JSONValue processID;
    JSONValue clientInfo;
    JSONValue locale;
    JSONValue rootPath;
    JSONValue rootURI;
    JSONValue initializationOptions;
    JSONValue capabilities;
    JSONValue trace;
    JSONValue workspaceFolders;

    this(JSONValue json) {
        super(json);
        JSONValue params = json["params"];
        assert(params.type == JSONType.object, "Initialization JSON has non-object params");

        assert("processID"    !in params ||
               "capabilities" !in params ||
               "rootUri"      !in params,
               "Missing Mandatory Parameters"
        );

        processID = params["processId"];
        capabilities = params["capabilities"];
        rootURI = params["rootUri"];

        if ("clientInfo" in params) {
            clientInfo = params["clientInfo"];
            assert(clientInfo.type == JSONType.object, "clientInfo is invalid type");
            assert("name" in clientInfo, "clientInfo missing name");
            assert(clientInfo["name"].type == JSONType.string, "clientInfo's name is invalid type");

            if ("version" in clientInfo) {
                assert(clientInfo["version"].type == JSONType.string, "clientInfo's version is invalid type");
            }            
        }

        

    }
}