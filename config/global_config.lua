

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

require "config.error_message_map"

local flow_control_map = {
	["/foo"] =  10,
	["/bar"] =  20
}

local authorize_need_map = {
	["/foo"] = false,
	["/bar"] = true
}

local user_authorization_map = {
	["liuhong"] = { ["/bar"] = true },
	["test"] = {"/bar", "/helloworld"}
}


local mysql_host = "61.154.164.33"
local mysql_port = 8020
local mysql_database = "siddb"
local mysql_user =  "sid"
local mysql_password = "sid"
local max_packet_size = 1024 * 1024


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)