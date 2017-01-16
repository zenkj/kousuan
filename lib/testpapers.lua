local _M = {}

function _M.GET()

end

-- POST /testpapers
-- name=abc&description=def&t-1=50&t-6=20&duration=300
-- same as: {
--   "name": "abc",
--   "description": "def",
--   "type-1": 50,
--   "type-6": 20,
--   "duration": 300
-- }
local function storepaper(name, desc, myid, duration, paper)
    local mysql = require "resty.mysql"
    local db, err = mysql:new()
    if not db then
        ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
        return
    end

    db:set_timeout(1000) -- 1 sec

    local ok, err, errcode, sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "kousuan",
        user = "kousuan",
        password = "kousuan",
        max_packet_size = 1024 * 1024 }

    if not ok then
        ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return
    end

    ngx.print("connected to mysql.")

    ok, err, errcode, sqlstate =
        db:query("insert into cats (name) "
                 .. "values (\'Bob\'),(\'\'),(null)")
    if not ok then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        return
    end

    ngx.say(res.affected_rows, " rows inserted into table cats ",
            "(last insert id: ", res.insert_id, ")")

    -- run a select query, expected about 10 rows in
    -- the result set:
    ok, err, errcode, sqlstate =
        db:query("select * from cats order by id asc", 10)
    if not ok then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        return
    end

    local cjson = require "cjson"
    ngx.print("result: ", cjson.encode(res))

    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle timeout
    local ok, err = db:set_keepalive(10000, 100)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
        return
    end
end

function _M.POST()
    local auth = require 'lib.auth'

    if not auth.pass() then
        return ngx.exit(401)
    end

    --local js = require 'cjson'
    local makeq = require('lib.init').makeq

    ngx.req.read_body()

    local args, err = ngx.req.get_post_args()
    if not args then
        ngx.log(ngx.ERR, "error get post args: ", err)
        return ngx.exit(500)
    end

    local name = args.name
    local desc = args.description
    local duration = args.duration

    if not name or name:len() == 0 then
        ngx.log(ngx.ERR, "invalid paper name: empty name")
        return ngx.exit(500)
    end

    local spec = {}
    for k,v in pairs(args) do
        k = k:match '^t%-([0-9]+)$'
        v = v:match '^[0-9]+$'
        if k and v then
            spec[tonumber(k)] = tonumber(v)
        end
    end

    local paper = makeq(spec, true)

    if #paper == 0 then
        ngx.log(ngx.ERR, "invalid paper spec: ", args)
    end

    storepaper(name, desc, auth.uid(), duration, paper)

    return ngx.exit(200)
end

function _M.PUT()

end

function _M.DELETE()

end

return _M
