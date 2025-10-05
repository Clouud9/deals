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
        }
        else {
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
        if (vd.loc.linnum == position.line &&
            vd.loc.charnum == position.character
        ) {
            sym = vd;
            stop = true;
        }
    }

    /*
    override void visit(ASTCodegen.Dsymbol s) {
        stderr.write("SYMBOL VISIT " ~ s.ident.toString());
        if (s.loc.linnum == position.line &&
            s.loc.charnum == position.character
        ) {
            sym = s;
            stop = true;
        }
    }

    override void visit(ASTCodegen.ScopeDsymbol ss) {
        stderr.rawWrite("Scope Symbol Vist");
        foreach (member; *ss.members) {
            if (ss.loc.linnum == position.line &&
                ss.loc.charnum == position.character
            ) {
                sym = ss;
                stop = true;
            }
        }
    }

    override void visit(ASTCodegen.VarDeclaration vd) {
        if (vd.ident !is null)
            //stderr.write(vd.ident.toString());

        Thread.sleep(5.msecs);
    }

    override void visit(ASTCodegen.FuncDeclaration fd) {
        stderr.rawWrite("FUNC " ~ fd.ident.toString());
        if (fd.type && fd.type.isTypeFunction()) {
            auto tf = fd.type.isTypeFunction();
            
        }

        fd.fbody.accept(this);
    }

    override void visit(ASTCodegen.IfStatement s) {
        stderr.rawWrite("IF STATEMENT");
    }

    override void visit(ASTCodegen.Parameter p) {
        stderr.rawWrite("PARAM VISIT");
        if (p.ident !is null) 
            stderr.write(p.ident.toString());
        Thread.sleep(5.msecs);
    }
    */

    /*
    override void visit(ASTCodegen.Expression e) {
        if (e.type !is null)
            stderr.write(e.toString() ~ ": " ~ e.type.kind()
                    .toDString() ~ ": " ~ e.loc.filename().toDString());

        import core.time, core.thread;

        Thread.sleep(msecs(5)); // Makes it so that newline isn't ignored 
    }
    */
}

extern (C++) class IdentifierVisitor : SemanticTimeTransitiveVisitor {
    alias visit = SemanticTimeTransitiveVisitor.visit;

    override void visit(ASTCodegen.Module m) {
        if (m.members) {
            foreach (Dsymbol s; *m.members) {
                if (!s.isModule() && !s.isAnonymous())
                    s.accept(this);
            }
        }
    }

    override void visit(ASTCodegen.FuncDeclaration fd) {
        logf("%s %d", fd.ident.toString(), fd.ident.getValue());
        foreach(pair; fd.localsymtab.tab.asRange()) {
            auto s = pair.value; 
            logf("%s %d", s.ident.toString(), s.ident.getValue());
        }
    }

    override void visit(ASTCodegen.VarDeclaration vd) {
        logf("%s %d", vd.ident.toString(), vd.ident.getValue());
    }
}