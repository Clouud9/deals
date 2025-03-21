module types.messages.request;
import types.messages.message;
import std.typecons;
import std.variant;
import std.json;
import std.container.array;
import std.stdio;

class Request : Message {
    JSONValue method;
    JSONValue id;
    JSONValue params = JSONValue.init;

    this(JSONValue json) {
        if (request_is_valid(json) == false)
            throw new Exception("Request passed invalid JSON");
        super(json);

        method = json.object["method"];
        id     = json.object["id"];

        if (request_has_params(json))
            params = json["params"];
    }
}

// TODO: Check for Valid Types
bool request_is_valid(JSONValue json) {
    if (message_is_valid(json) == false)
        return false;
    else if ("method" !in json)
        return false;
    else if ("id" !in json)
        return false;
    else return true;
}

bool request_has_params(JSONValue json) {
    if ("params" !in json) 
        return false;
    else return true;
}

JSONType request_get_params_type(JSONValue json) {
    return json.type;
}

// TODO: Exception if params don't exist
JSONValue request_get_params(JSONValue json) {
    return json["params"];
}

unittest {
    string jsonString = `{"jsonrpc":"2.0","id":1,"method":"initialize","params":null}`;
    JSONValue json = parseJSON(jsonString);
    Request request = new Request(json);
    writeln(request.root.toString);
}