module rpc;
import std.stdio;
import std.conv : to;
import core.stdc.stdlib;
import asdf;
import std.array;
import std.logger;

string encodeMessage(T)(T message) {
    // Error Checking using JSONException // Go's marshal function returns a byte arr
    string data = message.serializeToJson();
    data = "Content-Length: " ~ data.length.to!string ~ "\r\n\r\n" ~ data;
    return data;

    /*
    string jsonString;
    try {
        JSONValue jsonData = message.toJSON();
        jsonString = jsonData.toString;
        writeln("Serialized JSON: ", jsonString);
    } catch (JSONException e) {
        writeln("Error serializing JSON: ", e.message);
        exit(1);
    } catch (Exception e) {
        writeln("An unexpected error occurred: ", e.message);
        exit(1);
    } 

    auto header = "Content-Length: " ~ jsonString.length.to!string ~ "\r\n\r\n";
    auto finalMessage = header ~ jsonString;

    return finalMessage;
    */
}

// NOTE: Temporary out params for testing(?)
void decodeMessage(string message, out string method, out string content) {
    string sep = "\r\n\r\n";
    auto data = message.split(sep);

    // If the string doesn't have the separator, then the array is just an array w/ the string as the only entry
    
    string header = data[0];
    content = data[1];

    try {
        auto base = content.deserialize!Message;
        method = base.method;
    } catch (Exception e) {
        log("Non-Vital Error:\n", e);
        method = "";
    }
}

struct Message {
    import std.typecons; // Nullable for later?
    string method;
    //@serdeOptional // Example data part of the structure, don't use data
    //Nullable!string data;

    this(string method) {
        this.method = method;
        //data = null;
    }

    this(string method, string data) {
        this.method = method;
        //this.data = data;
    }
}