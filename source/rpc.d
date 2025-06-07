module rpc;
import std.stdio;
import std.conv : to;
import core.stdc.stdlib;
import std.array;
import std.logger;
import std.string;
import hipjson;

string encodeMessage(JSONValue message) {
    // Error Checking using JSONException // Go's marshal function returns a byte arr
    string json_string = message.toString;
    ulong length = json_string.length;
    return "Content-Length: " ~ to!string(length) ~ "\r\n\r\n" ~ json_string;
}

void decodeMessage(string message, out string method, out string content) {
    string sep = "\r\n\r\n";
    auto header_and_content = message.split(sep);
    content = header_and_content[1];

    JSONValue data = parseJSON(content);
    method = data["method"].str;
    return;
}

struct Message {
    import std.typecons; // Nullable for later?
    string method;

    this(string method) {
        this.method = method;
    }
}