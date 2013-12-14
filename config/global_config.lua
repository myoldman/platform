

local require = require
local setmetatable = setmetatable

module("global_config")

_VERSION = '0.1'

local mt = { __index = _M }

require "config.error_message_map"

flow_control_map = {
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