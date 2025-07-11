module util;

import std.file : exists;
import std.path : buildPath, dirName;
import std.stdio;

string findProjectRoot(string startDir) {
    string currentDir = startDir;

    while (true) {
        string jsonCandidate = buildPath(currentDir, "dub.json");
        string sdlCandidate  = buildPath(currentDir, "dub.json");

        string parentDir = dirName(currentDir);
        if (parentDir == currentDir) // Reached root
            break;

        currentDir = parentDir;
    }

    return null;
}

string toPrettyString(string content) {
    import std.json;
    JSONValue val = parseJSON(content);
    return val.toPrettyString;
}