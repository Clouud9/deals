module types.capabilities.client_capabilities;
import std.json;
import std.typecons;
import std.variant;

enum ResourceOperationKind : string {create = "create", rename = "rename", delete_ = "delete"}
enum FailureHandlingKind : string {
    abort = "abort",
    transactional = "transactional",
    textOnlyTransactional = "textOnlyTransactional",
    undo = "undo"
}

class ClientCapabilities {
    Workspace workspace;
    // Workspace, Window, General, Experimental
    
    this(JSONValue capabilities) {
        if ("workspace" in capabilities)
            workspace = new Workspace(capabilities["workspace"]);
    }
}

class Workspace {
    Nullable!bool applyEdit;
    Nullable!WorkspaceEditClientCapabilities workspaceEdit;
    Nullable!DidChangeConfigurationClientCapabilities didChangeConfiguration;
    // Continue Here

    this(JSONValue workspace) {
        if ("applyEdit" in workspace)
            applyEdit = workspace["applyEdit"].boolean; 
    }
}

class WorkspaceEditClientCapabilities {
    Nullable!bool documentChanges;
    JSONValue[] resourceOperations; // TODO: Add method to convert JSONValue[] to ResourceOperationKind[] 
    Nullable!FailureHandlingKind failureHandling = null;
    Nullable!bool normalizeLineEndings;
    JSONValue changeAnnotationSupport = JSONValue.init; // has boolean groupsOnLabel

    this(JSONValue workspace) {
        if ("changeAnnotationSupport" in workspace)
            changeAnnotationSupport = workspace["changeAnnotationSupport"];
        if ("normalizeLineEndings" in workspace)
            normalizeLineEndings = workspace["normalizeLineEndings"].boolean;
        if ("failureHandling" in workspace) {
            switch (workspace["failureHandling"].str) {
                case "abort": failureHandling = FailureHandlingKind.abort; break;
                case "transactional": failureHandling = FailureHandlingKind.transactional; break;
                case "textOnlyTransactional": failureHandling = FailureHandlingKind.textOnlyTransactional; break;
                case "undo": failureHandling = FailureHandlingKind.undo; break;
                default: assert(false, "Failure Handling Kind found but not valid");
            }
        }
        
        if ("resourceOperations" in workspace)
            resourceOperations = workspace["resourceOperations"].array;
        if ("documentChanges" in workspace)
            documentChanges = workspace["documentChanges"].boolean;
    }
}

class DidChangeConfigurationClientCapabilities {
    Nullable!bool dynamicRegistration;

    this(JSONValue didChange) {
        if ("dynamicRegistration" in didChange)
            dynamicRegistration = didChange["dynamicRegistration"].boolean;
    }
}

class DidChangeWatchedFilesClientCapabilities {
    Nullable!bool dynamicRegistration;
    Nullable!bool relativePatternSupport;
    
    this(JSONValue didChangeWatched) {
        if ("dynamicRegistration" in didChangeWatched)
            dynamicRegistration = didChangeWatched["dynamicRegistration"].boolean;
        if ("relativePatternSupport" in didChangeWatched)
            relativePatternSupport = didChangeWatched["relativePatternSupport"].boolean;
    }
}