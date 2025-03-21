module types.messages.message;
import std.variant;
import std.json;
import std.stdio;

bool message_is_valid(JSONValue json) {
    if ("jsonrpc" !in json) 
        return false;
    if (json["jsonrpc"].str != "2.0")
        return false;
    else return true;
}

class Message {
    JSONValue root;
    JSONValue jsonrpc;

    this(JSONValue json) {
        if (message_is_valid(json) == false)
            throw new Exception("Mesasge passed invalid json");
        root = json;
        jsonrpc = json["jsonrpc"];
    }
}

unittest {
    JSONValue json = JSONValue.emptyObject;
    json.object["jsonrpc"] = JSONValue("2.0");
    assert(json.toString == `{"jsonrpc":"2.0"}`);
}