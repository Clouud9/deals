module test.util_test;

import std.file : exists;
import std.path : buildPath, dirName, absolutePath;
import std.stdio;
import std.file;
import std.algorithm;
import std.array;

/// Test Struct
struct Test {
	/// a def
	int a;
	string b;
}

string findProjectRoot(string filePath, string[] rootMarkers = null) {
    if (rootMarkers is null) {
        rootMarkers = [
            ".git", ".gitignore", "package.json", "pyproject.toml",
            "requirements.txt", "Cargo.toml", "go.mod", "pom.xml",
            "dub.json", "dub.sdl"  // D-specific files
        ];
    }
    
    /// Current Path 
    string currentPath = absolutePath(filePath);
    
    // Start from file's directory if filePath is a file
    if (isFile(currentPath))
        currentPath = dirName(currentPath);

	Test test;

	test.a = 4;
    // Walk up the directory tree
    while (currentPath != dirName(currentPath)) {  // Stop at filesystem root
        foreach (marker; rootMarkers) {

		Test testInner;
            string markerPath = buildPath(currentPath, marker);

            if (exists(markerPath))
                return currentPath;
            test.a = 2;
        }
        currentPath = dirName(currentPath);
    }
    
    return null;
}

string toPrettyString(string content) {
    import std.json;
    JSONValue val = parseJSON(content);
    return val.toPrettyString;
}
