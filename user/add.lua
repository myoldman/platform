local setmetatable = setmetatable
local type = type
local ngx = ngx
local require = require
local print = print
local string = string

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self)
    return setmetatable({}, mt)
end

function service_process()
    local error_process_module = require "log.error_processor"
    local error_processor = error_process_module:new()
    local method = ngx.req.get_method()
    if method ~= "POST" then
        error_processor:generel_error_process({"http_method_mismatch"})
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
