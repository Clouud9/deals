module messages.request;
import messages.message;
import std.typecons;
//import std.variant;
import mir.algebraic;
import std.range;

//import mir.algebraic;
import mir.serde;
import asdf.serialization;

@serdeIsSerializable
@serdeIsDeserializable
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
    @serdeOptional
    Nullable!(string, int, float) params; // Array or Object

    void serialize(S)(ref S serializer) const {
        auto state = serializer.structBegin();
        serializer.putKey("jsonrpc");
        serializer.serializeValue(jsonrpc);

        serializer.putKey("id");
        serializer.serializeValue(id);

        serializer.putKey("method");
        serializer.serializeValue(method);

        if (params.isNull == false) {
            serializer.putKey("params");
            serializer.serializeValue(params);
        }

        serializer.structEnd(state);
    }

    import asdf.asdf;
    SerdeException deserializeFromJson(Asdf asdfData) {
        if (auto e = asdfData["jsonrpc"].deserializeValue(jsonrpc)) {
            return e;
        }

        if (auto e = asdfData["id"].deserializeValue(id)) {
            return e;
        }

        if (auto e = asdfData["method"].deserializeValue(method)) {
            return e;
        }

        if (auto e = asdfData["params"].deserializeValue(params)) {
            params = null;
        }

        return null;
    }
}

unittest {
    import asdf;
    import std.stdio;

    Request request = new Request();
    request.id = 5;
    request.method = "test";
    writeln("Request Test: ", request.serializeToJson());
    request.params = "testter";
    writeln("Request Test 2: ", request.serializeToJson());

    string json = request.serializeToJson();
    Request newReq =  json.deserialize!Request;
    writeln(newReq.jsonrpc, "\n", newReq.method, "\n", newReq.id);
    if (newReq.params == null) {
        writeln("null");
    }

    // Request newRequest = request.serializeToJson().deserial
}
