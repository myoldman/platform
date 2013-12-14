local setmetatable = setmetatable
local type = type
local ngx = ngx
local global_config = require("global_config")

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self)
    return setmetatable({}, mt)
end

function is_authorize_needed()
	local uri = ngx.var.uri
	ngx.log(ngx.INFO, " check whether uri " .. uri .. " need authorization")
	return global_config.authorize_need_map[uri] or false
end

function authorization(username)
	ngx.log(ngx.INFO, "authentication with user " .. username .. " uri " .. ngx.var.uri)

	local user_authorizations = global_config.user_authorization_map[username]
	if user_authorizations == nil then
		return false
	end

	if user_authorizations[ngx.var.uri] == nil then
		return false
	end

	return true
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
