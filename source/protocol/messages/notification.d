module protocol.messages.notification;
import protocol.messages.message;
import common.hipjson;

mixin template Notification() {
    string method;
    Optional!JSONValue params = JSONValue.init;
}

