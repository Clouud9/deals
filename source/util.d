module util;

import std.file : exists;
import std.path : buildPath, dirName, absolutePath;
import std.stdio;
import std.file;
import std.algorithm;
import std.array;

string findProjectRoot(string filePath, string[] rootMarkers = null) {
    if (rootMarkers is null) {
        rootMarkers = [
            ".git", ".gitignore", "package.json", "pyproject.toml",
            "requirements.txt", "Cargo.toml", "go.mod", "pom.xml",
            "dub.json", "dub.sdl"  // D-specific files
        ];
    }
    
    string currentPath = absolutePath(filePath);
    
    // Start from file's directory if filePath is a file
    if (isFile(currentPath))
        currentPath = dirName(currentPath);
    
    
    // Walk up the directory tree
    while (currentPath != dirName(currentPath)) {  // Stop at filesystem root
        foreach (marker; rootMarkers) {
            string markerPath = buildPath(currentPath, marker);

            if (exists(markerPath))
                return currentPath;
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