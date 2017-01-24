local _M = {}

local db = require 'lib.db'
local getdb = db.getdb
local releasedb = db.releasedb
local auth = require 'lib.auth'
local qtypes = require('lib.qtypes').qtypes

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

local function storepaper(name, desc, myid, duration, paper)

    name = ngx.quote_sql_str(name)
    desc = ngx.quote_sql_str(desc or '')
    duration = ngx.quote_sql_str(tostring(duration or 0))

    local db = getdb()
    if not db then return end


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


local arithmetic = {
    function(d1, d2) return d1+d2 end,
    function(d1, d2) return d1-d2 end,
    function(d1, d2) return d1*d2 end,
    function(d1, d2)
        if d2 == 0 then
            ngx.log(ngx.ERR, "wrong question: divisor is zero")
            return 0xFFFF
        end
        return d1/d2
    end
}

local function calc(q)
    local d3 = q%256
    q = floor(q/256)
    local d2 = q%256
    q = floor(q/256)
    local d1 = q%256
    q = floor(q/256)
    local qt = q%256
    if qt < 1 or qt > #qtypes then
        ngx.log(ngx.ERR, "wrong question: invalid qtype")
        return 0xFFFF
    end
    local op1 = qt%4
    local op2, three
    if qt >= 128 then
        op2 = floor(qt/4)%4
        three = true
    elseif qt >= 64 then
        d1 = d1 * 10
        d2 = d2 * 10
        d3 = d3 * 10
    end

    local result = arithmetic[op1](d1, d2)
    if result == 0xFFFF then return result end

    if three then
        result = arithmetic[op2](result, d3)
    elseif result ~= d3 then
        ngx.log(ngx.ERR, "wrong question: invalid result")
        return 0xFFFF
    end

    return result, qt, d1, d2, d3
end

-- POST /answersheets
-- {
--   "ptype": 23,
--   "questions": [1234, 5678],
--   "answers": [2345, 7890], -- answer*65536+duration-in-0.1second
-- }
function _M.POST()

    --[[
    if not auth.pass() then
        return ngx.exit(401)
    end
    ]]

    local json = require 'cjson'

    ngx.req.read_body()

    local data = ngx.req.get_body_data()
    if not data then
        ngx.log(ngx.ERR, "error get post data")
        return ngx.exit(500)
    end



    local args = json.decode(data)
    if not args or type(args.ptype) ~= 'number'
        or type(args.questions) ~= 'table'
        or type(args.answers) ~= 'table' 
        or #args.questions == 0
        or #args.questions ~= #args.answers then
        ngx.log(ngx.ERR, "error get post data: ", data)
        return ngx.exit(500)
    end

    local ptype = args.ptype
    local qts = {}
    local d1s = {}
    local d2s = {}
    local d3s = {}
    local answers = {}
    local durations = {}
    local totalright = 0
    local totalduration = 0
    for i=1, #args.questions do
        local q = args.questions[i]
        local a = args.answers[i]
        if type(q) ~= 'number' or type(a) ~= 'number' then
            ngx.log(ngx.ERR, 'question "', q, '" or answer "', a, '" is not number')
            return ngx.exit(500)
        end
        local result, qt, d1, d2, d3 = calc(q)
        if result == 0xFFFF then return ngx.exit(500) end

        local duration = a % 65536
        local answer = floor(a/65536)%65536
        if result == answer then totalright = totalright + 1 end
        totalduration = totalduration + duration
        insert(qts, qt)
        insert(d1s, d1)
        insert(d2s, d2)
        insert(d3s, d3)
        insert(answers, answer)
        insert(durations, duration)
    end

    storesheet(ptype, auth.uid(), qts, d1s, d2s, d3s, answers, durations)

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

--[[
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
]]

return _M
