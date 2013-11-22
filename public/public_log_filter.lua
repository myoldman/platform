local flowcontrol_module = require "flowcontrol.flow_controller"
local behavior_module = require "behavior.behavior_recorder"

local cookies = cookie.get_cookie()
local username = cookies["username"] or ngx.var.username
behavior_recorder.send_user_behavior_log(username)