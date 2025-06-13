module protocol.messages.message;
import std.variant;
import hipjson;

mixin template Message() {
    string jsonrpc = "2.0";
}
