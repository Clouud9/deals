module protocol.capabilities.client;
import protocol.base;
import std.typecons;
import std.json;
import std.parallelism;

struct ClientCapabilities {
    JSONValue workspace = JSONValue.emptyObject;
    JSONValue window = JSONValue.emptyObject;
    JSONValue general = JSONValue.emptyObject;
    JSONValue experiment = JSONValue.init;
    Nullable!TextDocClientCap textDoc;
    Nullable!NotebookDocClientCap notebookDoc;
}

struct TextDocClientCap {
    struct Sync {
        Nullable!bool dynamicRegistrationSync;
        Nullable!bool willSave;
        Nullable!bool willSaveWaitUntil;
        Nullable!bool didSave;
    }

    struct Completion {
        Nullable!bool dynamicRegistration;
        Nullable!CompletionItemKind completionItemKind;
        Nullable!bool contextSupport;
        Nullable!bool insertTextMode;
        Nullable!CompletionList completionList;
        // TODO: Continue Implementation here

        struct CompletionItem {
            Nullable!bool snippetSupport;
            Nullable!bool commitCharactersSupport;
            Nullable!(MarkupKind[]) documentationFormat;
            Nullable!bool deprecatedSupport;
            Nullable!bool preselectSupport;
            Nullable!TagSupport tagSupport;
            Nullable!bool insertReplaceSupport;
            Nullable!ResolveSupport resolveSupport;
            Nullable!InsertSupport insertSupport;
            Nullable!bool labelDetailSupport;

            struct TagSupport {
                CompletionItemTag[] valueSet;
            }

            struct ResolveSupport {
                string[] properties;
            }

            struct InsertSupport {
                InsertTextMode[] valueSet;
            }
        }

        struct CompletionItemKind {
            Nullable!(CompletionItemType[]) valueSet;
        }

        struct CompletionList {
            Nullable!(string[]) itemDefaults;
        }
    }

    struct Hover {
        Nullable!bool dynamicRegistration;
        Nullable!(MarkupKind[]) contentFormat;
    }

    struct SignatureHelp {
        Nullable!bool dynamicRegistration;
        Nullable!SignatureInformation signatureInformation;
        Nullable!bool contextSupport;

        struct SignatureInformation {
            Nullable!(MarkupKind[]) documentationFormat;
            Nullable!ParameterInformation parameterInformation;
            Nullable!bool activeParameterSupport;

            struct ParameterInformation {
                Nullable!bool labelOffsetSupport;
            }
        }
    }

    struct Declaration {

    }

    struct Definition {

    }

    struct TypeDefinition {

    }

    struct Implementation {

    }

    struct Reference {

    }

    struct DocHighlight {

    }

    struct DocSymbol {

    }

    struct CodeAction {

    }

    struct CodeLens {

    }

    struct DocLink {

    }

    struct DocColor {

    }

    struct DocFormatting {

    }

    struct DocRangeFormatting {

    }

    struct DocTypeFormatting {

    }

    struct Rename {

    }

    struct PublishDiagnostics {

    }

    struct FoldingRange {

    }

    struct SelectionRange {

    }

    struct LinkedEditRange {

    }

    struct CallHierarchy {

    }

    struct SemanticTokens {

    }

    struct Moniker {

    }

    struct TypeHierarchy {

    }

    struct InlineVal {

    }

    struct InlayHint {

    }

    struct Diagnostic {

    }
}

struct NotebookDocClientCap {

}

struct TextDocSyncClientCap {

}
