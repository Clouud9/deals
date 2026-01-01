module common.visitors;
import protocol.base.types;
import common.denseset;

import dmd.visitor;
import dmd.ast_node;
import dmd.location;
import dmd.astcodegen;
import dmd.visitor.postorder;
import std.algorithm;
import std.math;
import dmd.dsymbolsem : include;
import dmd.rootobject;
import dmd.identifier;
import dmd.dmodule;

struct IdentifierAtLoc {
    Identifier ident;
    Loc loc;
}

/** 
 * ASTVisitor from VisualD, modified to support the modern DMD frontend
 */
extern(C++) class ASTVisitor : StoppableVisitor
{
	bool unconditional; // take both branches in conditional declarations/statements

	alias visit = StoppableVisitor.visit;

	DenseSet!ASTNode visited;

	void visitRecursive(T)(T node)
	{
		if (stop || !node || visited.contains(node))
			return;

		visited.insert(node);

		if (walkPostorder(node, this))
			stop = true;
	}

	void visitExpression(ASTCodegen.Expression expr)
	{
		visitRecursive(expr);
	}

	void visitStatement(ASTCodegen.Statement stmt)
	{
		visitRecursive(stmt);
	}

	void visitDeclaration(ASTCodegen.Dsymbol sym)
	{
		if (stop || !sym)
			return;

		sym.accept(this);
	}

	void visitParameter(ASTCodegen.Parameter p, ASTCodegen.Declaration decl)
	{
		visitType(p.type);
		visitExpression(p.defaultArg);
		if (p.userAttribDecl)
			visit(p.userAttribDecl);
	}

	// default to being permissive
	override void visit(ASTCodegen.Parameter p)
	{
		visitParameter(p, null);
	}
	override void visit(ASTCodegen.TemplateParameter) {}

	// expressions
	override void visit(ASTCodegen.Expression expr)
	{
		visitExpression(expr);
	}

	override void visit(ASTCodegen.ErrorExp errexp)
	{
		visit(cast(ASTCodegen.Expression)errexp);
	}

	override void visit(ASTCodegen.CastExp expr)
    {
        visitType(expr.to);
        super.visit(expr);
    }

	override void visit(ASTCodegen.IsExp ie)
	{
		// TODO: has ident
		if (ie.targ)
			ie.targ.accept(this);

		visit(cast(ASTCodegen.Expression)ie);
	}

	override void visit(ASTCodegen.DeclarationExp expr)
	{
		visitDeclaration(expr.declaration);
		visit(cast(ASTCodegen.Expression)expr);
	}

	override void visit(ASTCodegen.TypeExp expr)
	{
		visitType(expr.type);
		visit(cast(ASTCodegen.Expression)expr);
	}

	override void visit(ASTCodegen.FuncExp expr)
	{
		visitDeclaration(expr.fd);
		visitDeclaration(expr.td);

		visit(cast(ASTCodegen.Expression)expr);
	}

	override void visit(ASTCodegen.NewExp ne)
	{
		if (ne.member)
			ne.member.accept(this);

		if (ne.newtype)
			visitType(ne.newtype);

		super.visit(ne);
	}

	override void visit(ASTCodegen.ScopeExp expr)
	{
		if (auto ti = expr.sds.isTemplateInstance())
			visitTemplateInstance(ti);
		super.visit(expr);
	}

	override void visit(ASTCodegen.TraitsExp te)
	{
		if (te.args)
		{
			foreach(a; (*te.args)) {
				// Try type
                if (auto t = cast(ASTCodegen.Type)a)
                {
                    visitType(t);
                    continue;
                }

                // Try expression
                if (auto e = cast(ASTCodegen.Expression)a)
                {
                    visitExpression(e);
                    continue;
                }

                // Try symbol
                if (auto s = cast(ASTCodegen.Dsymbol)a)
                    continue;
            }
		}

		super.visit(te);
	}

	void visitTemplateInstance(ASTCodegen.TemplateInstance ti)
	{
		if (ti.tiargs)
		{
			size_t args = ti.tiargs.length;
			for (size_t a = 0; a < args; a++)
				if (ASTCodegen.Type tip = cast(ASTCodegen.Type)(*ti.tiargs)[a])
					visitType(tip);
		}
	}

	// types
	void visitType(ASTCodegen.Type type)
	{
		if (type)
			type.accept(this);
	}

	override void visit(ASTCodegen.Type t)
	{
	}

	override void visit(ASTCodegen.TypeSArray tsa)
	{
		visitExpression(tsa.dim);
		super.visit(tsa);
	}

	override void visit(ASTCodegen.TypeAArray taa)
	{
        visitType(taa.index);
        super.visit(taa);
	}

	override void visit(ASTCodegen.TypeNext tn)
	{
		visitType(tn.next);
		super.visit(tn);
	}

	override void visit(ASTCodegen.TypeTypeof t)
	{
		visitExpression(t.exp);
		super.visit(t);
	}

	// symbols
	override void visit(ASTCodegen.Dsymbol) {}

	override void visit(ASTCodegen.ScopeDsymbol scopesym)
	{
		super.visit(scopesym);

		// optimize to only visit members in approriate source range
		size_t mcnt = scopesym.members ? scopesym.members.length : 0;
		for (size_t m = 0; !stop && m < mcnt; m++)
		{
			ASTCodegen.Dsymbol s = (*scopesym.members)[m];
			s.accept(this);
		}
	}

	// declarations
	override void visit(ASTCodegen.VarDeclaration decl)
	{
		visitType(decl.type);
		if (decl.originalType != decl.type)
			visitType(decl.originalType);

		visit(cast(ASTCodegen.Declaration)decl);

		if (!stop && decl._init)
			decl._init.accept(this);
	}

	override void visit(ASTCodegen.AliasDeclaration ad)
	{
		visitType(ad.originalType);
		super.visit(ad);
	}

	override void visit(ASTCodegen.AliasAssign aa)
	{
		if (aa.type)
			visitType(aa.type);
		super.visit(aa);
	}

	override void visit(ASTCodegen.AttribDeclaration decl)
	{
		visit(cast(ASTCodegen.Declaration)decl);

		if (!stop)
		{
			if (unconditional)
			{
				if (decl.decl)
					foreach(d; *decl.decl)
						if (!stop)
							d.accept(this);
			}
			else if (auto inc = decl.include(null))
				foreach(d; *inc)
					if (!stop)
						d.accept(this);
		}
	}

	override void visit(ASTCodegen.UserAttributeDeclaration decl)
	{
		if (decl.atts)
			foreach(e; *decl.atts)
				visitExpression(e);

		super.visit(decl);
	}

	override void visit(ASTCodegen.ConditionalDeclaration decl)
	{
		if (!stop && decl.condition)
			decl.condition.accept(this);

		visit(cast(ASTCodegen.AttribDeclaration)decl);

		if (!stop && unconditional && decl.elsedecl)
			foreach(d; *decl.elsedecl)
				if (!stop)
					d.accept(this);
	}

	override void visit(ASTCodegen.FuncDeclaration decl)
	{
		visit(cast(ASTCodegen.Declaration)decl);

		// function declaration only
		if (auto tf = decl.type ? decl.type.isTypeFunction() : null)
		{
			if (tf.parameterList.parameters)
				foreach(i, p; *tf.parameterList.parameters)
					if (!stop)
					{
						if (decl.parameters && i < decl.parameters.length)
							visitParameter(p, (*decl.parameters)[i]);
						else
							p.accept(this);
					}
		}
		else if (decl.parameters)
		{
			foreach(p; *decl.parameters)
				if (!stop)
					p.accept(this);
		}

		if (decl.frequires)
			foreach(s; *decl.frequires)
				visitStatement(s);
		if (decl.fensures)
			foreach(e; *decl.fensures)
				visitStatement(e.ensure); // TODO: check result ident

		visitStatement(decl.frequire);
		visitStatement(decl.fensure);
		visitStatement(decl.fbody);
	}

	override void visit(ASTCodegen.ClassDeclaration cd)
	{
		if (cd.baseclasses)
			foreach (bc; *(cd.baseclasses))
				visitType(bc.type);

		super.visit(cd);
	}

	// condition
	override void visit(ASTCodegen.Condition) {}

	override void visit(ASTCodegen.StaticIfCondition cond)
	{
		visitExpression(cond.exp);
		visit(cast(ASTCodegen.Condition)cond);
	}

	// initializer
	override void visit(ASTCodegen.Initializer) {}

	override void visit(ASTCodegen.ExpInitializer einit)
	{
		visitExpression(einit.exp);
	}

	override void visit(ASTCodegen.VoidInitializer vinit)
	{
	}

	override void visit(ASTCodegen.ErrorInitializer einit)
	{
        // Unusre if using einit.accept(this) would loop continously or not
		//if (einit.original)
		//	einit.original.accept(this);
	}

	override void visit(ASTCodegen.StructInitializer sinit)
	{
		foreach (i, const id; sinit.field)
			if (auto iz = sinit.value[i])
				iz.accept(this);
	}

	override void visit(ASTCodegen.ArrayInitializer ainit)
	{
		foreach (i, ex; ainit.index)
		{
			if (ex)
				ex.accept(this);
			if (auto iz = ainit.value[i])
				iz.accept(this);
		}
	}

	// statements
	override void visit(ASTCodegen.Statement stmt)
	{
		if (stmt)
			visitStatement(stmt);
	}

	override void visit(ASTCodegen.ExpStatement stmt)
	{
		visitExpression(stmt.exp);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.ConditionalStatement stmt)
	{
		if (!stop && stmt.condition)
		{
			stmt.condition.accept(this);

			if (unconditional)
			{
				visitStatement(stmt.ifbody);
				visitStatement(stmt.elsebody);
			}
			else if (stmt.condition.include(null))
				visitStatement(stmt.ifbody);
			else
				visitStatement(stmt.elsebody);
		}
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.MixinStatement stmt)
	{
		if (stmt.exps)
			foreach(e; *stmt.exps)
				if (!stop)
					e.accept(this);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.WhileStatement stmt)
	{
		visitExpression(stmt.condition);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.DoStatement stmt)
	{
		visitExpression(stmt.condition);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.ForStatement stmt)
	{
		visitExpression(stmt.condition);
		visitExpression(stmt.increment);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.ForeachStatement stmt)
	{
		if (stmt.parameters)
			foreach(p; *stmt.parameters)
				if (!stop)
					p.accept(this);
		visitExpression(stmt.aggr);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.ForeachRangeStatement stmt)
	{
		if (!stop && stmt.param)
			stmt.param.accept(this);
		visitExpression(stmt.lwr);
		visitExpression(stmt.upr);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.IfStatement stmt)
	{
		// prm converted to DeclarationExp as part of condition
		//if (!stop && stmt.prm)
		//	stmt.prm.accept(this);
		visitExpression(stmt.condition);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.PragmaStatement stmt)
	{
		if (!stop && stmt.args)
			foreach(a; *stmt.args)
				if (!stop)
					a.accept(this);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.StaticAssertStatement stmt)
	{
		visitExpression(stmt.sa.exp);
		if (stmt.sa.msgs)
			foreach(e; *stmt.sa.msgs)
				visitExpression(e);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.SwitchStatement stmt)
	{
		visitExpression(stmt.condition);
		visit(cast(ASTCodegen.Statement)stmt);
		if (stmt.cases)
			foreach(s; *stmt.cases)
				visitStatement(s);
	}

	override void visit(ASTCodegen.CaseStatement stmt)
	{
		visitExpression(stmt.exp);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.CaseRangeStatement stmt)
	{
		visitExpression(stmt.first);
		visitExpression(stmt.last);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.GotoCaseStatement stmt)
	{
		visitExpression(stmt.exp);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.ReturnStatement stmt)
	{
		visitExpression(stmt.exp);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.SynchronizedStatement stmt)
	{
		visitExpression(stmt.exp);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.WithStatement stmt)
	{
		visitExpression(stmt.exp);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.TryCatchStatement stmt)
	{
		// variables not looked at by PostorderStatementVisitor
		if (!stop && stmt.catches)
			foreach(c; *stmt.catches)
			{
				if (c.var)
					visitDeclaration(c.var);
				else
					visitType(c.type);
			}

		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.ThrowStatement stmt)
	{
		visitExpression(stmt.exp);
		visit(cast(ASTCodegen.Statement)stmt);
	}

	override void visit(ASTCodegen.ImportStatement stmt)
	{
		if (!stop && stmt.imports)
			foreach(i; *stmt.imports)
				visitDeclaration(i);
		visit(cast(ASTCodegen.Statement)stmt);
	}
}

extern(C++) class FindASTVisitor : ASTVisitor
{
	const(char*) filename;
	int startLine;
	int startIndex;
	int endLine;
	int endIndex;

	alias visit = ASTVisitor.visit;
	RootObject found;
	ASTCodegen.ScopeDsymbol foundScope;

	this(const(char*) filename, int startLine, int startIndex, int endLine, int endIndex)
	{
		this.filename = filename;
		this.startLine = startLine;
		this.startIndex = startIndex;
		this.endLine = endLine;
		this.endIndex = endIndex;
	}

	void foundNode(RootObject obj)
	{
		if (obj)
		{
			found = obj;
			// do not stop until the scope is also set
		}
	}

	void checkScope(ASTCodegen.ScopeDsymbol sc)
	{
		if (found && sc && !foundScope)
		{
			foundScope = sc;
			stop = true;
		}
	}

	bool foundExpr(ASTCodegen.Expression expr)
	{
		if (auto se = expr.isScopeExp())
			foundNode(se.sds);
		else if (auto ve = expr.isVarExp())
			foundNode(ve.var);
		else if (auto te = expr.isTypeExp())
			foundNode(te.type);
		else
			return false;
		return true;
	}

	bool foundResolved(ASTCodegen.Expression expr)
	{
		if (!expr)
			return false;
		ASTCodegen.CommaExp ce;
		while ((ce = expr.isCommaExp()) !is null)
		{
			if (foundExpr(ce.e1))
				return true;
			expr = ce.e2;
		}
		return foundExpr(expr);
	}

	bool matchIdentifier(ref const Loc loc, Identifier ident)
	{
		if (ident)
			if (loc.filename is filename)
				if (loc.linnum == startLine && loc.linnum == endLine)
					if (loc.charnum <= startIndex && loc.charnum + ident.toString().length >= endIndex)
						return true;
		return false;
	}

	bool matchDotIdentifier(ref const Loc dotloc, ref const Loc loc, Identifier ident)
	{
		if (!dotloc.filename)
			return matchIdentifier(loc, ident);
		if (ident)
			if (loc.filename is filename)
				if (dotloc.linnum < startLine ||
					(dotloc.linnum == startLine && dotloc.charnum < startIndex))
					if ((loc.linnum == endLine && loc.charnum + ident.toString().length >= endIndex) ||
						loc.linnum > endLine)
						return true;
		return false;
	}

    // TODO: Reimplement for goto's later
    /*
	extern(D) bool visitPackages(ASTCodegen.Module mod, Identifier[] packages)
	{
		if (!mod || !packages)
			return false;

		Package pkg = mod.parent ? mod.parent.isPackage() : null;
		for (size_t p; pkg && p < packages.length; p++)
		{
			size_t q = packages.length - 1 - p;
            // Identifiers don't have loc, so replacing packages[q].loc with pkg.loc
			if (!found && matchIdentifier(pkg.loc, packages[q] /+ packages[q].ident +/ ))
			{
				foundNode(pkg);
				return true;
			}
			pkg = pkg.parent ? pkg.parent.isPackage() : null;
		}
		return false;
	}
    */

	bool matchLoc(ref const(Loc) loc, int len)
	{
		if (loc.filename is filename)
			if (loc.linnum == startLine && loc.linnum == endLine)
				if (loc.charnum <= startIndex && loc.charnum + len >= endIndex)
					return true;
		return false;
	}

	override void visit(ASTCodegen.Dsymbol sym)
	{
		if (sym.isFuncLiteralDeclaration())
			return;
		if (!found && matchIdentifier(sym.loc, sym.ident))
			foundNode(sym);
	}

	override void visit(ASTCodegen.StaticAssert sa)
	{
		visitExpression(sa.exp);
		if (sa.msgs)
			foreach(e; *sa.msgs)
				visitExpression(e);
		super.visit(sa);
	}

	override void visitParameter(ASTCodegen.Parameter sym, ASTCodegen.Declaration decl)
	{
		super.visitParameter(sym, decl);
		if (!found && matchIdentifier(sym.loc, sym.ident))
			foundNode(decl ? decl : sym);
	}

	override void visit(ASTCodegen.Module mod)
	{
		if (mod.md)
		{
			//visitPackages(mod, mod.md.packages);

			if (!found && matchIdentifier(mod.md.loc, mod.md.id))
				foundNode(mod);
		}
		visit(cast(Package)mod);
	}

	override void visit(ASTCodegen.Import imp)
	{
		// visitPackages(imp.mod, imp.packages);

		if (!found && matchIdentifier(imp.loc, imp.id))
			foundNode(imp.mod);

        /* TODO: Do later for goto's
		for (int n = 0; !found && n < imp.names.length && n < imp.aliasdecls.length; n++)
			if (matchIdentifier(imp.names[n].loc, imp.names[n].ident) ||
				matchIdentifier(imp.aliases[n].loc, imp.aliases[n].ident))
				foundNode(imp.aliasdecls[n]);
        */

		// symbol has ident of first package, so don't forward
	}

	override void visit(ASTCodegen.DVCondition cond)
	{
		if (!found && matchIdentifier(cond.loc, cond.ident))
			foundNode(cond);
	}

	override void visit(ASTCodegen.AliasAssign aa)
	{
		if (!found && matchIdentifier(aa.loc, aa.ident))
			foundNode(aa);
		if (aa.type)
			super.visit(aa);
		if (aa.aliassym)
			super.visit(aa.aliassym);
	}

	override void visit(ASTCodegen.Expression expr)
	{
		super.visit(expr);
	}

	override void visit(ASTCodegen.CompoundStatement cs)
	{
		// optimize to only visit members in approriate source range
		size_t scnt = cs.statements ? cs.statements.length : 0;
		for (size_t i = 0; i < scnt && !stop; i++)
		{
			ASTCodegen.Statement s = (*cs.statements)[i];
			if (!s)
				continue;
			if (visited.contains(s))
				continue;

			if (s.loc.filename)
			{
				if (s.loc.filename !is filename || s.loc.linnum > endLine)
					continue;
				Loc endloc = endLocation(s);
				if (endloc.filename && endloc.linnum < startLine)
					continue;
			}
			s.accept(this);
		}
		visit(cast(ASTCodegen.Statement)cs);
	}

	override void visit(ASTCodegen.ScopeDsymbol scopesym)
	{
		// optimize to only visit members in approriate source range
		// unfortunately, some members don't have valid locations
		size_t mcnt = scopesym.members ? scopesym.members.length : 0;
		for (size_t m = 0; m < mcnt && !stop; m++)
		{
			ASTCodegen.Dsymbol s = (*scopesym.members)[m];
			if (s.isTemplateInstance)
				continue;
			if (s.loc.filename)
			{
				if (s.loc.filename !is filename || s.loc.linnum > endLine)
					continue;
				Loc endloc;
				if (auto fd = s.isFuncDeclaration())
					endloc = fd.endloc;
				if (endloc.filename && endloc.linnum < startLine)
					continue;
			}
			s.accept(this);
		}
		checkScope(scopesym);
	}

	override void visit(ASTCodegen.ScopeStatement ss)
	{
		visit(cast(ASTCodegen.Statement)ss);
		//checkScope(ss.scopesym);
	}

	override void visit(ASTCodegen.ForStatement fs)
	{
		visit(cast(ASTCodegen.Statement)fs);
		//checkScope(fs.scopesym);
	}

	override void visit(ASTCodegen.TemplateInstance ti)
	{
		// skip members added by semantic
		visit(cast(ASTCodegen.ScopeDsymbol)ti);
	}

	override void visit(ASTCodegen.TemplateDeclaration td)
	{
		if (!found && td.ident)
			if (matchIdentifier(td.loc, td.ident))
				foundNode(td);

		foreach(ti; td.instances)
			if (!stop)
				visit(ti);

		visit(cast(ASTCodegen.ScopeDsymbol)td);
	}

	override void visitTemplateInstance(ASTCodegen.TemplateInstance ti)
	{
		if (!found && ti.name)
			if (matchIdentifier(ti.loc, ti.name))
				foundNode(ti);

		super.visitTemplateInstance(ti);
	}

	override void visit(ASTCodegen.CallExp expr)
	{
		super.visit(expr);
	}

	override void visit(ASTCodegen.SymbolExp expr)
	{
		if (!found && expr.var)
			if (matchIdentifier(expr.loc, expr.var.ident))
				foundNode(expr);
		super.visit(expr);
	}

	override void visit(ASTCodegen.IdentifierExp expr)
	{
		if (!found && expr.ident)
		{
			if (matchIdentifier(expr.loc, expr.ident))
			{
				if (expr.type)
					foundNode(expr.type);
				else if (expr.resolvedTo)
					foundResolved(expr.resolvedTo);
			}
		}
		visit(cast(ASTCodegen.Expression)expr);
	}

	override void visit(ASTCodegen.DotIdExp de)
	{
		if (!found)
			if (de.ident)
				if (matchDotIdentifier(de.dotloc, de.identloc, de.ident))
				{
					if (!de.type && de.resolvedTo && !de.resolvedTo.isErrorExp())
						foundResolved(de.resolvedTo);
					else
						foundNode(de);
				}
	}

	override void visit(ASTCodegen.DotExp de)
	{
		if (!found)
		{
			// '.' of erroneous DotIdExp
			if (matchLoc(de.loc, 2))
				foundNode(de);
		}
		super.visit(de);
	}

	override void visit(ASTCodegen.DotTemplateExp dte)
	{
		if (!found && dte.td && dte.td.ident)
			if (matchIdentifier(dte.identloc, dte.td.ident))
				foundNode(dte);
		super.visit(dte);
	}

	override void visit(ASTCodegen.TemplateExp te)
	{
		if (!found && te.td && te.td.ident)
			if (matchIdentifier(te.identloc, te.td.ident))
				foundNode(te);
		super.visit(te);
	}

	override void visit(ASTCodegen.DotVarExp dve)
	{
		if (!found && dve.var && dve.var.ident)
			if (matchIdentifier(dve.varloc.filename ? dve.varloc : dve.loc, dve.var.ident))
				foundNode(dve);
	}

	override void visit(ASTCodegen.EnumDeclaration ed)
	{
		if (!found && ed.ident)
			if (matchIdentifier(ed.loc, ed.ident))
				foundNode(ed);

		visit(cast(ASTCodegen.ScopeDsymbol)ed);
	}

	override void visit(ASTCodegen.AggregateDeclaration ad)
	{
		if (!found && ad.ident)
			if (matchIdentifier(ad.loc, ad.ident))
				foundNode(ad);

		visit(cast(ASTCodegen.ScopeDsymbol)ad);
	}

	override void visit(ASTCodegen.FuncDeclaration decl)
	{
		super.visit(decl);

		checkScope(decl.scopesym);

		visitType(decl.originalType);
	}

	override void visit(ASTCodegen.TypeQualified tq)
	{
		foreach (i, id; tq.idents)
		{
			RootObject obj = id;
			if (obj.dyncast() == DYNCAST.identifier)
			{
				auto ident = cast(Identifier)obj;
				if (matchIdentifier(id.loc, ident))
					if (tq.parentScopes.dim > i + 1)
						foundNode(tq.parentScopes[i + 1]);
			}
		}
		super.visit(tq);
	}

	override void visit(ASTCodegen.TypeIdentifier otype)
	{
		if (found)
			return;

		for (ASTCodegen.TypeIdentifier ti = otype; ti; ti = ti.copiedFrom)
			if (ti.parentScopes.dim)
			{
				otype = ti;
				break;
			}

		if (matchIdentifier(otype.loc, otype.ident))
		{
			if (otype.parentScopes.dim > 0)
				foundNode(otype.parentScopes[0]);
			else
				foundNode(otype);
		}
		super.visit(otype);
	}

	override void visit(ASTCodegen.TypeInstance ti)
	{
		if (found)
			return;

		for (ASTCodegen.TypeInstance cti = ti; cti; cti = cti.copiedFrom)
			if (cti.parentScopes.dim)
			{
				ti = cti;
				break;
			}

		if (ti.tempinst && matchIdentifier(ti.loc, ti.tempinst.name))
		{
			if (ti.parentScopes.dim > 0)
				foundNode(ti.parentScopes[0]);
			return;
		}
		visitTemplateInstance(ti.tempinst);
		super.visit(ti);
	}
}

Loc endLocation(ASTCodegen.Statement s)
{
	Loc endloc;
	if (auto ss = s.isScopeStatement())
		endloc = ss.endloc;
	else if (auto ws = s.isWhileStatement())
		endloc = ws.endloc;
	else if (auto ds = s.isDoStatement())
		endloc = ds.endloc;
	else if (auto fs = s.isForStatement())
		endloc = fs.endloc;
	else if (auto fs = s.isForeachStatement())
		endloc = fs.endloc;
	else if (auto fs = s.isForeachRangeStatement())
		endloc = fs.endloc;
	else if (auto ifs = s.isIfStatement())
		endloc = ifs.endloc;
	else if (auto ws = s.isWithStatement())
		endloc = ws.endloc;
	return endloc;
}