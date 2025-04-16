module protocol.base.types;

enum FoldingRangeType : string {
    Comment = "comment",
    Imports = "imports",
    Region = "region"
}

enum SymbolKind {
	File = 1,
	Module = 2,
	Namespace = 3,
	Package = 4,
	Class = 5,
	Method = 6,
	Property = 7,
	Field = 8,
	Constructor = 9,
	Enum = 10,
	Interface = 11,
	Function = 12,
	Variable = 13,
	Constant = 14,
	String = 15,
	Number = 16,
	Boolean = 17,
	Array = 18,
	Object = 19,
	Key = 20,
	Null = 21,
	EnumMember = 22,
	Struct = 23,
	Event = 24,
	Operator = 25,
	TypeParameter = 26
}

enum PrepSupportDefaultBehavior {
    Identifier = 1
}

enum SymbolTag {
    Supported,
    Deprecated
}

enum TraceValue : string {
    Off = "off",
    Messages = "messages",
    Verbose = "verbose"
}

struct WorkspaceFolder {
    string uri, name;
}

enum DiagnosticTag {
    Unnecessary = 1,
    Deprecated = 2
}

enum MarkupKind {
    Plaintext,
    Markdown
}

enum InsertTextMode {
    As_Is = 1,
    Adjust_Indentation = 2
}

enum CompletionItemTag {
    Supported,
    Deprecated
}

enum CompletionItemType {
    Text = 1,
    Method,
    Function,
    Constructor,
    Field,
    Variable,
    Class,
    Interface,
    Module,
    Property,
    Unit,
    Value,
    Enum,
    Keyword,
    Snippet,
    Color,
    File,
    Reference,
    Folder,
    EnumMember,
    Constant,
    Struct,
    Event,
    Operator,
    TypeParameter
}

enum CodeActionKind : string {
    Empty = " ",
    QuickFix = "quickfix",
    Refactor = "refactor",
    RefactorExtract = "refactor.extract",
    RefactorInline = "refactor.inline",
    RefactorRewrite = "refactor.rewrite",
    Source = "source",
    SourceOrganizeImports = "source.organizeImports",
    SourceFixAll = "source.fixAll"
}

enum TokenFormat : string {
    Relative = "relative"
}

enum PositionEncodingKind : string {
    utf8  = "utf-8",
    utf16 = "utf-16",
    utf32 = "utf-32"
}

enum TextDocSyncKind : int {
    None = 0, 
    Full = 1,
    Incremental = 2
}