module protocol.capabilities.client;
import protocol.base;
import std.typecons;
import hip.data.json;
import std.parallelism;
import std.sumtype;

struct ClientCapabilities {
    Optional!ClientWorkspace workspace;
    Optional!WindowClientCapabilites window;
    Optional!GeneralClientCapabilities general;
    Optional!TextDocClientCap textDoc;
    Optional!NotebookDocClientCap notebookDoc;
    JSONValue experiment = JSONValue.init;
}

// TODO: Many of these structs only have one item with the same name and type, alias this type later, or use mixins. 
struct ClientWorkspace {
    Optional!bool applyEdit;
    Optional!WorkspaceEditClientCapabilities workspaceEdit;
    Optional!DidChangeConfigClientCapabilites didChangeConfiguration;
    Optional!DidChangeWatchedFilesClientCapabilities didChangeWatchedFiles;
    Optional!WorkspaceSymbolClientCapabilities symbol;
    Optional!ExecCommandClientCapabilites executeCommand;
    Optional!bool workspaceFolders;
    Optional!bool configuration;
    Optional!SemanticTokensWorkspaceClientCapabilities semanticTokens;
    Optional!CodeLensWorkspaceClientCapabilties codeLens;
    Optional!ClientFileOperations fileOperations;
    Optional!InlineValueWorkspaceClientCapabilities inlineValue;
    Optional!InlayHintWorkspaceClientCapabilites inlayHint;
    Optional!DiagnosticWorkspaceClientCapabilites diagnostic;

    struct WorkspaceEditClientCapabilities {
        Optional!bool documentChanges;
        Optional!(ResourceOperationKind[]) resourceOperations;
        Optional!FailureHandlingKind failureHandling;
        Optional!bool normalizesLineEndings;
        Optional!AnnotationSupport changeAnnotationSupport;

        struct AnnotationSupport {
            Optional!bool groupsOnLabel;
        }
    }

    struct DidChangeConfigClientCapabilites {
        Optional!bool dynamicRegistration;
    }

    struct DidChangeWatchedFilesClientCapabilities {
        Optional!bool dynamicRegistration;
        Optional!bool relativePatternSupport;
    }

    struct WorkspaceSymbolClientCapabilities {
        Optional!bool dynamicRegistration;
        Optional!SymbolType symbolKind;
        Optional!TagSupport tagSupport;
        Optional!ResolveSupport resolveSupport;

        struct SymbolType {
            Optional!(SymbolKind[]) valueSet;
        }

        struct TagSupport {
            SymbolTag[] valueSet;
        }

        struct ResolveSupport {
            string[] properties;
        }
    }

    struct ExecCommandClientCapabilites {
        Optional!bool dynamicRegistration;
    }

    struct SemanticTokensWorkspaceClientCapabilities {
        Optional!bool refreshSupport;
    }

    struct CodeLensWorkspaceClientCapabilties {
        Optional!bool refreshSupport;
    }

    struct ClientFileOperations {
        Optional!bool dynmaicRegistration;
        Optional!bool didCreate;
        Optional!bool willCreate;
        Optional!bool didRename;
        Optional!bool willRename;
        Optional!bool didDelete;
        Optional!bool willDelete;
    }

    struct InlineValueWorkspaceClientCapabilities {
        Optional!bool refreshSupport;
    }

    struct InlayHintWorkspaceClientCapabilites {
        Optional!bool refreshSupport; 
    }

    struct DiagnosticWorkspaceClientCapabilites {
        Optional!bool refreshSupport;
    }
}

struct WindowClientCapabilites {
    Optional!bool workDoneProgress;
    Optional!ShowMessageRequestClientCapabilites showMessage;
    Optional!ShowDocumentClientCapabilites showDocument;

    struct ShowMessageRequestClientCapabilites {
        Optional!MessageActionItem messageActionItem;

        struct MessageActionItem {
            Optional!bool additionalPropertiesSupport;
        }
    }

    struct ShowDocumentClientCapabilites {
        bool support;
    }
}

struct GeneralClientCapabilities {
    Optional!StaleRequestSupport staleRequestSupport;
    Optional!RegularExpressionClientCapabilites regularExpressions;
    Optional!MarkdownClientCapabilities markdown;
    Optional!(PositionEncodingKind[]) positionEncodings;

    struct StaleRequestSupport {
        bool cancel;
        string[] retryOnContentModified;
    }
    
    struct RegularExpressionClientCapabilites {
        string engine;
        Optional!string version_str;
    }

    struct MarkdownClientCapabilities {
        string parser;
        Optional!string version_str;
        Optional!(string[]) allowedTags;
    }
}

struct TextDocClientCap {
    Optional!Synchronization synchronization;
    Optional!Completion completion;
    Optional!Hover hover;
    Optional!SignatureHelp signatureHelp;
    Optional!Declaration declaration;
    Optional!Definition definition;
    Optional!TypeDefinition typeDefinition;
    Optional!Implementation implementation;
    Optional!Reference reference;
    Optional!DocHighlight docHighlight;
    Optional!DocSymbol docSymbol;
    Optional!CodeAction codeAction;
    Optional!CodeLens codeLens;
    Optional!DocLink docLink;
    Optional!DocColor docColor;
    Optional!DocFormatting docFormatting;
    Optional!DocRangeFormatting docRangeFormatting;
    Optional!DocTypeFormatting docTypeFormatting;
    Optional!Rename rename;
    Optional!PublishDiagnostics publishDiagnostics;
    Optional!FoldingRange foldingRange;
    Optional!SelectionRange selectionRange;
    Optional!LinkedEditRange linkedEditRange;
    Optional!CallHierarchy callHierarchy;
    Optional!SemanticTokens semanticTokens;
    Optional!Moniker moniker;
    Optional!TypeHierarchy typeHierarchy;
    Optional!InlineVal inlineVal;
    Optional!InlayHint inlayHint;
    Optional!Diagnostic diagnostic;

    struct Synchronization {
        Optional!bool dynamicRegistrationSync;
        Optional!bool willSave;
        Optional!bool willSaveWaitUntil;
        Optional!bool didSave;
    }

    struct Completion {
        Optional!bool dynamicRegistration;
        Optional!CompletionItemKind completionItemKind;
        Optional!bool contextSupport;
        Optional!bool insertTextMode;
        Optional!CompletionList completionList;
        // TODO: Continue Implementation here

        struct CompletionItem {
            Optional!bool snippetSupport;
            Optional!bool commitCharactersSupport;
            Optional!(MarkupKind[]) documentationFormat;
            Optional!bool deprecatedSupport;
            Optional!bool preselectSupport;
            Optional!TagSupport tagSupport;
            Optional!bool insertReplaceSupport;
            Optional!ResolveSupport resolveSupport;
            Optional!InsertSupport insertSupport;
            Optional!bool labelDetailSupport;

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
            Optional!(CompletionItemType[]) valueSet;
        }

        struct CompletionList {
            Optional!(string[]) itemDefaults;
        }
    }

    struct Hover {
        Optional!bool dynamicRegistration;
        Optional!(MarkupKind[]) contentFormat;
    }

    struct SignatureHelp {
        Optional!bool dynamicRegistration;
        Optional!SignatureInformation signatureInformation;
        Optional!bool contextSupport;

        struct SignatureInformation {
            Optional!(MarkupKind[]) documentationFormat;
            Optional!ParameterInformation parameterInformation;
            Optional!bool activeParameterSupport;

            struct ParameterInformation {
                Optional!bool labelOffsetSupport;
            }
        }
    }

    struct Declaration {
        Optional!bool dynamicRegistration;
        Optional!bool linkSupport;
    }

    struct Definition {
        Optional!bool dynamicRegistration;
        Optional!bool linkSupport;
    }

    struct TypeDefinition {
        Optional!bool dynamicRegistration;
        Optional!bool linkSupport;
    }

    struct Implementation {
        Optional!bool dynamicRegistration;
        Optional!bool linkSupport;
    }

    struct Reference {
        Optional!bool dynamicRegistration;
    }

    struct DocHighlight {
        Optional!bool dynamicRegistration;
    }

    struct DocSymbol {
        Optional!bool dynamicRegistration;
        Optional!SymbolType symbolKind;
        Optional!bool hierarchicalDocSymbolSupport;
        Optional!SymbolTagType tagSupport;
        Optional!bool labelSupport;

        struct SymbolType {
            Optional!(SymbolKind[]) valueSet;
        }

        struct SymbolTagType {
            Optional!(SymbolTag[]) valueSet;
        }
    }

    struct CodeAction {
        Optional!bool dynamicRegistration;
        Optional!LiteralSupport codeActionLiteralSupport;
        Optional!bool isPreferredSupport;
        Optional!bool disabledSupport;
        Optional!bool dataSupport;
        Optional!ResolveSupport resolveSupport;
        Optional!bool honorsChangeAnnotation;

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
        Optional!bool dynamicRegistration;
    }

    struct DocLink {
        Optional!bool dynamicRegistration;
        Optional!bool tooltipSupport;
    }

    struct DocColor {
        Optional!bool dynamicRegistration;
    }

    struct DocFormatting {
        Optional!bool dynamicRegistration;
    }

    struct DocRangeFormatting {
        Optional!bool dynamicRegistration;
    }

    struct DocTypeFormatting {
        Optional!bool dynamicRegistration;
    }

    struct Rename {
        Optional!bool dynamicRegistration;
        Optional!bool prepareSupport;
        Optional!PrepSupportDefaultBehavior prepDefaultBehavior;
        Optional!bool honorsChangeAnnotations;
    }

    struct PublishDiagnostics {
        Optional!bool relatedInformation;
        Optional!TagSupport tagSupport;
        Optional!bool versionSupport;
        Optional!bool codeDescriptionSupport;
        Optional!bool dataSupport;

        struct TagSupport {
            DiagnosticTag[] valueSet;
        }
    }

    struct FoldingRange {
        Optional!bool dynamicRegistration;
        Optional!uint rangeLimit;
        Optional!bool lineFoldingOnly;
        Optional!FoldingRangeKind foldingRangeKind;
        Optional!FoldingRange foldingRange;

        struct FoldingRangeKind {
            Optional!(FoldingRangeType[]) valueSet;
        }

        struct FoldingRange {
            Optional!bool collapsedText;
        }
    }

    struct SelectionRange {
        Optional!bool dynamicRegistration;
    }

    struct LinkedEditRange {
        Optional!bool dynamicRegistration;
    }

    struct CallHierarchy {
        Optional!bool dynamicRegistration;
    }

    struct SemanticTokens {
        Optional!bool dynamicRegistration;
        Optional!Requests requests;
        string[] tokenTypes;
        string[] tokenModifiers;
        TokenFormat[] formats;
        Optional!bool overlappingTokenSupport;
        Optional!bool multilineTokenSupport;
        Optional!bool serverCancelSupport;
        Optional!bool augmentsSyntaxTokens;

        struct Requests {
            Optional!Range range;
            Optional!Full full;

            struct FullObject {
                Optional!bool delta;
            }

            struct EmptyObject {}

            alias Range = SumType!(bool, EmptyObject);
            alias Full = SumType!(bool, FullObject);
        }
    }

    struct Moniker {
        Optional!bool dynamicRegistration;
    }

    struct TypeHierarchy {
        Optional!bool dynamicRegistration;
    }

    struct InlineVal {
        Optional!bool dynamicRegistration;
    }

    struct InlayHint {
        Optional!bool dynamicRegistration;
        Optional!ResolveSupport resolveSupport;

        struct ResolveSupport {
            string[] properties;
        }
    }

    struct Diagnostic {
        Optional!bool dynamicRegistration;
        Optional!bool relatedDocumentSupport;
    }
}

// TODO: Implement
struct NotebookDocClientCap {
    DocSync synchronization;

    struct DocSync {
        Optional!bool dynamicRegistration;
        Optional!bool executionSummarySupport;
    }
}