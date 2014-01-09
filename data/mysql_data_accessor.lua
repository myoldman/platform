
local setmetatable = setmetatable
local type = type
local ngx = ngx
local require = require
local print = print
local error = error
local global_config = require("global_config")
local pcall = pcall
local string = string
local os = os

module(...)

_VERSION = '0.1'

local mt = { __index = _M }

function new(self)
    return setmetatable({}, mt)
end

function mysql_connect()
	local mysql = require "resty.mysql"
	local db, err = mysql:new()
	if not db then
		print("failed to instantiate mysql: ", err)
		error(err)
		return
	end
	
	db:set_timeout(1000)
	local ok, err, errno, sqlstate = db:connect{
			host = global_config.mysql_host,
			port = global_config.mysql_port,
			database = global_config.mysql_database,
			user = global_config.mysql_user,
			password = global_config.mysql_password,
			max_packet_size = global_config.max_packet_size }
	if not ok then
		print("failed to connect: ", err, ": ", errno, " ", sqlstate)
		error(err)
		return
	end
	return db
end

function mysql_reconnect(db)
	print("mysql query error retry connection")
	db:close()
	local db_new = mysql_connect()
	return db_new
end


function mysql_query(db, query_str)
	local res, err, errno, sqlstate =
	db:query(query_str)
	if not res then
		print("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
		error(err)
		return
	end
	return res
end

function mysql_keepalive(db)
	local ok, err = db:set_keepalive(0, 100)
	if not ok then
		print("failed to set keepalive: ", err)
		return
	end
end

function mysql_exec_query(sql)
	local db = mysql_connect()
	if not db then 
		return nil
	end

	local res, ret = pcall(mysql_query, db, sql)
	if res == false then
		db = mysql_reconnect(db)
		res, ret = pcall(mysql_query, db, sql)
	end

	mysql_keepalive(db)

	return res, ret
end


function getAppByAppKey(self, appKey)
	local sql = "select app_key,app_secret from ts_accessor where app_key = " .. ngx.quote_sql_str(appKey) .. " limit 1"
	return mysql_exec_query(sql)
end

function getFlowControl(self)
	local sql = "select uri, max_qps from flow_control"
	return mysql_exec_query(sql)
end

function addUserInfo(self, username, mobilephone, password, user_uuid, timestamp)
	local sql
	if username ~= nil then
		 sql = string.format("insert into user_info(user_name, mobile_phone, password, user_uuid, create_time) values (%s, %s, %s, %s, %s)", ngx.quote_sql_str(username), ngx.quote_sql_str(mobilephone), ngx.quote_sql_str(password), ngx.quote_sql_str(user_uuid), ngx.quote_sql_str(timestamp))
	else
		sql = string.format("insert into user_info(mobile_phone, password, user_uuid, create_time) values (%s, %s, %s, %s)", ngx.quote_sql_str(mobilephone), ngx.quote_sql_str(password), ngx.quote_sql_str(user_uuid), ngx.quote_sql_str(timestamp))
	end
	return mysql_exec_query(sql)
end

function delUserInfoByUsername(self, username)
	local res, user_info = getUserInfoByUserName(self, username)
	if not res or user_info == nil or #user_info <= 0 then
		return res, user_info
	end
	deleteUserToken(self, user_info[1]["user_uuid"])
	local sql = string.format("delete from user_info where user_name = %s", ngx.quote_sql_str(username))
	return mysql_exec_query(sql)
end

function delUserInfoByMobilephone(self, mobilephone)
	local res, user_info = getUserInfoByMobilePhone(self, mobilephone)
	if not res or user_info == nil or #user_info <= 0 then
		return res, user_info
	end
	deleteUserToken(self, user_info[1]["user_uuid"])
	local sql = string.format("delete from user_info where mobile_phone = %s", ngx.quote_sql_str(mobilephone))
	return mysql_exec_query(sql)
end

function delUserInfoByUUID(self, user_uuid)
	deleteUserToken(self, user_uuid)
	local sql = string.format("delete from user_info where user_uuid = %s", ngx.quote_sql_str(user_uuid))
	return mysql_exec_query(sql)
end
 
 function getUserInfoByUserName(self, username)
	local sql = string.format("select id,user_uuid,password from user_info where user_name = %s limit 1", ngx.quote_sql_str(username))
	return mysql_exec_query(sql)
end

function getUserInfoByMobilePhone(self, mobilephone)
	local sql = string.format("select id,user_uuid,password from user_info where mobile_phone = %s limit 1", ngx.quote_sql_str(mobilephone))
	return mysql_exec_query(sql)
end

function deleteUserToken(self, user_uuid)
	local sql = string.format("delete from user_token where user_uuid = %s", ngx.quote_sql_str(user_uuid))
	return mysql_exec_query(sql)
end

function addUserToken(self, user_uuid, token)
	deleteUserToken(self, user_uuid)
	local create_time = ngx.localtime()
	local create_time_sec = ngx.time()
	local expire_time_sec = create_time_sec +  60 * 60 * 24 * 90
	local expire_time = os.date("%Y-%m-%d %X",expire_time_sec)
	local sql = string.format("insert into user_token(user_uuid, token, create_time, expire_time) values (%s, %s, %s, %s)", ngx.quote_sql_str(user_uuid), ngx.quote_sql_str(token), ngx.quote_sql_str(create_time), ngx.quote_sql_str(expire_time))
	return mysql_exec_query(sql)
end
 
function getTokenInfoByToken(self, token)
	local sql = string.format("select user_uuid, token, create_time, expire_time from user_token where token = %s limit 1", ngx.quote_sql_str(token))
	return mysql_exec_query(sql)
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)