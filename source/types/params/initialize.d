module types.params.initialize;

import mir.algebraic;
import mir.serde;
import params.work_done_progress;

// Extends work done progress params. 
// WorkDoneProgress has only a workDoneToken of type ProgressToken

struct InitalizizeParams {
    mixin WorkDoneProgressType;
}

/*
@serdeIsSerializable
@serdeIsDeserializable
class InitalizeParams {
    @serdeOptional
    Nullable!int processId;

    // Client Info w/ name and version strings, optional (version string is optional too)

    // Optional Locale String

    // Optional & nullable root path string, deprecated

    // Root URI, nullable documentURI type, deprecated

    // Initalization Options, LSPAny type, optional

    // capabilities, ClientCapabilities type

    // trace, TraceValue, optional

    // workspaceFolders, nullable WorkspaceFolder[], optional
}
*/

struct ClientInfo {
    string name;

    @serdeOptional
    @serdeIgnoreOutIf!((Nullable!string s) => s.isNull)
    @serdeKeys("version")
    Nullable!string version_string;
}