module protocol.capabilities.server;
import protocol.base;
import std.typecons;
import std.sumtype;
import std.traits;
import std.json;

struct ServerCapabilities {
    PositionEncodingKind positionEncoding;
    NullableSum!(TextDocSyncOptions, TextDocSyncKind, EmptyObject) textDocumentSync;
    NullableSum!(NotebookDocSyncOpts, NotebookDocSyncRegOpts) notebookDocumentSync;
    Nullable!CompletionOpts completionProvider;
    NullableSum!(bool, HoverOpts) hoverProvider;
    Nullable!SignatureHelpOpts signatureHelpProvider;
    NullableSum!(DeclarationOpts, DeclarationRegOpts, bool) declarationProvider;
    NullableSum!(DefinitionOpts, bool) definitonProvider;
    NullableSum!(TypeDefOpts, TypeDefRegOpts, bool) typeDefinitionProvider;
    NullableSum!(ImplOpts, ImplRegOpts, bool) implementationProvider;
    NullableSum!(RefOpts, bool) referenceOptions;
    NullableSum!(DocHighlightOpts, bool) documentHighlightProvider;
    NullableSum!(DocSymbolOpts, bool) documentSymbolProvider;
    NullableSum!(CodeActionOpts, bool) codeActionProvider;
    NullableSum!(CodeLensOpts, bool) codeLensProvider;
    Nullable!DocLinkOpts documentLinkProvider;
    NullableSum!(DocColorOpts, DocColorRegOpts, bool) colorProvider;
    NullableSum!(DocFormatOpts, bool) documentFormattingProvider;
    NullableSum!(DocRangeFormatOpts, bool) documentRangeFormattingProvider;
    Nullable!(DocOnTypeFormatOpts) documentOnTypeFormattingProvider;
    NullableSum!(RenameOpts, bool) renameProvider;
    NullableSum!(FoldingRangeOpts, FoldingRangeRegOpts, bool) foldingRangeProvider;
    Nullable!(ExecOpts) executeCommandProvider;
    NullableSum!(SelectRangeOpts, SelectRangeRegOpts, bool) selectionRangeProvider;
    NullableSum!(LinkEditRangeOpts, LinkEditRangeRegOpts, bool) linkedEditingRangeProvider;
    NullableSum!(CallHierarchyOpts, CallHierarchyRegOpts, bool) callHierarchyProvider;
    NullableSum!(SemanticTokenOpts, SemanticTokenRegOpts) semanticTokensProvider;
    NullableSum!(MonikerOpts, MonikerRegOpts, bool) monikerProvider;
    NullableSum!(TypeHierarchyOpts, TypeHierarchyRegOpts, bool) typeHierarchyProvider;
    NullableSum!(InlineValueOpts, InlineValueRegOpts, bool) inlineValueProvider;
    NullableSum!(InlayHintOpts, InlayHintRegOpts, bool) inlayHintProvider;
    NullableSum!(DiagnosticOpts, DiagnosticRegOpts) diagonsticProvider;
    NullableSum!(WorkSpaceSymbolOpts, bool) workspaceSymbolProvider;
    Nullable!Workspace workspace;
    JSONValue experimental;

    struct TextDocSyncOptions {
        Nullable!bool openClose;
        Nullable!TextDocSyncKind change;
    }

    template inheritWDPOpts() {
        WorkDoneProgressOpts wdpOpts;
        alias workDoneProgress = wdpOpts.workDoneProgress;
    }

    template inheritSROpts() {
        StaticRegOpts srOpts;
        alias id = srOpts.id;
    }

    template inheritTDROpts() {
        TextDocRegOpts tdrOpts;
        alias documentSelector = tdrOpts.documentSelector;
    }

    struct WorkDoneProgressOpts {
        Nullable!bool workDoneProgress;
    }

    struct StaticRegOpts {
        Nullable!string id;
    }

    struct TextDocRegOpts {
        Nullable!(DocumentFilter[]) documentSelector; // Always appears
    }

    struct TripleOpts {
        mixin inheritSROpts;
        mixin inheritTDROpts;
        mixin inheritWDPOpts;
    }

    struct NotebookDocSyncOpts {
        NullableSum!(string, NBFilter) notebook;
        Nullable!(string[string]) cells;
        Nullable!bool save;

        struct NBFilter {
            Nullable!string notebookType, scheme, pattern;
            invariant {
                assert(!notebookType.isNull ||
                        !scheme.isNull ||
                        !pattern.isNull,
                    "NotebookFilter has all null fields");
            }
        }
    }

    struct NotebookDocSyncRegOpts {
        mixin inheritSROpts;
        NotebookDocSyncOpts nbDocSyncOpts;
        alias cells = nbDocSyncOpts.cells;
        alias save = nbDocSyncOpts.save;
        alias notebook = nbDocSyncOpts.notebook;
    }

    struct CompletionOpts {
        mixin inheritWDPOpts;
        Nullable!(string[]) triggerCharacters;
        Nullable!(string[]) allCommitCharacters;
        Nullable!bool resolveProvider;
        Nullable!CompletionItem completionItem;

        struct CompletionItem {
            Nullable!bool labelDetailsSupport;
        }
    }

    struct SignatureHelpOpts {
        mixin inheritWDPOpts;
        Nullable!(string[]) triggerCharacters;
        Nullable!(string[]) retriggerCharacters;
    }

    struct DocSymbolOpts {
        mixin inheritWDPOpts;
        Nullable!string label;
    }

    struct CodeActionOpts {
        mixin inheritWDPOpts;
        Nullable!(CodeActionKind[]) codeActionKinds;
        Nullable!bool resolveProvider;
    }

    struct CodeLensOpts {
        mixin inheritWDPOpts;
        Nullable!bool resolveProvider;
    }

    struct DocOnTypeFormatOpts {
        string firstTriggerCharacter;
        Nullable!(string[]) moreTriggerCharacters;
    }

    struct RenameOpts {
        mixin inheritWDPOpts;
        Nullable!bool prepareProvider;
    }

    struct ExecOpts {
        mixin inheritWDPOpts;
        string[] commands;
    }

    struct SemanticTokenOpts {
        mixin inheritWDPOpts;
        TokenLegend legend;
        NullableSum!(bool, EmptyObject) range;
        NullableSum!(bool, FullObject) full;

        struct TokenLegend {
            string[] tokenTypes, tokenModifiers;
        }

        struct FullObject {
            Nullable!bool delta;
        }
    }

    struct SemanticTokenRegOpts {
        mixin inheritSROpts;
        mixin inheritTDROpts;

        SemanticTokenOpts semTokOpts;
        alias legend = semTokOpts.legend;
        alias range = semTokOpts.range;
        alias full = semTokOpts.full;
        alias workDoneProgress = semTokOpts.wdpOpts.workDoneProgress;
    }

    struct MonikerRegOpts {
        mixin inheritWDPOpts;
        mixin inheritTDROpts;
    }

    struct InlayHintRegOpts {
        mixin inheritTDROpts;
        mixin inheritSROpts;

        InlayHintOpts inlayOpts;
        alias resolveProvider = inlayOpts.resolveProvider;
        alias workDoneProgess = inlayOpts.wdpOpts.workDoneProgress;
    }

    struct DiagnosticOpts {
        mixin inheritWDPOpts;
        Nullable!string identifier;
        bool interFileDependencies;
        bool workspaceDiagnostics;
    }

    struct DiagnosticRegOpts {
        mixin inheritSROpts;
        mixin inheritTDROpts;

        DiagnosticOpts diagnosticOpts;
        alias identifier = diagnosticOpts.identifier;
        alias interFileDependencies = diagnosticOpts.interFileDependencies;
        alias workspaceDiagnostics = diagnosticOpts.workspaceDiagnostics;
        alias workDoneProgress = diagnosticOpts.wdpOpts.workDoneProgress;
    }

    struct Workspace {
        Nullable!WSFolderServerCap workspaceFolders;

        struct FileOpts {
            Nullable!FileOpRegOpts didCreate, willCreate, 
                                   didRename, willRename,
                                   didDelete, willDelete;

            struct FileOpRegOpts {
                struct FileOpFilter {
                    Nullable!string scheme;
                    FileOpPattern pattern;

                    struct FileOpPattern {
                        string glob;
                        Nullable!FileOpPatternKind matches;
                        Nullable!FileOpPatternOpts options;

                        enum FileOpPatternKind : string {
                            file = "file",
                            folder = "folder"
                        }

                        struct FileOpPatternOpts {
                            Nullable!bool ignoreCase;
                        }
                    }
                }
            }
        }

        struct WSFolderServerCap {
            Nullable!bool supported;
            NullableSum!(string, bool) changeNotifications;
        }
    }

    alias HoverOpts = WorkDoneProgressOpts;
    alias RefOpts = WorkDoneProgressOpts;
    alias DocHighlightOpts = WorkDoneProgressOpts;
    alias DefinitionOpts = WorkDoneProgressOpts;
    alias DeclarationOpts = WorkDoneProgressOpts;
    alias TypeDefOpts = WorkDoneProgressOpts;
    alias ImplOpts = WorkDoneProgressOpts;
    alias DocColorOpts = WorkDoneProgressOpts;
    alias DocFormatOpts = WorkDoneProgressOpts;
    alias DocRangeFormatOpts = WorkDoneProgressOpts;
    alias FoldingRangeOpts = WorkDoneProgressOpts;
    alias SelectRangeOpts = WorkDoneProgressOpts;
    alias LinkEditRangeOpts = WorkDoneProgressOpts;
    alias CallHierarchyOpts = WorkDoneProgressOpts;
    alias MonikerOpts = WorkDoneProgressOpts;
    alias TypeHierarchyOpts = WorkDoneProgressOpts;
    alias InlineValueOpts = WorkDoneProgressOpts;

    alias ImplRegOpts = TripleOpts;
    alias DeclarationRegOpts = TripleOpts;
    alias TypeDefRegOpts = TripleOpts;
    alias DocColorRegOpts = TripleOpts;
    alias FoldingRangeRegOpts = TripleOpts;
    alias SelectRangeRegOpts = TripleOpts;
    alias LinkEditRangeRegOpts = TripleOpts;
    alias CallHierarchyRegOpts = TripleOpts;
    alias TypeHierarchyRegOpts = TripleOpts;
    alias InlineValueRegOpts = TripleOpts;

    alias DocLinkOpts = CodeLensOpts;
    alias InlayHintOpts = CodeLensOpts;
    alias WorkSpaceSymbolOpts = CodeLensOpts;

    struct EmptyObject {}
}
