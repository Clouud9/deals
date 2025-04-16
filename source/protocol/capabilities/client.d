module protocol.capabilities.client;
import protocol.base;
import std.typecons;
import std.json;
import std.parallelism;
import std.sumtype;

struct ClientCapabilities {
    JSONValue workspace = JSONValue.emptyObject;
    JSONValue window = JSONValue.emptyObject;
    JSONValue general = JSONValue.emptyObject;
    JSONValue experiment = JSONValue.init;
    Nullable!TextDocClientCap textDoc;
    Nullable!NotebookDocClientCap notebookDoc;
}

struct TextDocClientCap {
    Nullable!Synchronization synchronization;
    Nullable!Completion completion;
    Nullable!Hover hover;
    Nullable!SignatureHelp signatureHelp;
    Nullable!Declaration declaration;
    Nullable!Definition definition;
    Nullable!TypeDefinition typeDefinition;
    Nullable!Implementation implementation;
    Nullable!Reference reference;
    Nullable!DocHighlight docHighlight;
    Nullable!DocSymbol docSymbol;
    Nullable!CodeAction codeAction;
    Nullable!CodeLens codeLens;
    Nullable!DocLink docLink;
    Nullable!DocColor docColor;
    Nullable!DocFormatting docFormatting;
    Nullable!DocRangeFormatting docRangeFormatting;
    Nullable!DocTypeFormatting docTypeFormatting;
    Nullable!Rename rename;
    Nullable!PublishDiagnostics publishDiagnostics;
    Nullable!FoldingRange foldingRange;
    Nullable!SelectionRange selectionRange;
    Nullable!LinkedEditRange linkedEditRange;
    Nullable!CallHierarchy callHierarchy;
    Nullable!SemanticTokens semanticTokens;
    Nullable!Moniker moniker;
    Nullable!TypeHierarchy typeHierarchy;
    Nullable!InlineVal inlineVal;
    Nullable!InlayHint inlayHint;
    Nullable!Diagnostic diagnostic;

    struct Synchronization {
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
        Nullable!bool dynamicRegistration;
        Nullable!bool linkSupport;
    }

    struct Definition {
        Nullable!bool dynamicRegistration;
        Nullable!bool linkSupport;
    }

    struct TypeDefinition {
        Nullable!bool dynamicRegistration;
        Nullable!bool linkSupport;
    }

    struct Implementation {
        Nullable!bool dynamicRegistration;
        Nullable!bool linkSupport;
    }

    struct Reference {
        Nullable!bool dynamicRegistration;
    }

    struct DocHighlight {
        Nullable!bool dynamicRegistration;
    }

    struct DocSymbol {
        Nullable!bool dynamicRegistration;
        Nullable!SymbolType symbolKind;
        Nullable!bool hierarchicalDocSymbolSupport;
        Nullable!SymbolTagType tagSupport;
        Nullable!bool labelSupport;

        struct SymbolType {
            Nullable!(SymbolKind[]) valueSet;
        }

        struct SymbolTagType {
            Nullable!(SymbolTag[]) valueSet;
        }
    }

    struct CodeAction {
        Nullable!bool dynamicRegistration;
        Nullable!LiteralSupport codeActionLiteralSupport;
        Nullable!bool isPreferredSupport;
        Nullable!bool disabledSupport;
        Nullable!bool dataSupport;
        Nullable!ResolveSupport resolveSupport;
        Nullable!bool honorsChangeAnnotation;

        struct LiteralSupport {
            struct ActionKind {
                CodeActionKind[] valueSet;
            }
        }

        struct ResolveSupport {
            string[] properties;
        }
    }

    struct CodeLens {
        Nullable!bool dynamicRegistration;
    }

    struct DocLink {
        Nullable!bool dynamicRegistration;
        Nullable!bool tooltipSupport;
    }

    struct DocColor {
        Nullable!bool dynamicRegistration;
    }

    struct DocFormatting {
        Nullable!bool dynamicRegistration;
    }

    struct DocRangeFormatting {
        Nullable!bool dynamicRegistration;
    }

    struct DocTypeFormatting {
        Nullable!bool dynamicRegistration;
    }

    struct Rename {
        Nullable!bool dynamicRegistration;
        Nullable!bool prepareSupport;
        Nullable!PrepSupportDefaultBehavior prepDefaultBehavior;
        Nullable!bool honorsChangeAnnotations;
    }

    struct PublishDiagnostics {
        Nullable!bool relatedInformation;
        Nullable!TagSupport tagSupport;
        Nullable!bool versionSupport;
        Nullable!bool codeDescriptionSupport;
        Nullable!bool dataSupport;

        struct TagSupport {
            DiagnosticTag[] valueSet;
        }
    }

    struct FoldingRange {
        Nullable!bool dynamicRegistration;
        Nullable!uint rangeLimit;
        Nullable!bool lineFoldingOnly;
        Nullable!FoldingRangeKind foldingRangeKind;
        Nullable!FoldingRange foldingRange;

        struct FoldingRangeKind {
            Nullable!(FoldingRangeType[]) valueSet;
        }

        struct FoldingRange {
            Nullable!bool collapsedText;
        }
    }

    struct SelectionRange {
        Nullable!bool dynamicRegistration;
    }

    struct LinkedEditRange {
        Nullable!bool dynamicRegistration;
    }

    struct CallHierarchy {
        Nullable!bool dynamicRegistration;
    }

    struct SemanticTokens {
        Nullable!bool dynamicRegistration;
        Nullable!Requests requests;
        string[] tokenTypes;
        string[] tokenModifiers;
        TokenFormat[] formats;
        Nullable!bool overlappingTokenSupport;
        Nullable!bool multilineTokenSupport;
        Nullable!bool serverCancelSupport;
        Nullable!bool augmentsSyntaxTokens;

        struct Requests {
            Nullable!(SumType!(bool, EmptyObject)) range;
            Nullable!(SumType!(bool, FullObject)) full;

            struct FullObject {
                Nullable!bool delta;
            }

            struct EmptyObject {}
        }
    }

    struct Moniker {
        Nullable!bool dynamicRegistration;
    }

    struct TypeHierarchy {
        Nullable!bool dynamicRegistration;
    }

    struct InlineVal {
        Nullable!bool dynamicRegistration;
    }

    struct InlayHint {
        Nullable!bool dynamicRegistration;
        Nullable!ResolveSupport resolveSupport;

        struct ResolveSupport {
            string[] properties;
        }
    }

    struct Diagnostic {
        Nullable!bool dynamicRegistration;
        Nullable!bool relatedDocumentSupport;
    }
}

// TODO: Implement
struct NotebookDocClientCap {
    DocSync synchronization;

    struct DocSync {
        Nullable!bool dynamicRegistration;
        Nullable!bool executionSummarySupport;
    }
}