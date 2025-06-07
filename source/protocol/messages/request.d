module protocol.messages.request;
import protocol.messages.message;
import std.typecons;
import std.variant;
import hipjson;
import std.container.array;
import std.stdio;

struct Request {
    mixin Message;
    string method;
    JSONValue id;
    JSONValue params = JSONValue.init;
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
