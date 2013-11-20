local method_name = ngx.req.get_method()
if method_name == "POST" then
	ngx.req.read_body()
    local args = ngx.req.get_post_args()
    local username = args["username"] or ngx.var.username
    ngx.log(ngx.INFO, "username post is " .. username)
    ngx.ctx.username = username
end