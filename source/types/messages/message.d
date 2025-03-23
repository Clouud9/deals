module types.messages.message;
import std.variant;
import std.json;

class Message {
    JSONValue root;
    string jsonrpc;

    this(JSONValue json) {
        root = json;
        jsonrpc = json["jsonrpc"].str;
    }
}

unittest {
    JSONValue json = JSONValue.emptyObject;
    json.object["jsonrpc"] = JSONValue("2.0");
    assert(json.toString == `{"jsonrpc":"2.0"}`);
}