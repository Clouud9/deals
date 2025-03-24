module types.messages.initalize;
import types.messages.request;
import types.messages.initialize_params;
import std.json;

// TODO: Finish Implementing Constructor And Params Fields.
class InitializeRequest : Request {
    InitializeParams params;

    this(JSONValue json) {
        params = new InitializeParams(json["params"]);
        super(json);
    }
}