module types.messages.request;
import types.messages.message;
//import std.typecons;
//import std.variant;
import mir.algebraic;
import std.range;

//import mir.algebraic;
import mir.serde;
import asdf.serialization;

struct Request {
    mixin MessageType;
    int id;
    string method;

    @serdeOptional
    @serdeIgnoreOutIf!((Nullable!(string, int) s) => s.isNull)
    Nullable!(string, int) params;
}


unittest {
    import asdf;
    import std.stdio;

    /** 
     * Test One
     */
    Request request = Request();
    request.id = 5;
    request.method = "test";

    string jsonOne = "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"test\"}";
    string errOne = "Request with null params failed to serialize";
    assert(request.serializeToJson() == jsonOne, errOne);

    /** 
     * Test Two
     */
    request.params = "testter";
    string jsonTwo = "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"test\",\"params\":\"testter\"}";
    string errTwo = "Request with non-null params failed to serialize";
    assert(request.serializeToJson() == jsonTwo, errTwo);

    /** 
     * Test Three
     */
    Request req = jsonTwo.deserialize!Request;
    if (
        req.jsonrpc != "2.0"    ||
        req.id != 5             ||
        req.method != "test"    ||
        req.params != "testter"
    ) {
        assert(false, "Failed to deserialize JSON with non-null params");
    }
    
    /** 
     * Test Four
     */
    Request secondRequest = Request();
    secondRequest.id = 6;
    secondRequest.method = "nullTest";

    string json = secondRequest.serializeToJson();
    Request newReq =  json.deserialize!Request;
    if (
        newReq.jsonrpc != "2.0"      ||
        newReq.id      != 6          ||
        newReq.method  != "nullTest" ||
        newReq.params  != null
    ) {
        writeln(newReq.params);
        assert(false, "Failed to deserialize JSON with null params");
    }
}
