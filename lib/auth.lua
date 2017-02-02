local _M = {}

local uid = nil
local sidmap = {}

function _M.pass()
    local ck = require "lib.resty.cookie"
    local cookie, err = ck:new()
    if not cookie then
        ngx.log(ngx.ERR, err)
        return
    end

    -- get single cookie
    local field, err = cookie:get("kssid")
    if not field then
        ngx.log(ngx.ERR, err)
        return
    end
    --ngx.print("kssid", " => ", field)

    uid = sidmap[field]

    if uid then return true end

    -- set one cookie
    --local ok, err = cookie:set({
    --    key = "kssid", value = "kssid", path = "/",
    --    --domain = "example.com", secure = true, httponly = true,
    --    --expires = "Wed, 09 Jun 2021 10:18:14 GMT", max_age = 50,
    --    --samesite = "Strict", extension = "a4334aebaec"
    --})
    --if not ok then
    --    ngx.log(ngx.ERR, err)
    --    return
    --end

end

function _M.uid()
    return uid
end

return _M
