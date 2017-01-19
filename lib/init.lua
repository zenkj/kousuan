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
local floor = math.floor
local random = math.random
local randomseed = math.randomseed
local ascii = string.byte
local substr = string.sub

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

local _hexstring = '0123456789ABCDEF'
local _hexmap = {}
for i=1,_hexstring:len() do
    _hexmap[ascii(_hexstring,i)] = i-1
    _hexmap[i] = substr(_hexstring, i, i)
end

local function hexmap(str, i)
    return _hexmap[ascii(str, i)]
end

-- hex('1234') return 0x3412
-- this means the string should be little-endian
local function hex(str, beginp, endp)
    beginp = beginp or 1
    endp = endp or str:len()
    local n = endp
    local result = 0
    while n > beginp do
        local h = hexmap(str, n-1)
        local l = hexmap(str, n)
        if not h or not l then return -1 end
        result = result*256 + h*16 + l 
        n = n-2
    end
    return result
end

local function hexstr(n)
    local ss = {}
    while n > 0 do
        local r = n%256
        local h = floor(r/16) + 1
        local l = r%16 + 1
        insert(ss, _hexmap[h])
        insert(ss, _hexmap[l])
        n = floor(n/256)
    end
    return concat(ss, '')
end

        

local questions = {}

--log 'begin to load questions...'
local qdir = ngx.config.prefix() .. '/data/q/'
for i=1,53 do
    questions[i] = {}
    for line in lines(qdir .. i .. '.txt') do
        insert(questions[i], tonumber(line))
    end
end
--log 'finish to load questions.'

local papertypes = require 'conf.papertypes'
local qtypes = require 'lib.qtypes'
for i,ptype in ipairs(papertypes) do
    if i ~= ptype.sequence then
        error('Invalid sequence of papertype #' .. i)
    end
    local total = 0
    local qts = ptype.qtypes
    local newqts = {}
    for qt, percent in pairs(qts) do
        local qtid = qtypes[qt]
        if not qtid then
            error('Invalid qtype "' .. qt .. '" in papertype #' .. i)
        else
            newqts[qtid] = percent
        end
        total = total + percent
    end
    if total ~= 100 then
        error('Invalid qtypes in papertype #' .. i
              .. ': total percentage is not 100: ' .. tatal)
    end
    ptype.qtypes = newqts
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
    ngx.say(ptype, count, rseed)

    local pt = papertypes[ptype]
    if not pt then return end

    ngx.say(pt.sequence)

    local ks = {}
    local vs = {}
    local tmp = 0
    for k,v in pairs(pt.qtypes) do
        insert(ks, k)
        local v1 = floor(v/100*count)
        tmp = tmp + v1
        insert(vs, v1)
    end

    ngx.say('tmp = ' .. tmp)

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
--    print(i,hexstr(v))
--end
-- for test

local _M = {}

_M.hex = hex
_M.hexstr = hexstr
_M.makeq = makeq
_M.makep = makep

return _M
