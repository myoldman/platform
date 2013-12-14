

local require = require
local setmetatable = setmetatable

module("global_config")

_VERSION = '0.1'

local mt = { __index = _M }

require "config.error_message_map"

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

error_message_map = {
	["general"] = {
		error_in_header = false,
		server_busy = "{\"res_code\" : 503,\"res_message\" : \""..error_server_busy.."\"}",
		call_threshold_over = "{\"res_code\" : 503,\"res_message\" : \""..error_call_threshold_over.."\"}",
		point_not_enough = "{\"res_code\" : 503,\"res_message\" : \""..error_point_not_enough.."\"}",
		app_id_empty = "{\"res_code\" : 1,\"res_message\" : \""..error_app_id_empty.."\"}",
		access_token_empty = "{\"res_code\" : 1,\"res_message\" : \""..error_access_token_empty.."\"}",
		timestamp_empty = "{\"res_code\" : 1,\"res_message\" : \""..error_timestamp_empty.."\"}",
		timestamp_format_error = "{\"res_code\" : 1,\"res_message\" : \""..error_timestamp_format_error.."\"}",
		timestamp_expired = "{\"res_code\" : 1,\"res_message\" : \""..error_timestamp_expired.."\"}",
		sign_empty = "{\"res_code\" : 1,\"res_message\" : \""..error_sign_empty.."\"}",
		sign_error = "{\"res_code\" : 1,\"res_message\" : \""..error_sign_error.."\"}",
		api_not_exist = "{\"res_code\" : 1,\"res_message\" : \""..error_api_not_exist.."\"}",
		app_not_exist = "{\"res_code\" : 1,\"res_message\" : \""..error_app_not_exist.."\"}",
		app_status_invalid = "{\"res_code\" : 1,\"res_message\" : \""..error_app_status_invalid.."\"}",
		api_ability_empy = "{\"res_code\" : 1,\"res_message\" : \""..error_api_ability_empy.."\"}",
		api_app_not_associated = "{\"res_code\" : 1,\"res_message\" : \""..error_api_app_not_associated.."\"}",
		access_token_invalid = "{\"res_code\" : 110,\"res_message\" : \""..error_access_token_invalid.."\"}",
		access_token_access_deny = "{\"res_code\" : 110,\"res_message\" : \""..error_access_token_access_deny.."\"}",
		access_token_expired = "{\"res_code\" : 110,\"res_message\" : \""..error_access_token_expired.."\"}"
	}
}

mysql_host = "61.154.164.33"
mysql_port = 8020
mysql_database = "siddb"
mysql_user =  "sid"
mysql_password = "sid"
max_packet_size = 1024 * 1024


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)