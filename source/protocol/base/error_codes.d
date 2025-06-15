module protocol.base.error_codes;

alias Error = Errors;
// TODO: Add & Format Error Code Documentation
enum Errors : long {
    ParseError     = -32_700,
    InvalidRequest = -32_600,
    MethodNotFound = -32_601,
    InvalidParams  = -32_602,
    InternalError  = -32_603,

    // JSON-RPC Reserved Error Codes Below
    jsonrpcReservedErrorRangeStart = -32_099,
    serverErrorStart = jsonrpcReservedErrorRangeStart, // Deprecated

    /**
     * Server Receieved Notification before initalize request
     */
    ServerNotInitialized = -32_002,
    UnknownErrorCode     = -32_001,

    jsonrpcReservedErrorRangeEnd = -32_000,
    serverErrorEnd = jsonrpcReservedErrorRangeEnd, // Deprecated

    /** 
     *  LSP Reserved Error Codes Below
     */
    lspReservedErrorRangeStart = -32_899,

    /**
     *  Request Failed but was syntactically correct.
     */
    RequestFailed = -32_803,

    ServerCancelled = -32_802,

    ContentModified = -32_801,

    RequestCancelled = -32_800,

    lspReservedErrorRangeEnd = -32_800
}
