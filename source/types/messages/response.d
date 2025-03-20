module types.messages.response;
import types.messages.message;
import std.typecons;
import mir.serde;
import std.variant;

struct Response {    
    mixin MessageType;
    //@serdeOptional
    //Nullable!int id; // Can be string too, just use int for now
    int id;

    //@serdeOptional
    //Nullable!Variant result;

    //@serdeOptional
    //Nullable!ResponseError error;
}

class ResponseError {
    int code;
    string message;
    Nullable!Variant data;
}