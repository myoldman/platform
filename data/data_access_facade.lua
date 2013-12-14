
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
	return accessor:getFlowControl(appKey)
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)