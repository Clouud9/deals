module messages.notification;
import messages.message;

import std.typecons;
import mir.serde;
import std.variant;

class Notification : Message {
    string method;

    //@serdeOptional
    //Nullable!Variant params;
}
