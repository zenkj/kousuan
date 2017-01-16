-- for test
--local ngx = {['config'] = {['prefix'] = '/home/wecloud/openresty/projects/kousuan'}}
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
local qdir = ngx.config.prefix .. '/data/q/'
for i=1,53 do
    questions[i] = {}
    for line in lines(qdir .. i .. '.txt') do
        local v = hex(line)
        insert(questions[i], v)
    end
end
--log 'finish to load questions.'

local _M = {}

_M.hex = hex
_M.hexstr = hexstr

function _M.makeq(kv, doshuffle)
    local result = {}
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
    if doshuffle then shuffle(result) end
    return result
end

-- for test
--for i,v in ipairs(_M.makeq({[1]=10, [5]=10, [46]=10, [53]=20})) do
--    print(i,hexstr(v))
--end
-- for test

return _M
