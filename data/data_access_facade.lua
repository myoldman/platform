
local setmetatable = setmetatable
local type = type
local ngx = ngx
local require = require

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self, accessor_name)
	local module_str =  "data." .. accessor_name .. "_data_accessor"
	local accessor_module = require(module_str)
	local accessor = accessor_module:new()
    return setmetatable({ accessor = accessor }, mt)
end

function getAppByAppKey(self, appKey)
	local accessor = self.accessor
	return accessor:getAppByAppKey(appKey)
end

function getFlowControl(self)
	local accessor = self.accessor
	return accessor:getFlowControl()
end

function addUserInfo(self, username, mobilephone, password, user_uuid, timestamp)
	local accessor = self.accessor
	return accessor:addUserInfo(username, mobilephone, password, user_uuid, timestamp)
end

function delUserInfoByUsername(self, username)
	local accessor = self.accessor
	return accessor:delUserInfoByUsername(username)
end

function delUserInfoByMobilephone(self, mobilephone)
	local accessor = self.accessor
	return accessor:delUserInfoByMobilephone(mobilephone)
end

function delUserInfoByUUID(self, user_uuid)
	local accessor = self.accessor
	return accessor:delUserInfoByUUID(user_uuid)
end

function getUserInfoByMobilePhone(self, mobilephone)
	local accessor = self.accessor
	return accessor:getUserInfoByMobilePhone(mobilephone)
end

function getUserInfoByUserName(self, username)
	local accessor = self.accessor
	return accessor:getUserInfoByUserName(username)
end

function addUserToken(self, user_uuid, token)
	local accessor = self.accessor
	return accessor:addUserToken(user_uuid, token)
end

function getTokenInfoByToken(self, token)
	local accessor = self.accessor
	return accessor:getTokenInfoByToken(token)
end



local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)