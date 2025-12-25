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
import dmd.ast_node;
import std.string;
import std.regex.internal.parser;

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
extern (C++) class HoverVisitor : SemanticTimePermissiveVisitor {
    const Position position;
    char* uri;
    bool stop = false;
    ASTNode node;
    string doc_string;
    Position newPos;

    this(Position pos, char* uri) {
        this.position = pos;
        this.uri = uri;
        newPos = position;
    }

    alias visit = SemanticTimePermissiveVisitor.visit; 

    override void visit(ASTCodegen.Module m) {
        if (stop)
            return;
            
        if (m.members) {
            foreach (s; *m.members) {
                if (stop)
                    return;
                s.accept(this);
            }
        }
    }

    override void visit(ASTCodegen.VarDeclaration vd) {
        if (!vd.ident.toString().endsWith("__initZ"))
            log("VAR DECL " ~ vd.ident.toString());
    }

    // TODO: Parameter Hovering
    override void visit(ASTCodegen.FuncDeclaration fd) {
        log("FUNC DECL " ~ fd.ident.toString());
        fd.fbody.accept(this);
    }

    override void visit(ASTCodegen.IfStatement ifs) {
        log("IF STMT " ~ ifs.loc.linnum().to!string ~ " " ~ ifs.loc.charnum().to!string);

        ifs.condition.accept(this);

        if (!ifs.ifbody.isScopeStatement())
            newPos.line++;

        ifs.ifbody.accept(this);

        if (ifs.elsebody) {
            ifs.elsebody.accept(this);
            if (!ifs.elsebody.isScopeStatement())
                newPos.line++;
        }
    }

    // While Statement is lowered into a for statement 
    override void visit(ASTCodegen.ForStatement fs) {
        log("FOR STMT " ~ fs.loc.linnum.to!string ~ " " ~ fs.loc.charnum.to!string);
        fs.condition.accept(this);

        if (!fs._body.isScopeStatement())
            newPos.line++;

        fs._body.accept(this);
    }

    override void visit(ASTCodegen.ForeachStatement fes) {
        log("FOREACH STMNT");
        fes.key.accept(this);
        fes.value.accept(this);

        if (!fes._body.isScopeStatement())
            newPos.line++;

        fes._body.accept(this);
    }

    override void visit(ASTCodegen.ForeachRangeStatement fers) {
        fers.key.accept(this);

        if (!fers._body.isScopeStatement())
            newPos.line++;

        fers._body.accept(this);
    }

    override void visit(ASTCodegen.WhileStatement ws) {
        log("WHILE STMT");
        ws.condition.accept(this);

        if (!ws._body.isScopeStatement()) {
            log("NON-SCOPE WHILE BODY");
            newPos.line++;
        }

        ws._body.accept(this);
    }  

    override void visit(ASTCodegen.DoStatement ds) {
        ds.condition.accept(this);

         if (!ds._body.isScopeStatement())
            newPos.line++;

        ds._body.accept(this);
    }

    // Inside of a function body is a CompoundStatement
    override void visit(ASTCodegen.CompoundStatement cs) {
        log("CMPND STMNT");
        foreach (statement; *(cs.statements))
            statement.accept(this);
    }

    override void visit(ASTCodegen.ScopeStatement ss) {
        log("SCOPE STMNT");
        ss.statement.accept(this);
    }

    // Visit statements to find expressions within them
    override void visit(ASTCodegen.ExpStatement es) {
        if (stop)
            return;
            
        log("EXP STATEMENT");
        if (es.exp) {
            checkExpression(es.exp);
        }

        es.exp.accept(this);
    }

    override void visit(ASTCodegen.ErrorExp ee) {
        log("ERROR EXP");
    }

    override void visit(ASTCodegen.CallExp ce) {
        if ((cast(Dsymbol) ce).matchesPosition(newPos)) {
            doc_string = ce.f.comment().to!string;
            stop = true;
        }

        if (ce.arguments) {
            foreach(arg; *(ce.arguments)) {
                arg.accept(this);
            }
        }
    }

    override void visit(ASTCodegen.AssignExp ae) {
        log("ASSIGN EXP");
        ae.e1.accept(this);
        ae.e2.accept(this);
    }

    override void visit(ASTCodegen.VarExp ve) {
        log("VAR EXP");
        auto se = cast(SymbolExp) ve;
        log("VAR EXP: " ~ se.loc.linnum.to!string ~ " " ~ se.loc.charnum.to!string);
    }

    override void visit(ASTCodegen.DotVarExp dve) {
        import std.string;
        log("DOT VAR EXP " ~ dve.toString().to!string ~ " " ~ dve.loc.linnum().to!string ~ " " ~ dve.loc.charnum().to!string);
        dve.e1.accept(this);
        log("A IDX " ~ (dve.toString().to!string).indexOf(".").to!string);
        dve.var.accept(this);
    }

    override void visit(ASTCodegen.Expression e) {
        if (auto declExp = e.isDeclarationExp())
            declExp.accept(this);
    }

    // TODO: Check if other declaration types exist
    override void visit(ASTCodegen.DeclarationExp de) {
        log("DECL EXPS");
        if (auto vd = de.declaration.isVarDeclaration()) {
            log("DECL EXP: VAR DECL " ~ vd.ident.toString());
            if (containsLoc(vd)) {
                if (auto ts = vd.type.isTypeStruct()) {
                    doc_string = ts.sym.comment().to!string;
                    stop = true;
                } else if (auto tc = vd.type.isTypeClass()) {
                    doc_string = tc.sym.comment().to!string;
                } else if (auto te = vd.type.isTypeEnum()) {
                    doc_string = te.sym.comment().to!string;
                }
            }
        }
    }
    
    void checkExpression(ASTCodegen.Expression e) {
        log("EXPRESSION");
        if (auto dv = e.isDotVarExp()) {
            if ((cast(Dsymbol) dv).matchesPosition(newPos)) {
                log("DOTVAR MATCH!");
                node = dv;
                stop = true;
                return;
            }
            
            // Check both sides of the dot expression
            if (dv.e1) {
                checkExpression(dv.e1);
            }
        }
        // Add checks for other expression types as needed
    }

    bool containsLoc(ASTCodegen.VarDeclaration vd) {
        if (auto ti = vd.originalType ? vd.originalType.isTypeIdentifier() : null)
            if ((cast(Dsymbol) ti).matchesPosition(newPos)) return true;
        
        return (cast(Dsymbol) vd).matchesPosition(newPos);
    }
}

bool matchesPosition(Dsymbol sym, immutable Position pos) {
    if (!sym)
        return false;
    return (sym.loc.linnum == pos.line && sym.loc.charnum == pos.character);
}

bool matchesPosition(Loc loc, immutable Position pos) {
    return (loc.linnum == pos.line && loc.charnum == pos.character);
}