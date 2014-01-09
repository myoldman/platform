local setmetatable = setmetatable
local type = type
local ngx = ngx
local require = require
local error = error
local table = table
local print = print
local pairs = pairs
local ipairs = ipairs
local global_config = require("global_config")

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self)
    return setmetatable({}, mt)
end
function authentication_for_findme()
	local data_module = require("data.data_access_facade")
	local data_accessor = data_module:new("mysql")
	local headers = ngx.req.get_headers()
	local request_time = headers["request-time"]
	local access_token = headers["access-token"]
	local sign = headers["sign"]

	if request_time == nil or type(request_time) ~= "string" or #request_time <= 0 then
		error({"request_time_empty"})
	end

	if access_token == nil or type(access_token) ~= "string" or #access_token <= 0 then
		error({"access_token_empty"})
	end
	
	if sign == nil or type(sign) ~= "string" or #sign <= 0 then
		error({"sign_empty"})
	end

	print(request_time)
	local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
	local runyear, runmonth, runday, runhour, runminute, runseconds = request_time:match(pattern)
	if runyear == nil or runmonth == nil or runday == nil or runhour == nil or runminute == nil or runseconds == nil then
		error({"request_time_format_error"})
		return	
	end

	local res, ret = data_accessor:getTokenInfoByToken(access_token)

	if not res or ret == nil or #ret <= 0 then
		error({"access_token_invalid"})
	end

	local sign_cal = ngx.md5(request_time..access_token..global_config.secret)

	if sign_cal ~= sign then
		error({"access_token_invalid"})
	end

	local runyear, runmonth, runday, runhour, runminute, runseconds = request_time:match(ret["expire_time"])
	local expire_time_second = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})

	if expire_time_second < ngx.time() then
		error({"access_token_expired"})
	end

	ngx.req.set_header("user-uuid", ret["user-uuid"])

end

function authentication(username, password)
	ngx.log(ngx.INFO, "authentication with user " .. username .. " password " .. password)
	return false
end

function generate_multiple_keyvalue_string(arg_name, arg_values)
    local ret_string = ""
    table.sort(arg_values)
    for key, val in pairs(arg_values) do
        if key == 1 then
            ret_string = arg_name .. val
        else 
            ret_string = ret_string .. arg_name .. val
        end
    end
    return ret_string
end

function authentication_for_api()
	local data_module = require("data.data_access_facade")
	local data_accessor = data_module:new("mysql")
	local sign_before_enc = ""
	local key_table = {}
	-- get uri args and post args
	local args = ngx.req.get_uri_args()
	local headers = ngx.req.get_headers()
	if headers["content-type"] ~= nil and string.match(headers["content-type"], "multipart") ~= nil then
		error({"server_busy"})
	end

	ngx.req.read_body()
	local post_args = ngx.req.get_post_args()
	local app_key = args["app_key"] or post_args["app_key"] or headers["app_key"]
	if app_key == nil or type(app_key) ~= "string" or #app_key <= 0 then
		error({"app_id_empty"})
		return
	end

	local app_info = data_accessor:getAppByAppKey(app_key)
	if app_info == nil or #app_info == 0 then
		error({"app_not_exist",app_id})
	end

	local method = args["method"] or post_args["method"] or headers["method"]
	if method == nil or type(method) ~= "string" or #method <= 0 then
		error({"access_token_empty"})
		return
	end

	local timestamp = args["timestamp"] or post_args["timestamp"] or headers["timestamp"]
	if timestamp == nil or type(timestamp) ~= "string" or #timestamp <= 0 then
		error({"timestamp_empty"})
		return
	end

	local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
	local runyear, runmonth, runday, runhour, runminute, runseconds = timestamp:match(pattern)
	if runyear == nil or runmonth == nil or runday == nil or runhour == nil or runminute == nil or runseconds == nil then
		error({"timestamp_format_error"})
		return	
	end

	-- sign field calculate and check
	local sign = args["sign"] or post_args["sign"] or headers["sign"]
	if sign == nil or type(sign) ~= "string" or #sign <= 0 then
		error({"sign_empty"})
		return
	end

		-- sign field calculate and check
	local sign_method = args["sign_method"] or post_args["sign_method"] or headers["sign_method"] 
	if sign_method == nil or type(sign_method) ~= "string" or #sign_method <= 0  then
		error({"sign_empty"})
		return
	end

	for key, val in pairs(args) do
		if key ~= "sign" then
			table.insert(key_table, key)
		end
	end

	if post_args ~= nil and type(post_args) == "table" then
		for key, val in pairs(post_args) do
			if key ~= "sign" and exist_key(key_table,key) == false then
				table.insert(key_table, key)
			end
		end
	end
		
	table.sort(key_table)

	for i,val in ipairs(key_table) do
		local temp_val = args[val] or post_args[val]
		if i == 1 then
			if type(temp_val) == "string" then
				sign_before_enc = val .. temp_val
			else
				sign_before_enc = generate_multiple_keyvalue_string(val, temp_val)
			end
		else
			if type(temp_val) == "string" then 
				sign_before_enc = sign_before_enc .. val .. temp_val
			else
				sign_before_enc = sign_before_enc .. generate_multiple_keyvalue_string(val, temp_val)
			end
		end
	end

	sign_before_enc = app_info[1]["app_secret"] .. sign_before_enc

	local sign_after_enc = ngx.md5(sign_before_enc)
	print(sign_after_enc)
	if sign_after_enc ~= sign then
		error({"sign_error"})
	end

	return app_info[1]["app_secret"]
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
