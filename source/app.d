module app;

import std.stdio;
import std.array;
import std.conv : to;
import std.algorithm : startsWith;
import std.string;
import std.logger;
import core.stdc.stdio : fgets;
import core.stdc.stdlib : exit;

import common.hipjson;
import protocol.capabilities.server;
import protocol.messages.response;
import protocol.base;
import analysis.state;
import std.sumtype;
import std.typecons;
import common.util;
import common.serialization;

static this() {
    auto file = File("deals.log", "w"); // change to a in production
    sharedLog = cast(shared) new FileLogger(file);
}

// TODO: Define a queue data structure or find one if need be.
//  Would probably need to implement a blocking queue to prevent threading errors and such
version (unittest) {

} else {
    int main() {
        log("Starting Deals");
        bool initialize_received = false;
        State state;

        /*
        debug {
            import core.sys.windows.windows;
            import core.thread, core.time;
            while (IsDebuggerPresent() == false) {
                Thread.sleep(msecs(5));
            }
        }
        */

        while (true) {
            string header, json;
            bool read = read_message(header, json);

            if (!read)
                continue; // Not sure this is what I want to do

            //writeln("HEADER: ", header);
            //writeln("JSON: ", json);
            string message = header.strip ~ "\r\n\r\n" ~ json;
            string method, content;
            //string message, method, content;
            decodeMessage(message, method, content); // Implement Error Handling for this function
            handleMessage(method, content, state);
        }
        return 0;
    }
}

void handleMessage(string method, string content, ref State state) {
    log("Received Message With Method: ", method);
    import core.time, core.thread;

    Thread.sleep(msecs(5)); // Makes it so that newline isn't ignored 
    // log("Received Message With Method: ", method);

    JSONValue requestJSON = parseJSON(content);
    // Temporarily to test response
    if (method == "initialize") {
        log("initialization");

        state = State(requestJSON);

        Response response;
        response.id = new SumType!(string, int, typeof(null))(1);
        JSONValue result = JSONValue.emptyObject();
        result["serverInfo"] = JSONValue.emptyObject();
        result["capabilities"] = JSONValue.emptyObject();
        result["serverInfo"]["name"] = "deals";
        result["serverInfo"]["version"] = "0.1";
        result["capabilities"]["textDocumentSync"] = JSONValue(TextDocSyncKind.Full);
        result["capabilities"]["hoverProvider"] = JSONValue(true);
        response.result = new JSONValue();
        *response.result = result;
        JSONValue json = response.serialize();
        auto header = "Content-Length: " ~ to!string(json.toString.length) ~ "\r\n\r\n";
        string output = header ~ json.toString;
        stdout.rawWrite(output);
        log("Initialization Response Sent");
    } else if (method == "shutdown") {
        exit(0);
    } else if (method == "initialized") {
        // Can use this to dynamically register capabilities
    } else if (method == "textDocument/didOpen") {
        // This should be moved since it has more than params
        import protocol.messages.params.text_doc_did_open;

        auto notification = DidOpenTextDocumentNotification(method, content);
        state.openDocument(notification.params.textDocument.uri, notification.params.textDocument.text);
        //log(format("Opened: %s", notification.params.textDocument.uri));
        // Can Print Contents Later
    } else if (method == "textDocument/didChange") {
        import protocol.messages.params.text_doc_did_change;

        auto notification = DidChangeTextDocumentNotification(method, content);
        foreach (item; notification.params.contentChanges) {
            auto event = cast(ChangeEventSingle) item;
            state.updateDocument(notification.params.textDocument.uri, event.text);
        }

        //log(format("Changed: %s", notification.params.textDocument.uri));
    } else if (method == "textDocument/didClose") {
        import protocol.messages.params.text_doc_did_change;

        auto notification = DidCloseTextDocumentNotification(method, content);
        string uri = notification.params.textDocument;
        state.closeDocument(uri);
    } else if (method == "textDocument/hover") {
        //log(content.toPrettyString());
        JSONValue params = requestJSON["params"];
        int id = requestJSON["id"].integer();

        string uri = params["textDocument"]["uri"].str();

        Position position;
        position.line      = params["position"]["line"].integer();
        position.character = params["position"]["character"].integer();

        string result = state.serveHover(uri, position);

        Response response;
        response.id = new SumType!(string, int, typeof(null))(id);
        response.result = new JSONValue(JSONValue.emptyObject);
        (*response.result)["contents"] = JSONValue(result);
        JSONValue json = response.serialize();
        // TODO: Implement function to automatically write header and such
        auto header = "Content-Length: " ~ to!string(json.toString.length) ~ "\r\n\r\n";
        string output = header ~ json.toString;
        stdout.rawWrite(output);
    }
}

bool read_message(out string header, out string JSON) {
    string line, line_cpy;
    ulong content_length;

    while (true) {
        if ((line = readln()) == null || stdin.eof || line.empty()) {
            return false;
        }

        line_cpy = line;

        if (line_cpy.strip.startsWith("#")) {
            continue;
        }

        if (line_cpy.strip.startsWith("Content-Length: ")) {
            if (content_length != 0) {
                log("Another Content Length Previously Found");
            }

            string num;
            num = line_cpy.strip.chompPrefix("Content-Length: ");
            content_length = to!ulong(num);
            header = line_cpy;
            continue;
        }

        if (line_cpy.strip.empty()) {
            break;
        }
    }

    if (content_length > (1 << 30)) {
        log("Content Length is too long");
        return false;
    } else if (content_length == 0) {
        log("Missing Header or Message Length of 0");
        return false;
    }

    char[] bytes = new char[content_length];
    fread(bytes.ptr, char.sizeof, content_length, stdin.getFP);
    JSON = cast(string) bytes;
    return true;
}

void decodeMessage(string message, out string method, out string content) {
    string sep = "\r\n\r\n";
    auto header_and_content = message.split(sep);
    content = header_and_content[1];

    JSONValue data = parseJSON(content);
    method = data["method"].str;
    return;
}
