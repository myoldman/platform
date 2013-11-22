local cookie_module = require "cookie.cookie_processor"
local behavior_module = require "behavior.behavior_recorder"

local cookie = cookie_module:new()
local behavior_recorder = behavior_module:new()

local cookies = cookie.get_cookie()
local username = cookies["username"] or ngx.var.username
behavior_recorder.send_user_behavior_log(username)