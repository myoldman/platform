local setmetatable = setmetatable
local type = type
local ngx = ngx

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self)
    return setmetatable({}, mt)
end

function set_userinfo(username)
	username = username or ngx.var.username
    local userinfo = "username="..username
    local userinfo_base64 = ngx.encode_base64(userinfo)
    ngx.req.set_header("userinfo", userinfo_base64)
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
