local authentication_module = require "user.authentication"
local authorization_module = require "user.authorization"
local cookie_module = require "cookie.cookie_processor"
local flowcontrol_module = require "flowcontrol.flow_controller"
local behavior_module = require "behavior.behavior_recorder"
local post_process_module = require "user.post_processor"

local authenticator = authentication_module:new()
local authorizor = authorization_module:new()
local cookie = cookie_module:new()
local flowcontroller = flowcontrol_module:new()
local behavior_recorder = behavior_module:new()
local post_processor = post_process_module:new()

local cookies = cookie.get_cookie()
local username = cookies["username"] or ngx.var.username

local flow_check_ret = flowcontroller.check_flowcontrol()
if flow_check_ret == false then
	return ngx.redirect("/access_overflow")
end

flowcontroller.incr_flowcontrol()

local is_authorize_needed = authorizor.is_authorize_needed()

if is_authorize_needed == false then
	post_processor.set_userinfo(username)
	behavior_recorder.save_user_behavior(username)
	return
end

if username == "anonymous" then
	return ngx.redirect("/login")
end

if authorizor.authorization(username) == false then 
	behavior_recorder.save_user_behavior(username)
	return ngx.redirect("/unauthorized")
end

post_processor.set_userinfo(username)
behavior_recorder.save_user_behavior(username)

