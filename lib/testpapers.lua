local _M = {}

local db = require 'lib.db'
local getdb = db.getdb
local releasedb = db.releasedb
local auth = require 'lib.auth'
local makeq = require('lib.init').makeq
local makep = require('lib.init').makep

local insert = table.insert
local concat = table.concat
local floor  = math.floor


-- join a2 to a1
local function ajoin(a1, a2)
    for _, v in ipairs(a2) do
        insert(a1, v)
    end
end    

-- GET /testpapers
function _M.GET()

    if not auth.pass() then
        return ngx.exit(401)
    end

    local uid = auth.uid()

    local db = getdb()
    if not db then return end

    local result, err, errcode, sqlstate =
        db:query("select paperid, name, description, create_time, question_number, duration from testpapers "
                 .. " where creatorid = " .. uid)
    if not result then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        return
    end

    local final = result

    while err == 'again' do
        result, err, errcode, sqlstate = db:read_result()
        if not result then
            ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
            return
        end
        ajoin(final, result)
    end

    local js = require 'cjson'
    ngx.say(js.encode(final))

    releasedb(db)
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

    name = ngx.quote_sql_str(name)
    desc = ngx.quote_sql_str(desc or '')
    duration = ngx.quote_sql_str(tostring(duration or 0))

    local db = getdb()
    if not db then return end

    ngx.print("connected to mysql.")

    local result, err, errcode, sqlstate =
        db:query("insert into testpapers (name, description, creatorid, question_number, duration) "
                 .. "values ('"..name.."', '"..desc.."', "..myid..", "..#paper..", "..duration..")")
    if not result then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        return
    end

    local paperid = result.insert_id
    local qs = {}
    for i=1, #paper do
        local question = paper[i]
        local n = question
        local operand3 = n % 256
        n = floor(n/256)
        local operand2 = n % 256
        n = floor(n/256)
        local operand1 = n % 256
        n = floor(n/256)
        local qtype = n
        local q = {paperid, i, qtype, operand1, operand2, operand3, question}
        insert(qs, '('..concat(q, ', ')..')')
    end

    result, err, errcode, sqlstate = 
        db:query("insert into questions (paperid, sequence, qtype, operand1, operand2, operand3, question) "
                 .. "values " .. concat(qs, ', '))
    if not result then
        ngx.log(ngx.ERR, "band result: ", err, ": ", errcode, ": ", sqlstate, ".")
    end

    ngx.exit(200)

    releasedb(db)
end

local function updatepaper(pid, name, desc, duration)

    name = ngx.quote_sql_str(name)
    desc = ngx.quote_sql_str(desc or '')
    duration = ngx.quote_sql_str(tostring(duration or 0))

    local db = getdb()
    if not db then return end

    local result, err, errcode, sqlstate =
        db:query("update testpapers set name = '"..name.."', description = '"..desc.."', duration = "..duration
                 .." where paperid = "..pid) 
    if not result then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        releasedb(db)
        return ngx.exit(500)
    end

    ngx.exit(200)

    releasedb(db)
end

function _M.POST()

    if not auth.pass() then
        return ngx.exit(401)
    end

    --local js = require 'cjson'

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

    local paper = makeq(spec)

    if #paper == 0 then
        ngx.log(ngx.ERR, "invalid paper spec: ", args)
    end

    storepaper(name, desc, auth.uid(), duration, paper)

    return ngx.exit(200)
end

local _S = {}

_M.single = _S

function _S.GET()

    if not auth.pass() then
        return ngx.exit(401)
    end

    local uid = auth.uid()

    local db = getdb()
    if not db then return end

    local pid = tonumber(ngx.var[1])

    local result, err, errcode, sqlstate =
        db:query("select name, description, creatorid, create_time, question_number, "
                 .. "duration from testpapers where paperid = " .. pid)
    if not result then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        releasedb(db)
        return ngx.exit(500)
    end

    local final = result

    result, err, errcode, sqlstate = 
        db:query("select question from questions where paperid = " .. pid 
                 .. "order by sequence asc");
    if not result then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        releasedb(db)
        return ngx.exit(500)
    end

    local total = result
    while err == 'again' do
        result, err, errcode, sqlstate = db:read_result()
        if not result then
            ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
            releasedb(db)
            return ngx.exit(500)
        end
        ajoin(total, result)
    end

    final.questions = {}
    for _,v in ipairs(total) do
        insert(final.questions, v.question)
    end

    local js = require 'cjson'
    ngx.say(js.encode(final))

    releasedb(db)
end

function _S.PUT()

    if not auth.pass() then
        return ngx.exit(401)
    end

    local uid = auth.uid()

    local pid = tonumber(ngx.var[1])

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

    updatepaper(pid, name, desc, duration)

end

function _S.DELETE()

    if not auth.pass() then
        return ngx.exit(401)
    end

    local uid = auth.uid()

    local pid = tonumber(ngx.var[1])

    local db = getdb()
    if not db then return end

    local result, err, errcode, sqlstate =
        db:query("delete from testpapers where paperid = "..pid) 
    if not result then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        releasedb(db)
        return ngx.exit(500)
    end

    ngx.exit(200)
    releasedb(db)
end


_M.makep = makep

return _M
