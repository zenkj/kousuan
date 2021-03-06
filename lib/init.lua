-- for test
-- local ngx = {['config'] = {['prefix'] = function() return '/home/wecloud/openresty/projects/kousuan' end}}
--local time = os.time
--local clock = os.clock
--local difftime = os.difftime
--local function log(msg)
--    print(clock(), msg)
--end
-- for test

local lines = io.lines
local insert = table.insert
local concat = table.concat
local tonumber = tonumber
local pairs = pairs
local ipairs = ipairs
local floor = math.floor
local random = math.random
local randomseed = math.randomseed
local format = string.format

local function shuffle(arr)
    local n = #arr
    while n > 1 do
        local m = floor(random()*n)+1
        local x = arr[m]
        arr[m] = arr[n]
        arr[n] = x
        n = n - 1
    end
end

local questions = {}

--log 'begin to load questions...'
local qdir = ngx.config.prefix() .. '/data/q/'
for i=1,53 do
    questions[i] = {}
    for line in lines(qdir .. i .. '.txt') do
        insert(questions[i], tonumber(line, 16))
    end
end
--log 'finish to load questions.'

local papertypes = require 'conf.papertypes'
local qtsequences = require('lib.qtypes').qtsequences

-- papertypemap = {
--   ['1-1'] = {
--     {['sequence'] = 1, ['name'] = '10以内加法'},
--     {['sequence'] = 2, ['name'] = '10以内减法'},
--   },
--   ['1-2'] = {
--     ...
--   },
--   ['2-1'] = {
--     ...
--   },
--   ['2-2'] = {
--     ...
--   }
-- }
local papertypemap = {}

for i,ptype in ipairs(papertypes) do
    if i ~= ptype.sequence then
        error('Invalid sequence of papertype #' .. i)
    end
    local total = 0
    local qts = ptype.qtypes
    local newqts = {}
    for qt, percent in pairs(qts) do
        local qtseq = qtsequences[qt]
        if not qtseq then
            error('Invalid qtype "' .. qt .. '" in papertype #' .. i)
        else
            newqts[qtseq] = percent
        end
        total = total + percent
    end
    if total ~= 100 then
        error('Invalid qtypes in papertype #' .. i
              .. ': total percentage is not 100: ' .. tatal)
    end
    ptype.qtypes = newqts

    local gs = ptype.grade .. '-' .. ptype.semester
    local gsarray = papertypemap[gs]
    if not gsarray then
        gsarray = {}
        papertypemap[gs] = gsarray
    end
    insert(gsarray, {['sequence'] = i, ['name'] = ptype.name})
end

-- make questions
local function makeq(kv, rseed, noshuffle)
    local result = {}

    if rseed then randomseed(rseed) end

    local r = floor(random()*180000)

    for k,v in pairs(kv) do
        if k > 0 and k <= #questions then
            local q = questions[k]
            local len = #q
            for i = 1,v do
                local n = (r+i)%len + 1
                insert(result, q[n])
            end
        end
    end

    if not noshuffle then shuffle(result) end

    return result
end

-- make test paper
local function makep(ptype, count, rseed)

    local pt = papertypes[ptype]
    if not pt then return end

    local ks = {}
    local vs = {}
    local tmp = 0
    for k,v in pairs(pt.qtypes) do
        insert(ks, k)
        local v1 = floor(v/100*count)
        tmp = tmp + v1
        insert(vs, v1)
    end

    for i = 1, count-tmp do
        local k = i % #vs + 1
        vs[k] = vs[k] + 1
    end

    local kv = {}
    for i=1,#ks do
        kv[ks[i]] = vs[i]
    end

    return makeq(kv, rseed)
end

-- for test
--for i,v in ipairs(makeq({[1]=10, [5]=10, [46]=10, [53]=20})) do
--    print(i,format('%08X',v))
--end
-- for test

local _M = {}

_M.makeq = makeq
_M.makep = makep
local json = require 'cjson'
_M.papertypes = json.encode(papertypemap)

return _M
