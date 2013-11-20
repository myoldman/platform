
local setmetatable = setmetatable
local type = type
local ngx = ngx
local mysql_host = mysql_host
local mysql_port = mysql_port
local mysql_database = mysql_database
local mysql_user = mysql_user
local mysql_password = mysql_password
local max_packet_size = max_packet_size
local require = require
local print = print
local error = error

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
			host = MYSQL_HOST,
			port = MYSQL_PORT,
			database = MYSQL_DATABASE,
			user = MYSQL_USER,
			password = MYSQL_PASSWORAD,
			max_packet_size = MAX_PACKET_SIZE }
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

function getAppByAppKey(self, appKey)
	local mysql = require "resty.mysql"
	local db = mysql_connect()
	if not db then 
		return nil
	end

	local sql = "select app_key,app_secret from ts_accessor where app_key = " .. ngx.quote_sql_str(appKey) .. " limit 1"
	local res, app_info = pcall(mysql_query, db, sql)
	if res == false then
		db = mysql_reconnect(db)
		res, app_info = pcall(mysql_query, db, sql)
	end

	mysql_keepalive(db)

	return app_info
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)