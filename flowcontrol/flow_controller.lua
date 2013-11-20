local setmetatable = setmetatable
local type = type
local ngx = ngx
local flow_control_map = flow_control_map

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self)
    return setmetatable({}, mt)
end

local function incr(dict, key, increment)
	increment = increment or 1
	local newval , err = dict:incr(key, increment)
	if not newval and err == "not found" then
    dict:add(key, 0, 1) -- expire for 1s for flow control --
 		newval, err = dict:incr(key, increment)
 	end
 	return newval
end

function check_flowcontrol()
	local uri = ngx.var.uri
   	local current_qps = ngx.shared.flow_control.get(ngx.shared.flow_control, uri)
   	local max_qps = flow_control_map[uri] or 0
   	if qps and qps > max_qps then
    	return false
    end
    return true
end

function incr_flowcontrol()
	local key = ngx.var.uri
	incr(ngx.shared.flow_control, key , 1)
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
