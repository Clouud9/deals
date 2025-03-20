module types.messages.message;
import std.variant;

template MessageType() {
    string jsonrpc = "2.0";
}