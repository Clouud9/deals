module protocol.messages.request;
import protocol.messages.message;
import std.typecons;
import std.variant;
import hip.data.json;
import std.container.array;
import std.stdio;

struct Request {
    mixin Message;
    string method;
    JSONValue id;
    JSONValue params = JSONValue.init;
}