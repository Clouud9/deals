module protocol.messages.response;
import protocol.messages.message;
import std.typecons;
import hipjson;
import std.variant;
import protocol.base.types;
import std.sumtype;

struct Response {
    mixin Message;
    SumType!(string, int, typeof(null))* id;
    JSONValue* result;
    Optional!ResponseError error; // Might change to Variant

    alias ResponseID = SumType!(string, int);
}

struct ResponseError {
    long code;
    string message;
    Optional!JSONValue data;
}

mixin template ResponseType() {
    mixin Message;
    Nullable!ResponseID id;
    Optional!JSONValue result;
    Optional!ResponseError error; // Might change to Variant

    alias ResponseID = SumType!(string, int);
}