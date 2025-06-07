module protocol.base.serialization;
import protocol.base;
import std.traits;
import std.typecons;
import std.sumtype;
import protocol.capabilities.server;
import hipjson;
import std.string;
import std.meta;

JSONValue serialize(T)(T value) 
if (is(T : long) && !is(T == enum) && !isBoolean!T) {
    return JSONValue(value);
}

JSONValue serialize(T)(T value) 
if (isInstanceOf!(SumType, T)) {
    return value.match!serialize;
}

JSONValue serialize(T)(T value)
if (is(T : long) && is(T == enum)) {
    return JSONValue(value);
}

JSONValue serialize(T)(T value) 
if (is(T : bool) || isBoolean!T) {
    return JSONValue(value);
}

JSONValue serialize(T)(T value) 
if (isArray!T && 
    !is(T == string) && 
    !is(T == enum)
) {
    JSONValue json = JSONValue.emptyArray;
    foreach (val; value) 
        json ~= serialize(val);
    return json;
}

JSONValue serialize(T)(T value) 
if (isInstanceOf!(Optional, T) ||
    isInstanceOf!(Nullable, T)
) {
    if (!value.isNull)
        return serialize(value.get);
    else 
        return JSONValue(null);
}

JSONValue serialize(T)(T value)
if (is(T == JSONValue)) {
    return value;
}

JSONValue serialize(T)(T value)
if (is(T : string)) {
    return JSONValue(value);
}

JSONValue serialize(T)(T value) 
if (is(T == struct) &&
    !isInstanceOf!(Optional, T) &&
    !isInstanceOf!(Nullable, T) &&
    !isInstanceOf!(SumType, T)  &&
    !is(T == JSONValue)
) {
    JSONValue json = JSONValue.emptyObject;
    alias fields = FieldNameTuple!T;
    static foreach(string field_name; FieldNameTuple!T) {{
        auto field_val = __traits(getMember, value, field_name);
        alias FieldType = typeof(field_val);

        static if (isInstanceOf!(Optional, FieldType)) {
            if (!field_val.isNull)
                json[field_name.strip("_")] = serialize(field_val);
        } else
            json[field_name.strip("_")] = serialize(field_val);
    }}

    return json;
}