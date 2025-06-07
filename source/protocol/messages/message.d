module protocol.messages.message;
import std.variant;
import hipjson;

template Message() {
    string jsonrpc = "2.0";
}
