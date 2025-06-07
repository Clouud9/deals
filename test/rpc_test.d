module test.rpc_test;
import std.format;
import hipjson;
import std.stdio;
import rpc;

import core.stdc.stdlib;

struct Example {
    JSONValue root;
    bool testing;

    this(bool isTrue) {
        root = JSONValue.emptyObject;
        root["testing"] = isTrue;
        testing = isTrue;
    }
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
    string actual = encodeMessage(Example(true).root);

    if (expected != actual) {
        string form = format("Expected: %s, Actual: %s\n", expected, actual);
        assert(false, form);
    } else {
        //writeln("Encoding Test Passed");
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