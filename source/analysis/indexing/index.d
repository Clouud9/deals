module analysis.indexing.index;
import analysis.indexing.symbol;

abstract class Index {
    abstract void find(FuzzyFindRequest request, void delegate(immutable(Symbol)[]) callback) {}
    abstract void lookup(LookupRequest request, void delegate(immutable(Symbol)[]) callback) {}
    abstract void refs(RefsRequest request, void delegate(immutable(Symbol)[]) callback) {}
    abstract void containedRefs(ContainedRefsRequest request, void delegate(immutable(Symbol)[]) callback) {}
    abstract void relations(RelationsRequest request, void delegate(immutable(Symbol)[]) callback) {}
}

final class ActiveIndex : Index {
    IndexEntry[string] entries_by_module;

    override void find(FuzzyFindRequest request, void delegate(immutable(Symbol)[]) callback) {}
    override void lookup(LookupRequest request, void delegate(immutable(Symbol)[]) callback) {}
    override void refs(RefsRequest request, void delegate(immutable(Symbol)[]) callback) {}
    override void containedRefs(ContainedRefsRequest request, void delegate(immutable(Symbol)[]) callback) {}
    override void relations(RelationsRequest request, void delegate(immutable(Symbol)[]) callback) {}
}

final class GroupIndex : Index {

}

struct FuzzyFindRequest {

}

struct LookupRequest {

}

struct RefsRequest {

}

struct ContainedRefsRequest {

}

struct RelationsRequest {

}