local cookie_module = require "cookie.cookie_processor"
local cookie = cookie_module:new()
local method_name = ngx.req.get_method()
ngx.log(ngx.INFO, "header filter")
if method_name == "POST" then
    local username = ngx.ctx.username or ngx.var.username
    cookie.set_cookie(username)
end