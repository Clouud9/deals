module common.serialization;
import protocol.base;
import std.traits;
import std.typecons;
import std.sumtype;
import protocol.capabilities.server;
import common.hipjson;
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
if (is(T == void)) {
    return JSONValue(null);
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
if ((is(T == struct) || is(T == class)) &&
    !isInstanceOf!(Optional, T)         &&
    !isInstanceOf!(Nullable, T)         &&
    !isInstanceOf!(SumType, T)          &&
    !is(T == JSONValue)                 &&
    !is(T == interface)
) {
    JSONValue json = JSONValue.emptyObject;
    alias fields = FieldNameTuple!T;
    static foreach(string field_name; FieldNameTuple!T) {{
        auto field_val = __traits(getMember, value, field_name);
        alias FieldType = typeof(field_val);

        static if (isPointerToSumType!FieldType || isPointerToJSONValue!FieldType) {
            if (field_val != null) 
                json[field_name.strip("_")] = serialize(*field_val);
        } else static if (isInstanceOf!(Optional, FieldType)) {
            if (!field_val.isNull)
                json[field_name.strip("_")] = serialize(field_val);
        } else
            json[field_name.strip("_")] = serialize(field_val);
    }}

    return json;
}

template isPointerToSumType(T) {
    static if (isPointer!T) {
        enum isPointerToSumType = is(PointerTarget!T : SumType!Args, Args...);
    } else {
        enum isPointerToSumType = false;
    }
}

template isPointerToJSONValue(T) {
    static if (isPointer!T) {
        enum isPointerToJSONValue = is(PointerTarget!T : JSONValue);
    } else {
        enum isPointerToJSONValue = false;
    }
}

// Template to get all nested classes in an interface
template getNestedClasses(T) if (is(T == interface)) {
    import std.meta : Filter;
    
    template isNestedClass(string name) {
        enum isNestedClass = is(__traits(getMember, T, name) == class);
    }
    
    alias getNestedClasses = Filter!(isNestedClass, __traits(allMembers, T));
}

JSONValue serialize(T)(T value) 
if (is(T == interface)) {
    JSONValue json = JSONValue.emptyObject;
    
    // Try to cast to each nested class and serialize if successful
    static foreach (className; getNestedClasses!T) {
        {
            alias ClassType = __traits(getMember, T, className);
            if (auto castedValue = cast(ClassType)value) {
                // Serialize all fields of the concrete class
                static foreach (fieldName; FieldNameTuple!ClassType) {
                    json[fieldName] = serializeValue(__traits(getMember, castedValue, fieldName));
                }
                
                return json; // Early return once we find the right type
            }
        }
    }
    
    // If we get here, the cast failed for all types
    json["__error"] = JSONValue("Unknown concrete type");
    return json;
}