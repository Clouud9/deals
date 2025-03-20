module types.messages.notification;
import types.messages.message;

import std.typecons;
import mir.serde;
import std.variant;
import mir.algebraic;

struct Notification {
    mixin MessageType;
    string method;

    @serdeOptional
    @serdeIgnoreOutIf!((Nullable!(string, int) s) => s.isNull)
    Nullable!(string, int) params;
}
