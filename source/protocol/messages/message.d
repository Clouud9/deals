module protocol.messages.message;
import std.variant;
import hip.data.json;

mixin template Message() {
    string jsonrpc = "2.0";
}

class MessageClass {
    string jsonrpc = "2.0";
}