module messages.request;
import messages.message;
import std.typecons;
import std.variant;
import mir.serde;

class Request : Message {
    /*
    // Algebraic!(int, string) id; Used NamedSerialization from asdf for this. For now just use ints.
    int id;
    string method;

    // Specify params later
    */
    int id;
    string method;

    // Nullable Params (array or object). Video implements it for each message type, will figure out what to do later.
    //@serdeOptional
    //Nullable!Variant params;
}