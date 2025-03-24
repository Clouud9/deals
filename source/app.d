module app;

import std.stdio;
import std.array;
import std.conv : to;
import std.algorithm : startsWith;
import std.string;
import std.logger;
import core.stdc.stdio : fgets;
import core.stdc.stdlib : exit;

import rpc;
import std.json;

static this() {
	auto file = File("C://Users/l_sne/Base/Projects/D/deals/deals.log", "w"); // change to a in production
	sharedLog = cast(shared) new FileLogger(file);
}

// TODO: Define a queue data structure or find one if need be.
// 	Would probably need to implement a blocking queue to prevent threading errors and such
version (unittest) {

} else {
	int main() {
		log("Starting Deals");
		bool initialize_received = false;

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
			handleMessage(method, content); // Initialize has \r\n in nvim
		}
		return 0;
	}
}

void handleMessage(string method, string content) {
	stderr.write("Received Message With Method: ", method);
	import core.time, core.thread;
	Thread.sleep(msecs(5)); // Makes it so that newline isn't ignored 
	log("Received Message With Method: ", method);

	JSONValue requestJSON = parseJSON(content);
	// Temporarily to test response
	if (method == "initialize") {
		log("initialization thing");
		JSONValue json = JSONValue.emptyObject;
		json["id"] = JSONValue(1);
		json["result"] = JSONValue.emptyObject;
		json["result"]["capabilities"] = JSONValue.emptyObject;

		json["result"]["serverInfo"] = JSONValue.emptyObject;
		json["result"]["serverInfo"]["name"] = JSONValue("deals");
		json["result"]["serverInfo"]["version"] = JSONValue("v0.1");
		auto header = "Content-Length: " ~ to!string(json.toString.length) ~ "\r\n\r\n";
		string output = header ~ json.toString;
		stdout.rawWrite(output);
	} else if (method == "shutdown") {
		exit(0);
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
