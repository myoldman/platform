

local require = require
local setmetatable = setmetatable

module("global_config")

_VERSION = '0.1'

local mt = { __index = _M }

flow_control_map = {
	["init"] = false,
	["/foo"] =  10,
	["/bar"] =  20
}

authorize_need_map = {
	["/foo"] = false,
	["/bar"] = true
}

user_authorization_map = {
	["liuhong"] = { ["/bar"] = true },
	["test"] = {"/bar", "/helloworld"}
}


error_server_busy = "server is busy now, please retry later"
error_call_threshold_over = "call_threshold over"
error_point_not_enough = "point not enough"
error_app_id_empty = "app_id should not be empty"
error_access_token_empty ="access_token should not be empty"
error_timestamp_empty ="timestamp should not be empty"
error_timestamp_format_error ="timestamp should be yyyy-MM-dd HH:mm:ss"
error_timestamp_expired ="timestamp expired"
error_sign_empty ="checksum of sign field empty"
error_sign_error ="checksum of sign field error"
error_api_not_exist = "api[%s] not exist"
error_app_not_exist = "request app [%s] not exist"
error_app_status_invalid = "request app [%s] not online or testing"
error_api_ability_empy = "ability list not exit"
error_api_app_not_associated = "api and app not associated"
error_access_token_invalid = "request app [%s] ACCESS_TOKEN [%s] not valid"
error_access_token_access_deny = "request app [%s] ACCESS_TOKEN [%s] access deny"
error_access_token_expired = "request app [%s] ACCESS_TOKEN [%s] expired"
error_http_method_mismatch = "http request method mismatch"
error_mobilephone_empty = "mobil phone number empty"
error_password_empty = "mobil phone number empty"

error_message_map = {
	["general"] = {
		error_in_header = false,
		server_busy = "{\"ret\" : 503,\"msg\" : \""..error_server_busy.."\"}",
		call_threshold_over = "{\"ret\" : 503,\"msg\" : \""..error_call_threshold_over.."\"}",
		point_not_enough = "{\"ret\" : 503,\"msg\" : \""..error_point_not_enough.."\"}",
		app_id_empty = "{\"ret\" : 1,\"msg\" : \""..error_app_id_empty.."\"}",
		access_token_empty = "{\"ret\" : 1,\"msg\" : \""..error_access_token_empty.."\"}",
		timestamp_empty = "{\"ret\" : 1,\"msg\" : \""..error_timestamp_empty.."\"}",
		timestamp_format_error = "{\"ret\" : 1,\"msg\" : \""..error_timestamp_format_error.."\"}",
		timestamp_expired = "{\"ret\" : 1,\"msg\" : \""..error_timestamp_expired.."\"}",
		sign_empty = "{\"ret\" : 1,\"msg\" : \""..error_sign_empty.."\"}",
		sign_error = "{\"ret\" : 1,\"msg\" : \""..error_sign_error.."\"}",
		api_not_exist = "{\"ret\" : 1,\"msg\" : \""..error_api_not_exist.."\"}",
		app_not_exist = "{\"ret\" : 1,\"msg\" : \""..error_app_not_exist.."\"}",
		app_status_invalid = "{\"ret\" : 1,\"msg\" : \""..error_app_status_invalid.."\"}",
		api_ability_empy = "{\"ret\" : 1,\"msg\" : \""..error_api_ability_empy.."\"}",
		api_app_not_associated = "{\"ret\" : 1,\"msg\" : \""..error_api_app_not_associated.."\"}",
		access_token_invalid = "{\"ret\" : 110,\"msg\" : \""..error_access_token_invalid.."\"}",
		access_token_access_deny = "{\"ret\" : 110,\"msg\" : \""..error_access_token_access_deny.."\"}",
		access_token_expired = "{\"ret\" : 110,\"msg\" : \""..error_access_token_expired.."\"}",
		http_method_mismatch = "{\"ret\" : 105,\"msg\" : \""..error_http_method_mismatch.."\"}",
		mobile_phone_empty = "{\"ret\" : 105,\"msg\" : \""..error_mobilephone_empty.."\"}",
		password_empty = "{\"ret\" : 105,\"msg\" : \""..error_password_empty.."\"}"
	}
}

mysql_host = "202.109.211.109"
mysql_port = 3306
mysql_database = "test"
mysql_user =  "test"
mysql_password = "ffcsbapd"
max_packet_size = 1024 * 1024


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)