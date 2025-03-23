module types.messages.response;
import types.messages.message;
import std.typecons;
import std.json;
import std.variant;

class Response : Message {
    JSONValue id;
    JSONValue result = JSONValue.init;
    Nullable!ResponseError error;

    this(JSONValue json) {
        super(json);
    }
}

class ResponseError {
    long code;
    string message;
    JSONValue data;

    this(JSONValue response_json) {
        code = response_json["code"].integer;
        message = response_json["message"].str;

        if ("data" in response_json) 
            data = response_json["data"];
    }
}