local _M = {}
function _M.getdb()
    local mysql = require "resty.mysql"
    local db, err = mysql:new()
    if not db then
        ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
        return
    end

    db:set_timeout(1000) -- 1 sec

    local result, err, errcode, sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "kousuan",
        user = "kousuan",
        password = "kousuan",
        max_packet_size = 1024 * 1024 }

    if not result then
        ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return
    end

    return db
end

function _M.releasedb(db)
    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle timeout
    local ok, err = db:set_keepalive(10000, 100)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
        return
    end
    return true
end

return _M
