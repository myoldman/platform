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
    end

    ngx.req.read_body()
    local args = ngx.req.get_post_args()
    local username = args["username"]
    local mobilephone = args["mobilephone"]
    local password = args["password"]
    local resty_uuid = require "resty.uuid"
    local uuid = resty_uuid:gen20()
    local token = ngx.encode_base64(uuid)
    if mobilephone == nil and username == nil then
        error_processor:generel_error_process({"mobilephone_or_username_needed"})
    end

    if password == nil then
        error_processor:generel_error_process({"password_empty"})
    end

    local data_module = require("data.data_access_facade")
    local data_accessor = data_module:new("mysql")
    local user_info

    if mobilephone ~= nil then
        local res, ret = data_accessor:getUserInfoByMobilePhone(mobilephone)
        if not res or #ret <= 0 then
            error_processor:generel_error_process({"mobilephone_not_found"})
        end
        user_info = ret
    else
        local res, ret = data_accessor:getUserInfoByUserName(username)
        if not res or #ret <= 0 then
            error_processor:generel_error_process({"username_not_found"})
        end
        user_info = ret
    end

    if ngx.md5(password) ~= user_info[1]["password"] then
            error_processor:generel_error_process({"password_not_match"})
    end


    local res, ret = data_accessor:addUserToken(user_info[1]["user_uuid"], token)
    if res then
        local result_arr = {ret = 0, msg = "success", access_token = token, user_uuid = user_uuid }
        local cjson = require "cjson"
        ngx.say(cjson.encode(result_arr))
    else
        error_processor:generel_error_process({"server_error"})
    end

end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
