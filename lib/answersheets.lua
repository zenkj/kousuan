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

--[[
-- GET /answersheets
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
]]

local function storesheet(ptype, myid, compact_questions, compact_answers, qts, d1s, d2s, d3s, answers, durations, totalright, totalduration)

    local db = getdb()
    if not db then return end


    local result, err, errcode, sqlstate =
        db:query("insert into answersheets (ptype, studentid, duration, qcount, rcount) "
                 .. "values ('"..ptype.."', '"..myid.."', '"..totalduration.."', "..#qts..", "..totalright..")")
    if not result then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        releasedb(db)
        return
    end

    local sheetid = result.insert_id
    local as = {}
    for i=1, #qts do
        local q = {sheetid, i, qts[i], d1s[i], d2s[i], d3s[i], answers[i], durations[i], compact_questions[i], compact_answers[i]}
        insert(as, '('..concat(q, ', ')..')')
    end

    result, err, errcode, sqlstate = 
        db:query("insert into answers (sheetid, sequence, qtype, operand1, operand2, "
                .. "operand3, answer, duration, compact_question, compact_answer) "
                 .. "values " .. concat(as, ', '))
    if not result then
        ngx.log(ngx.ERR, "band result: ", err, ": ", errcode, ": ", sqlstate, ".")
        releasedb(db)
        return
    end

    releasedb(db)
    return sheetid
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
        ngx.log(ngx.ERR, "wrong question " .. q .. ": invalid qtype " .. qt)
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
        ngx.log(ngx.ERR, "wrong question " .. q .. ": invalid result " .. d3)
        return 0xFFFF
    end

    return result, qt, d1, d2, d3
end

-- POST /answersheets
-- 交卷
-- params:
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

    local compact_questions = args.questions
    local compact_answers = args.answers

    local ptype = args.ptype
    local qts = {}
    local d1s = {}
    local d2s = {}
    local d3s = {}
    local answers = {}
    local durations = {}
    local totalright = 0
    local totalduration = 0
    for i=1, #compact_questions do
        local q = compact_questions[i]
        local a = compact_answers[i]
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

    local sheetid = storesheet(ptype, auth.uid(), compact_questions, compact_answers,
                        qts, d1s, d2s, d3s, answers, durations, totalright, totalduration)

    if sheetid then
        ngx.say('{"sheetid": ' .. sheetid .. '}')
    end

    return ngx.exit(200)
end

local _S = {}

_M.single = _S

-- 查卷
-- return：
-- {
--   "ptype": 12,
--   "studentid": 123,
--   "submit_time": 12342342,
--   "duration": 123414,
--   "qcount": 100,
--   "rcount": 98,
--   "questions": [12343, 234123],
--   "answers": [134324, 31241213]
-- }
function _S.GET(sheetid)

    if not auth.pass() then
        return ngx.exit(401)
    end

    local uid = auth.uid()

    local db = getdb()
    if not db then return end

    local result, err, errcode, sqlstate =
        db:query("select ptype, studentid, submit_time, duration, qcount, "
                 .. "rcount from answersheets where sheetid = " .. sheetid)
    if not result then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        releasedb(db)
        return ngx.exit(500)
    end

    if not result[1] or result[1].studentid ~= uid then
        ngx.log(ngx.ERR, "invalid query from " .. uid)
        return ngx.exit(401)
    end

    local final = result[1]

    result, err, errcode, sqlstate = 
        db:query("select compact_question, compact_answer from answers where sheetid = "
                  .. sheetid .. " order by sequence asc");
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
    final.answers = {}
    for _,v in ipairs(total) do
        insert(final.questions, v.compact_question)
        insert(final.answers, v.compact_answer)
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
