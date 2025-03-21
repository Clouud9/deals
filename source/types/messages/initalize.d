module types.messages.initalize;
import types.messages.request;
import std.json;

// TODO: Check for valid types
bool init_is_init_request(JSONValue json) {
    if (json["method"].str == "initalize")
        return true;
    else return false;
}

// Not Root JSON, need to get params if they exist and then go.
bool init_is_valid_request(JSONValue json) {
    JSONValue params = request_get_params(json);
    if (init_is_init_request(json) == false)
        return false;
    else if ("processID" !in params)
        return false;
    else if ("rootURI" !in params)
        return false;
    else if ("capabilities" !in params)
        return false;
    else return true;
}

bool init_has_client_info(JSONValue json) {
    JSONValue params = request_get_params(json);
    if ("clientInfo" in params) 
        return true;
    else return false;
}

bool init_has_client_version(JSONValue json) {
    JSONValue params = request_get_params(json);
    if (init_has_client_info(json) == false) 
        return false;

    JSONValue clientInfo = params["clientInfo"].object;
    if ("version" !in clientInfo) 
        return false;
    else return true;
}

bool init_has_locale(JSONValue json) {
    JSONValue params = request_get_params(json);
    if ("locale" !in params)
        return false;
    else return true;
}

bool init_has_root_path(JSONValue json) {
    JSONValue params = request_get_params(json);
    if ("rootPath" !in params)
        return false;
    else return true;
}

bool init_has_init_options(JSONValue json) {
    JSONValue params = request_get_params(json);
    if ("initializationOptions" !in params) 
        return false;
    else return true;
}

bool init_has_trace(JSONValue json) {
    JSONValue params = request_get_params(json);
    if ("trace" !in params) 
        return false;
    else return true;
}

// TODO: Move to own section?
bool work_progress_params_has_token(JSONValue json) {
    JSONValue params = request_get_params(json);
    if ("workDoneToken" !in json)
        return true;
    else return false;
}