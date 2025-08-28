module analysis.hover;

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
import std.stdio;
import dmd.globals;

Position* findIdentifierAt(ref State state, Position pos, string uri) {
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
                stderr.write(token.toString());
                return new Position(token.loc.linnum, token.loc.charnum);
            }
        }

    }

    return null;
}

extern (C++) class IdentifierVisitor(AST) : ParseTimeTransitiveVisitor!AST {
    alias visit = ParseTimeTransitiveVisitor!AST.visit;
    Position position;
    bool stop = false;

    this(Position pos) {
        this.position = pos;
    }

    override void visit(AST.Module m) {
        foreach (s; *m.members) {
            if (stop)
                break;
            else
                s.accept(this);
        }
    }

    override void visit(AST.TemplateExp t) {

    }

    override void visit(AST.CallExp c) {

    }

    override void visit(AST.VarExp v) {

    }

    override void visit(AST.DotIdExp d) {

    }

    override void visit(AST.DotTemplateInstanceExp d) {

    }
}

extern (C++) class HoverVisitor : SemanticTimeTransitiveVisitor {
    Position position;
    char* uri;

    this(Position pos, char* uri) {
        this.position = pos;
        this.uri = uri;
    }

    alias visit = SemanticTimeTransitiveVisitor.visit;

    override void visit(ASTCodegen.Module m) {
        foreach (s; *m.members)
            s.accept(this);
    }

    override void visit(ASTCodegen.Expression e) {
        if (e.type !is null)
            stderr.write(e.toString() ~ ": " ~ e.type.kind()
                    .toDString() ~ ": " ~ e.loc.filename().toDString());

        import core.time, core.thread;

        Thread.sleep(msecs(5)); // Makes it so that newline isn't ignored 
    }
}
