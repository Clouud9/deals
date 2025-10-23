module protocol.messages.notification;
import protocol.messages.message;
import hip.data.json;

mixin template Notification() {
    string method;
    Optional!JSONValue params = JSONValue.init;
}

