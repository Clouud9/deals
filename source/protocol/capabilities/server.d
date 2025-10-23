module protocol.capabilities.server;
import protocol.base;
import std.typecons;
import std.sumtype;
import std.traits;
import hip.data.json;
import core.stdc.stdlib;

struct ServerCapabilities {
    Optional!PositionEncodingKind positionEncoding;
    Optional!TextDocSync textDocumentSync; // Change back to textDocSync after adding UDA support to declare what a thing should be serialized to 
    Optional!NotebookDocSync notebookDocumentSync;
    Optional!CompletionOpts completionProvider;
    Optional!HoverProvider hoverProvider;
    Optional!SignatureHelpOpts signatureHelpProvider;
    Optional!DeclProvider declarationProvider;
    Optional!DefProvider definitonProvider;
    Optional!TypeDefProvider typeDefinitionProvider;
    Optional!ImplProvider implementationProvider;
    Optional!RefProvider referenceOptions;
    Optional!DocHighlightProvider documentHighlightProvider;
    Optional!DocSymbolProvider documentSymbolProvider;
    Optional!CodeActionProvider codeActionProvider;
    Optional!CodeLensProvider codeLensProvider;
    Optional!DocLinkOpts documentLinkProvider;
    Optional!DocColorProvider colorProvider;
    Optional!DocFormatProvider documentFormattingProvider;
    Optional!DocRangeFormatProvider documentRangeFormattingProvider;
    Optional!DocOnTypeFormatOpts documentOnTypeFormattingProvider;
    Optional!RenameProvider renameProvider;
    Optional!FoldingRangeProvider foldingRangeProvider;
    Optional!ExecOpts executeCommandProvider;
    Optional!SelectionRangeProvider selectionRangeProvider;
    Optional!LinkedEditRangeProvider linkedEditingRangeProvider;
    Optional!CallHierarchyProvider callHierarchyProvider;
    Optional!SemanticTokenProvider semanticTokensProvider;
    Optional!MonikerProvider monikerProvider;
    Optional!TypeHierarchyProvider typeHierarchyProvider;
    Optional!InlineValueProvider inlineValueProvider;
    Optional!InlayHintProivder inlayHintProvider;
    Optional!DiagnosticProvider diagonsticProvider;
    Optional!WorkspaceSymbolProvider workspaceSymbolProvider;
    Optional!ServerWorkspace workspace;
    Optional!JSONValue experimental;

    // TODO: Start here and move down
    struct TextDocSyncOptions {
        Optional!bool openClose;
        Optional!TextDocSyncKind change;
    }

    template inheritWDPOpts() {
        Optional!bool workDoneProgress;
    }

    template inheritSROpts() {
        Optional!string id;
    }

    template inheritTDROpts() {
        alias DocumentSelector = DocumentFilter[];
        Nullable!(DocumentSelector) documentSelector; // Always appears
    }

    struct WorkDoneProgressOpts {
        Optional!bool workDoneProgress;
    }

    struct StaticRegOpts {
        Optional!string id;
    }

    struct TextDocRegOpts {
        alias DocumentSelector = DocumentFilter[];
        Nullable!(DocumentSelector) documentSelector; // Always appears
    }

    struct TripleOpts {
        mixin inheritSROpts;
        mixin inheritTDROpts;
        mixin inheritWDPOpts;
    }
    
    struct NotebookDocSyncOptions {
        Selector[] notebookSelector;
        Optional!bool save;

        alias Selector = SumType!(NotebookSelector, CellSelector);
        alias NotebookDocumentFilter = SumType!(NotebookFilter, SchemeFilter, PatternFilter);
        alias Notebook = SumType!(string, NotebookDocumentFilter);

        struct NotebookFilter {string notebookType; Optional!string scheme; Optional!string pattern;}
        struct SchemeFilter   {Optional!string notebookType; string scheme; Optional!string pattern;}
        struct PatternFilter  {Optional!string notebookType; Optional!string scheme; string pattern;}

        struct CellStruct { string language; }
        struct NotebookSelector {
            Notebook notebook;
            Optional!(CellStruct[]) cells;
        }

        struct CellSelector {
            Optional!Notebook notebook;
            CellStruct[] cells;
        }
    }

    struct NotebookDocSyncRegOptions {
        mixin inheritSROpts;
        NotebookDocSyncOptions syncOptions;
        alias save = syncOptions.save;
        alias notebookSelector = syncOptions.notebookSelector;
    }

    struct CompletionOpts {
        mixin inheritWDPOpts;
        Optional!(string[]) triggerCharacters;
        Optional!(string[]) allCommitCharacters;
        Optional!bool resolveProvider;
        Optional!CompletionItem completionItem;

        struct CompletionItem {
            Optional!bool labelDetailsSupport;
        }
    }

    struct SignatureHelpOpts {
        mixin inheritWDPOpts;
        Optional!(string[]) triggerCharacters;
        Optional!(string[]) retriggerCharacters;
    }

    struct DocSymbolOpts {
        mixin inheritWDPOpts;
        Optional!string label;
    }

    struct CodeActionOpts {
        mixin inheritWDPOpts;
        Optional!(CodeActionKind[]) codeActionKinds;
        Optional!bool resolveProvider;
    }

    struct CodeLensOpts {
        mixin inheritWDPOpts;
        Optional!bool resolveProvider;
    }

    struct DocOnTypeFormatOpts {
        string firstTriggerCharacter;
        Optional!(string[]) moreTriggerCharacters;
    }

    struct RenameOpts {
        mixin inheritWDPOpts;
        Optional!bool prepareProvider;
    }

    struct ExecOpts {
        mixin inheritWDPOpts;
        string[] commands;
    }

    struct SemanticTokenOpts {
        mixin inheritWDPOpts;
        TokenLegend legend;
        Optional!Range range;
        Optional!Full full;

        alias Range = SumType!(bool, EmptyObject);
        alias Full  = SumType!(bool, FullObject);

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
        alias workDoneProgress = semTokOpts.workDoneProgress;
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
        alias workDoneProgess = inlayOpts.workDoneProgress;
    }

    struct DiagnosticOpts {
        mixin inheritWDPOpts;
        Optional!string identifier;
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
        alias workDoneProgress = diagnosticOpts.workDoneProgress;
    }

    struct ServerWorkspace {
        Optional!WSFolderServerCap workspaceFolders;
        Optional!FileOperations fileOperations;

        struct FileOperations {
            Optional!FileOpRegOpts didCreate, willCreate, 
                                   didRename, willRename,
                                   didDelete, willDelete;

            struct FileOpRegOpts {
                struct FileOpFilter {
                    Optional!string scheme;
                    FileOpPattern pattern;

                    struct FileOpPattern {
                        string glob;
                        Optional!FileOpPatternKind matches;
                        Optional!FileOpPatternOpts options;

                        enum FileOpPatternKind : string {
                            file = "file",
                            folder = "folder"
                        }

                        struct FileOpPatternOpts {
                            Optional!bool ignoreCase;
                        }
                    }
                }
            }
        }

        struct WSFolderServerCap {
            Optional!bool supported;
            Optional!ChangeNotifications changeNotifications;

            alias ChangeNotifications = SumType!(string, bool);
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

    alias TextDocSync = SumType!(TextDocSyncOptions, TextDocSyncKind);
    alias NotebookDocSync = SumType!(NotebookDocSyncOptions, NotebookDocSyncRegOptions);
    alias HoverProvider = SumType!(bool, HoverOpts);
    alias DeclProvider = SumType!(DeclarationOpts, DeclarationRegOpts, bool);
    alias DefProvider = SumType!(DefinitionOpts, bool);
    alias TypeDefProvider = SumType!(TypeDefOpts, TypeDefRegOpts, bool);
    alias ImplProvider = SumType!(ImplOpts, ImplRegOpts, bool);
    alias RefProvider = SumType!(RefOpts, bool);
    alias DocHighlightProvider = SumType!(DocHighlightOpts, bool);
    alias DocSymbolProvider = SumType!(DocSymbolOpts, bool);
    alias CodeActionProvider = SumType!(CodeActionOpts, bool);
    alias CodeLensProvider = SumType!(CodeLensOpts, bool);
    alias DocColorProvider = SumType!(DocColorOpts, DocColorRegOpts, bool);
    alias DocFormatProvider = SumType!(DocFormatOpts, bool);
    alias DocRangeFormatProvider = SumType!(DocRangeFormatOpts, bool);
    alias RenameProvider = SumType!(RenameOpts, bool);
    alias FoldingRangeProvider = SumType!(FoldingRangeOpts, FoldingRangeRegOpts, bool);
    alias SelectionRangeProvider = SumType!(SelectRangeOpts, SelectRangeRegOpts, bool);
    alias LinkedEditRangeProvider = SumType!(LinkEditRangeOpts, LinkEditRangeRegOpts, bool);
    alias CallHierarchyProvider = SumType!(CallHierarchyOpts, CallHierarchyRegOpts, bool);
    alias SemanticTokenProvider = SumType!(SemanticTokenOpts, SemanticTokenRegOpts);
    alias MonikerProvider = SumType!(MonikerOpts, MonikerRegOpts, bool);
    alias TypeHierarchyProvider = SumType!(TypeHierarchyOpts, TypeHierarchyRegOpts, bool);
    alias InlineValueProvider = SumType!(InlineValueOpts, InlineValueRegOpts, bool);
    alias InlayHintProivder = SumType!(InlayHintOpts, InlayHintRegOpts, bool);
    alias DiagnosticProvider = SumType!(DiagnosticOpts, DiagnosticRegOpts);
    alias WorkspaceSymbolProvider = SumType!(WorkSpaceSymbolOpts, bool);
}

alias TextDocSync = ServerCapabilities.TextDocSync;
alias NotebookDocSync = ServerCapabilities.NotebookDocSync;
alias HoverProvider = ServerCapabilities.HoverProvider;
alias DeclProvider = ServerCapabilities.DeclProvider;
alias DefProvider = ServerCapabilities.DefProvider;
alias TypeDefProvider = ServerCapabilities.TypeDefProvider;
alias ImplProvider = ServerCapabilities.ImplProvider;
alias RefProvider = ServerCapabilities.RefProvider;
alias DocHighlightProvider = ServerCapabilities.DocHighlightProvider;
alias DocSymbolProvider = ServerCapabilities.DocSymbolProvider;
alias CodeActionProvider = ServerCapabilities.CodeActionProvider;
alias CodeLensProvider = ServerCapabilities.CodeLensProvider;
alias DocColorProvider = ServerCapabilities.DocColorProvider;
alias DocFormatProvider = ServerCapabilities.DocFormatProvider;
alias DocRangeFormatProvider = ServerCapabilities.DocRangeFormatProvider;
alias RenameProvider = ServerCapabilities.RenameProvider;
alias FoldingRangeProvider = ServerCapabilities.FoldingRangeProvider;
alias SelectionRangeProvider = ServerCapabilities.SelectionRangeProvider;
alias LinkedEditRangeProvider = ServerCapabilities.LinkedEditRangeProvider;
alias CallHierarchyProvider = ServerCapabilities.CallHierarchyProvider;
alias SemanticTokenProvider = ServerCapabilities.SemanticTokenProvider;
alias MonikerProvider = ServerCapabilities.MonikerProvider;
alias TypeHierarchyProvider = ServerCapabilities.TypeHierarchyProvider;
alias InlineValueProvider = ServerCapabilities.InlineValueProvider;
alias InlayHintProivder = ServerCapabilities.InlayHintProivder;
alias DiagnosticProvider = ServerCapabilities.DiagnosticProvider;
alias WorkspaceSymbolProvider = ServerCapabilities.WorkspaceSymbolProvider;