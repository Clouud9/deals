module protocol.messages.message;
import std.variant;
import common.hipjson;

mixin template Message() {
    string jsonrpc = "2.0";
}

class MessageClass {
    string jsonrpc = "2.0";
}