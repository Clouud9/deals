module messages.response;
import messages.message;
import std.typecons;
import mir.serde;
import std.variant;

class Response : Message {    
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