local setmetatable = setmetatable
local type = type
local ngx = ngx
local require = require
local print = print

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self)
    return setmetatable({}, mt)
end

function save_user_behavior(username)
	if username ~= nil then
		ngx.var.username = username
	end
end

function send_user_behavior_log(username)
	 local logger = require "resty.logger.socket"
	 if not logger.initted() then
        local ok, err = logger.init{
                        host = '127.0.0.1',
                        port = 514
       	}
        if not ok then
        ngx.log(ngx.ERR, "failed to initialize the logger: ", err)
        	return
       	end
    end
    print("log to syslog-ng")
    local ok, err = logger.log("openresty:" .. username .. "|" .. ngx.var.uri)
		if not ok then
			ngx.log(ngx.ERR, "failed to log the message: ", err)
        return
    end
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
