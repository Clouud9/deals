module analysis.hover;

import core.memory;
import dmd.visitor;
import dmd.dsymbol;
import dmd.expression;
import dmd.declaration;
import dmd.astcodegen;
import dmd.dmodule;
import dmd.root.string;
import std.stdio;
import protocol.base;
import std.conv : to;
import dmd.expressionsem;
import dmd.visitor.permissive;
import dmd.visitor.parsetime;
import dmd.visitor.transitive;
import std.typecons;
import dmd.location;
import analysis.state;
import dmd.identifier;
import dmd.astbase;
import dmd.errorsink;
import dmd.parse;
import dmd.lexer;
import std.string;
import dmd.tokens;
import dmd.globals;
import std.typetuple;
import dmd.identifier;
import core.time, core.thread;
import std.algorithm;
import std.logger;
import dmd.astenums;

static this() {
    auto file = File("deals.log", "w"); // change to a in production
    sharedLog = cast(shared) new FileLogger(file);
}

Tuple!(Identifier, "ident", Loc, "loc")* findIdentifierAt(ref State state, Position pos, string uri) {
    Lexer lexer = new Lexer(
        uri.to!(char[]).ptr, // const(char)* filename
        state.documents[uri].toStringz, // const(char)* base  
        0, // ulong begoffset
        state.documents[uri].length, // ulong endoffset
        true, // bool doDocComment
        true, // bool commentToken
        false, // bool whitespaceToken
        new ErrorSinkNull(), // ErrorSink errorSink
        &global.compileEnv // const(CompileEnv*) compileEnv  
        
    );

    Token token;
    while (token.value != TOK.endOfFile) {
        lexer.scan(&token);

        string tokenText;
        if (token.value == TOK.identifier && token.ident) {
            tokenText = token.ident.toString().to!string;
        } else {
            continue;
        }

        if (token.loc.linnum == (pos.line + 1)) {
            uint tokenStart = token.loc.charnum;
            uint tokenEnd = tokenStart + cast(uint) tokenText.length;
            uint cursorPos = cast(uint)(pos.character + 1); // Adjust for 0/1-based indexing

            // Check if cursor is WITHIN the token bounds
            if (cursorPos >= tokenStart && cursorPos <= tokenEnd) {
                //stderr.write(token.toString());
                // auto final_pos = new Position(token.loc.linnum, token.loc.charnum);
                Loc loc = token.loc;
                Identifier ident = token.ident;
                return new Tuple!(Identifier, "ident", Loc, "loc")(ident, loc);
            }
        }

    }

    return null;
}

/**
 * TODO: The HoverVisitor should only find the location of the Hover target, not the source of the symbol.
 * The found symbol should be processed in order to find the source symbol (i.e. the one with the info we want to know about)
 */
extern (C++) class HoverVisitor : SemanticTimeTransitiveVisitor {
    Position position;
    char* uri;
    bool stop = false;
    Dsymbol sym;

    this(Position pos, char* uri) {
        this.position = pos;
        this.uri = uri;
    }

    alias visit = SemanticTimeTransitiveVisitor.visit;

    /** 
     * Only local checks for now, likely don't need them
     *  since types contain references to their parent modules anyways
     */
    override void visit(ASTCodegen.Module m) {
        if (m.members) {
            foreach (s; *m.members) {
                if (stop)
                    return;

                if (!s.isModule() && !s.isAnonymous())
                    s.accept(this);
            }
        }
    }

    /** 
     * For Class, Enum, Interface, etc. types found in parameters,
     *  and for identifiers inside of the function
     */
    override void visit(ASTCodegen.FuncDeclaration fd) {
        if (fd.parameters) {
            foreach (p; *fd.parameters) {
                if (stop)
                    return;
                p.accept(this);
            }
        }

        fd.fbody.accept(this);
    }

    override void visit(ASTCodegen.VarDeclaration vd) {
        // For when the Type is the hover target
        if (auto ti = vd.originalType ? vd.originalType.isTypeIdentifier() : null) {
            if ((cast(Dsymbol) ti).matchesPosition(position)) {
                
            }
        }

        // For when the variable name is the hover target (Why would this be a thing? IDK.)
    }

    override void visit(ASTCodegen.Expression e) {
        // May put this at the end if binary/other expressions could get triggered like this
        if ((cast(Dsymbol) e).matchesPosition(position)) {
            int derefCount;

            if (auto varDecl = e.expToVariable(derefCount)) {
                sym = varDecl;
                stop = true;
            }
        } else if (auto binExp = e.isBinExp()) {
            binExp.e1.accept(this);
            binExp.e2.accept(this);
        } else if (auto assignExp = e.isAssignExp()) {
            assignExp.e1.accept(this);
            assignExp.e2.accept(this);
        } else if (auto unExp = e.isUnaExp()) {
            unExp.e1.accept(this);
        }
    }
}

bool matchesPosition(Dsymbol sym, immutable Position pos) {
    if (!sym)
        return false;
    return (sym.loc.linnum == pos.line && sym.loc.charnum == pos.character);
}

// Add parameter for specific response format
string buildHoverResponse(Dsymbol sym) {
    switch (sym.dsym) {
    case DSYM.funcDeclaration:
        return "Function Declaration";
    case DSYM.aggregateDeclaration:
        return "Aggregate Declaration";
    case DSYM.varDeclaration:
        return "Var Declaration";
    case DSYM.enumDeclaration:
        return "Enum Declaration";
    case DSYM.structDeclaration:
        return "Struct Declaration";
    default:
        return "";
    }

    return "";
}
