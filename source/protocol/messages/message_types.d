module protocol.messages.message_types;
import protocol.base.types;
import common.hipjson;
import std.sumtype;
import std.variant;

interface RPCType {}

interface Request {}
interface Notification {}
interface Response {}

class Message {
    string jsonrpc = "2.0";
}

class RequestMessage(T) : Message, Request {
    SumType!(int, string) id;
    string method;
    Optional!T params;
}

class ResponseMessage(T) : Message, Response {
    SumType!(int, string, void) id;
    Optional!T result;
    Optional!ResponseError error;
}

class NotificationMessage(T) : Message, Notification {
    string method;
    Optional!T params;
}

interface ResponseError {}
class Error_Code(T) : ResponseError {
    long code;
    string message;
    Optional!T data;
}