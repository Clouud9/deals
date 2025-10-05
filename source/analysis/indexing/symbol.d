module analysis.indexing.symbol;

alias SymbolID = ulong;

// May add or eliminate types later
enum Type {Function, Struct, Class, Template, Enum, Basic, Interface, Union, Mixin, Alias, Module}

enum Visibility {Private, Public, Protected}

class Symbol {
    Type type;
    SymbolID id;
    Symbol[] members; // For Classes, Structs, Enums, Interfaces
    string name; // For debugging (may include just to have though)
    string module_name; // Do I need? 
    string documentation;
    string full_signature;
}

struct IndexEntry {
    Symbol[] search(string name) {
        return null;
    }
    
    SymbolID[] import_ids;
    Symbol[SymbolID] top_level_symbols;

    // May be more advanced than I need
    SymbolID[][string] symbols_by_name;

    // TODO: Add References & Relations later
}