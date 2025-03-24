module types.messages.request;
import types.messages.message;
import std.typecons;
import std.variant;
import std.json;
import std.container.array;
import std.stdio;

class Request : Message {
    string method;
    JSONValue id;
    JSONValue params = JSONValue.init;

    this(JSONValue json) {
        super(json);
        id = json["id"];
        method = json["method"].str;
        
        if ("params" in json)
            params = json["params"];
    }
}

unittest {
    string jsonString = `{"jsonrpc":"2.0","id":1,"method":"initialize"}`;
    JSONValue json = parseJSON(jsonString);
    Request request = new Request(json);
    //writeln(request.root.toString);

    jsonString = `{"jsonrpc":"2.0","id":1,"method":"initialize","params":null}`;
    json = parseJSON(jsonString);
    request = new Request(json);
    //writeln(request.root.toString);
}
