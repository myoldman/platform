local ngx = ngx
local string = string
local print = print
local split = split
local os = os
local setmetatable = setmetatable
local global_config = require("global_config")

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

--output log to errors.log
function oupput_error_log(uri, error_message)
	ngx.log(ngx.ERR, string.format("uri %s error: %s", uri, error_message))
end


--output error to both client and error.log when authentication error
function output_error_message(error_message)
	local args = ngx.req.get_uri_args()
	local headers = ngx.req.get_headers()
	ngx.ctx.is_error = true
	ngx.say(error_message)
	oupput_error_log(ngx.var.uri, error_message)
end

-- funtion to create module table
function new(self)
	return setmetatable({}, mt)
end

function generel_error_process(self, err)
		-- get error header acording to request uri
		local args = ngx.req.get_uri_args()
		local headers = ngx.req.get_headers()
		ngx.req.read_body()
		local post_args;
		if headers["content-type"] ~= nil and string.match(headers["content-type"], "multipart") ~= nil then
			post_args = {}
		else 
			post_args = ngx.req.get_post_args()
		end

		local error_header = "general"
		local len = #err
		ngx.status = ngx.HTTP_FORBIDDEN
		if len  == 1 then
			output_error_message(string.format(global_config.error_message_map[error_header][err[1]]))
		elseif len == 2  then
			output_error_message(string.format(global_config.error_message_map[error_header][err[1]], err[2]))
		elseif len == 3 then
			output_error_message(string.format(global_config.error_message_map[error_header][err[1]], err[2], err[3]))
		else
			print(err)
			output_error_message("Internal Server Error")
		end
		ngx.exit(ngx.status)
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
