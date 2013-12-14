
local setmetatable = setmetatable
local type = type
local ngx = ngx
local require = require
local print = print
local error = error
local global_config = require("global_config")
local pcall = pcall

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
		error()
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
		error()
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
		error()
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

function mysql_exec_query(db, sql)
	local mysql = require "resty.mysql"
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

	return ret
end

function getAppByAppKey(self, appKey)
	local sql = "select app_key,app_secret from ts_accessor where app_key = " .. ngx.quote_sql_str(appKey) .. " limit 1"
	return mysql_exec_query(sql)
end

function getFlowControl(self)
	local sql = "select uri, max_ps from flow_control limit 1"
	return mysql_exec_query(sql)
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)