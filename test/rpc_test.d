module test.rpc_test;
import std.format;
import std.json;
import std.stdio;
import rpc;

import core.stdc.stdlib;

struct Example {
    bool testing;

    this(bool isTrue) {
        testing = isTrue;
    }

    /* 
    // TODO: This doesn't auto-serialize like Go's library does. Would have to use jsonizer, mir-ion, asdf or some other library. 
    JSONValue toJSON() const {
        return JSONValue([
            "testing": JSONValue(testing)
        ]);
    }    
    */
}

unittest {
    testEncode();
}

unittest {
    testDecode();
}

void testEncode() {
    // Test example json file with example struct
    string expected = "Content-Length: 16\r\n\r\n{\"testing\":true}";
    string actual = encodeMessage!Example(Example(true));

    if (expected != actual) {
        string form = format("Expected: %s, Actual: %s\n", expected, actual);
        assert(false, form);
    } else {
        writeln("Encoding Test Passed");
    }
}

void testDecode() {
    string expected = "Content-Length: 15\r\n\r\n{\"method\":\"hi\"}";
    string method; 
    string content;
    decodeMessage(expected, method, content);
    long length = content.length;
    string form = format("Expected: 16, Actual: %d", length);
    assert(length == 15, form);

    string content_form = format("Expected: hi, Actual: %s", content);
    assert(method == "hi", content_form);
}