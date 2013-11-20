local setmetatable = setmetatable
local type = type
local ngx = ngx
local error = error
local string = string

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self)
    return setmetatable({}, mt)
end

function set_cookie(username)
    ngx.log(ngx.INFO,"setting cookie for username " .. username)
	local expires = ngx.cookie_time(4523969511)
 	ngx.header["Set-Cookie"] = {"username=" .. username .."; expires=" .. expires .. "; Path=/"}
end

function get_cookie()
	local t = {}
    if ngx.var.http_cookie then
    	local s = ngx.var.http_cookie
        for k, v in string.gmatch(s, "(%w+)=([%w%/%.=_-]+)") do
			t[k] = v
        end
 	end
 	return t
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
