local service_module = require(ngx.var.uri) then
if service_module 
	service_module.service_process()
	ngx.exit(ngx.HTTP_OK)
else
	ngx.exit(ngx.HTTP_NOT_FOUND)
end

