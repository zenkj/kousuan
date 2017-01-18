local concat = table.concat
local insert = table.insert

local random = math.random
local floor = math.floor

local data = {}

for i=1, 53 do
    data[i] = {}
end

local function map(list, f)
    local result = {}
    for i, v in ipairs(list) do
        insert(result, f(v))
    end
    return result
end

local h = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}
local function hex(n)
    local low = h[n%16+1]
    local high = h[floor(n/16)%16+1]
    return high..low
end

local flagmap = {
    ['x+y:1']       = 0 + 1*4,
    ['x+y:2']       = 0 + 2*4,
    ['x+y:3']       = 0 + 3*4,
    ['x+y:4']       = 0 + 4*4,
    ['x+y:5']       = 0 + 5*4,
    ['x+y:6']       = 0 + 6*4,
    ['x+y:7']       = 0 + 7*4,
    ['x+y:8']       = 0 + 8*4,
    ['x+y:9/10']    = 0 + 9*4  + 64,
    ['x+y:a/10']    = 0 + 10*4 + 64,
    ['x+y:b/10']    = 0 + 11*4 + 64,
    ['x-y:1']       = 1 + 1*4,
    ['x-y:2']       = 1 + 2*4,
    ['x-y:3']       = 1 + 3*4,
    ['x-y:4']       = 1 + 4*4,
    ['x-y:5']       = 1 + 5*4,
    ['x-y:6']       = 1 + 6*4,
    ['x-y:7']       = 1 + 7*4,
    ['x-y:8']       = 1 + 8*4,
    ['x-y:9/10']    = 1 + 9*4  + 64,
    ['x-y:a/10']    = 1 + 10*4 + 64,
    ['x-y:b/10']    = 1 + 11*4 + 64,
    ['x*y']         = 2,
    ['x/y']         = 3,
    ['x+y+z:1']     = 0 + 0*4 + 128 + 1*16,
    ['x+y+z:2']     = 0 + 0*4 + 128 + 2*16,
    ['x+y+z:3']     = 0 + 0*4 + 128 + 3*16,
    ['x+y-z:1']     = 0 + 1*4 + 128 + 1*16,
    ['x+y-z:2']     = 0 + 1*4 + 128 + 2*16,
    ['x+y*z:1']     = 0 + 2*4 + 128 + 1*16,
    ['x+y*z:2']     = 0 + 2*4 + 128 + 2*16,
    ['x+y/z:1']     = 0 + 3*4 + 128 + 1*16,
    ['x+y/z:2']     = 0 + 3*4 + 128 + 2*16,
    ['x-y+z:1']     = 1 + 0*4 + 128 + 1*16,
    ['x-y+z:2']     = 1 + 0*4 + 128 + 2*16,
    ['x-y-z:1']     = 1 + 1*4 + 128 + 1*16,
    ['x-y-z:2']     = 1 + 1*4 + 128 + 2*16,
    ['x-y-z:3']     = 1 + 1*4 + 128 + 3*16,
    ['x-y*z:1']     = 1 + 2*4 + 128 + 1*16,
    ['x-y*z:2']     = 1 + 2*4 + 128 + 2*16,
    ['x-y/z:1']     = 1 + 3*4 + 128 + 1*16,
    ['x-y/z:2']     = 1 + 3*4 + 128 + 2*16,
    ['x*y+z:1']     = 2 + 0*4 + 128 + 1*16,
    ['x*y+z:2']     = 2 + 0*4 + 128 + 2*16,
    ['x*y-z:1']     = 2 + 1*4 + 128 + 1*16,
    ['x*y-z:2']     = 2 + 1*4 + 128 + 2*16,
    ['x*y*z']       = 2 + 2*4 + 128,
    ['x*y/z']       = 2 + 3*4 + 128,
    ['x/y+z:1']     = 3 + 0*4 + 128 + 1*16,
    ['x/y+z:2']     = 3 + 0*4 + 128 + 2*16,
    ['x/y-z']       = 3 + 1*4 + 128,
    ['x/y*z']       = 3 + 2*4 + 128,
    ['x/y/z']       = 3 + 3*4 + 128
}

-- flag:
--   b7 b6 b5 b4 b3 b2 b1 b0
--   b7: 三操作数运算
--   b6: 操作数被除以10
--   b1b0: 第一个操作符: 00:+, 01:-, 10:*, 11:/
--   b3b2: 第二个操作符（可选）
--   b5b4: 保留
-- d1: 第一个操作数
-- d2: 第二个操作数
-- d3: 第三个操作数，或者二操作数的结果
local function say(fd, flag, d1, d2, d3)
    insert(data[fd], '0x'..concat(map({flagmap[flag],d1,d2,d3}, hex), ''))
end

local function shuffle(arr)
    local n = #arr
    while n > 1 do
        local m = floor(random()*n)+1
        local t = arr[m]
        arr[m] = arr[n]
        arr[n] = t
        n = n - 1
    end
end 

-- grade 1 semester 1
for i = 0, 20 do
    for j = 0, 20 do
        -- 1. addition within 10 (x+y)
        if i+j<=10 then say(1, 'x+y:1', i, j, i+j) end

        -- 2. subtraction within 10 (x-y)
        if i<=10 and i-j>=0 then say(2, 'x-y:1', i, j, i-j) end

        -- 3. carry-save addition within 20 (x+y)
        if (i>=10 or j>=10) and i+j<=20 then say(3, 'x+y:2', i, j, i+j) end

        -- 4. subtraction without abdication within 20 (x-y)
        if i>=10 and i-j>=0 and i%10>=j%10 then say(4, 'x-y:2', i, j, i-j) end

        -- 5. addition with carry within 20 (x+y)
        if i<10 and j<10 and i+j>10 then say(5, 'x+y:3', i, j, i+j) end

        -- 6. subtraction with abdication within 20 (x-y)
        if i-j>0 and i%10<j%10 then say(6, 'x-y:3', i, j, i-j) end

        -- 7-14 3 operands
        for k=0,20 do
            -- 7. continuous addition within 10 (x+y+z)
            if i+j+k <= 10 then say(7, 'x+y+z:1', i, j, k) end

            -- 8. continuous subtraction within 10 (x-y-z)
            if i<=10 and i-j-k>=0 then say(8, 'x-y-z:1', i, j, k) end

            -- 9. subtraction and addition within 10 (x-y+z)
            if i<=10 and i-j>=0 and i-j+k<=10 then say(9, 'x-y+z:1', i, j, k) end

            -- 10. addition and subtraction within 10 (x+y-z)
            if i+j<=10 and i+j-k>=0 then say(10, 'x+y-z:1', i, j, k) end

            -- 11. continuous addition within 20 (x+y+z)
            if i+j+k>10 and i+j+k<=20 then say(11, 'x+y+z:2', i, j, k) end

            -- 12. continuous subtraction within 20 (x-y-z)
            if i>10 and i-j-k>=0 then say(12, 'x-y-z:2', i, j, k) end

            -- 13. subtraction and addition within 20 (x-y+z)
            if i-j>=0 and i-j+k>10 and i-j+k<=20 then say(13, 'x-y+z:2', i, j, k) end

            -- 14. addition and subtraction within 20 (x+y-z)
            if i+j<=20 and i+j-k>=0 then say(14, 'x+y-z:2', i, j, k) end
        end
    end
end

-- grade 1 semester 2
for i=20,100 do
    for j=0,100,10 do
        -- 15. carry-save addition of whole 10 within 100 (x+y)
        if i+j<=100 then say(15, 'x+y:4', i, j, i+j); say(15, 'x+y:4', j, i, i+j) end

        -- 16. subtraction without abdication of whole 10 within 100 (x-y)
        if i-j>=0 then say(16, 'x-y:4', i, j, i-j) end
    end 
end

for i=10,100 do
    for j=0,10-1 do
        -- 17. carry-save addition of single digit within 100 (x+y)
        if i+j<=100 and i%10+j<10 then say(17,'x+y:5',i,j,i+j); say(17,'x+y:5',j,i,i+j) end

        -- 18. subtraction without abdication of single digit within 100 (x-y)
        if i-j>=0 and i%10>=j then say(18,'x-y:5',i,j,i-j) end

        -- 19. addition with carry of single digit within 100 (x+y)
        if i+j<=100 and i%10+j>=10 then say(19,'x+y:6',i,j,i+j) end

        -- 20. subtraction with abdication of single digit within 100 (x-y)
        if i-j>=0 and i%10<j then say(20,'x-y:6',i,j,i-j) end
    end
end

for i=10,100-1 do
    for j=10,100-1 do
        -- 21. carry-save addition of double-digit within 100 (x+y)
        if i+j<=100 and i%10+j%10<10 then say(21,'x+y:7',i,j,i+j) end

        -- 22. subtraction without abdication of double-digit within 100 (x-y)
        if i-j>=0 and i%10>=j%10 then say(22,'x-y:7',i,j,i-j) end

        -- 23. addition with carry of double-digit within 100 (x+y)
        if i+j<=100 and i%10+j%10>=10 then say(23,'x+y:8',i,j,i+j) end

        -- 24. subtraction without abdication of double-digit within 100 (x-y)
        if i-j>=0 and i%10<j%10 then say(24,'x-y:8',i,j,i-j) end
    end 
end

-- 25 and 26, 3 operands
-- 25. continuous addition within 100 (x+y+z)
for i=0,100-1 do
    for j=0,100-1 do
        for k=0,100-1 do
            if i+j+k<=100 and i+j+k>20 then say(25,'x+y+z:3',i,j,k) end
        end
    end
end

-- 26. continous subtraction within 100 (x-y-z)
for i=21,100-1 do
    for j=0,100-1 do
        for k=0,100-1 do
            if i-j-k>=0 then say(26,'x-y-z:3',i,j,k) end
        end
    end
end

-- grade 2 semester 1
for i=0,10-1 do
    for j=0,10-1 do
        -- 27. multiplication within table (x*y)
        say(27,'x*y',i,j,i*j)

        -- 28. division within table (x/y)
        if i~=0 then say(28,'x/y',i*j,i,j) end

        -- from 29 to 47, there are 3 operands
        for k=0,10-1 do
            if i*j<10 or j*k<10 or i*k<10 then
                -- 29. continuous multiplication within table (x*y*z)
                say(29,'x*y*z',i,j,k)

                -- 30. continuous division within table (x/y/z)
                if i~=0 and j~=0 then say(30,'x/y/z',i*j*k,i,j) end
            end
            -- 31. division and multiplication within table (x/y*z)
            if i~=0 then say(31,'x/y*z',i*j,i,k) end

            -- 32. multiplication and division within table (x*y/z)
            if k~=0 and i*j%k==0 then say(32,'x*y/z',i,j,k) end
        end

        for k=0,100-1 do
            if i*j+k<=100 and i*j%10+k%10<10 then
                -- 33. multiplication and carry-save addition (x*y+z)
                say(33,'x*y+z:1',i,j,k)

                -- 34. carry-save addition and multiplication (x+y*z)
                say(34,'x+y*z:1',k,i,j)
            end

            -- 35. multiplication and subtraction without abdication (x*y-z)
            if i*j-k>=0 and i*j%10>=k%10 then say(35,'x*y-z:1',i,j,k) end

            -- 36. subtraction without abdication and multiplication (x-y*z)
            if k-i*j>=0 and k%10>=i*j%10 then say(36,'x-y*z:1',k,i,j) end

            if i*j+k<=100 and i*j%10+k%10>=10 then
                -- 37. multiplication and addition with carry (x*y+z)
                say(37,'x*y+z:2',i,j,k)

                -- 38. addition with carry and multiplication (x+y*z)
                say(38,'x+y*z:2',k,i,j)
            end

            -- 39. multiplication and subtraction with abdication (x*y-z)
            if i*j-k>=0 and i*j%10<k%10 then say(39,'x*y-z:2',i,j,k) end

            -- 40. subtraction with abdication and multiplication (x-y*z)
            if k-i*j>=0 and k%10<i*j%10 then say(40,'x-y*z:2',k,i,j) end

            if i~=0 and j+k<=100 and j%10+k%10<10 then
                -- 41. division and carry-save addition (x/y+z)
                say(41,'x/y+z:1',i*j,i,k)

                -- 42. carry-save addition and division (x+y/z)
                say(42,'x+y/z:1',k,i*j,i)
            end

            -- 43. division and subtraction without abdication (x/y-z)
            if i~=0 and j-k>=0 and j%10>=k%10 then say(43,'x/y-z',i*j,i,k) end

            -- 44. subtraction without abdication and division (x-y/z)
            if i~=0 and k-j>=0 and k%10>=j%10 then say(44,'x-y/z:1',k,i*j,i) end

            if i~=0 and j+k<=100 and j%10+k%10>=10 then
                -- 45. division and addition with carry (x/y+z)
                say(45,'x/y+z:2',i*j,i,k)

                -- 46. addition with carry and division (x+y/z)
                say(46,'x+y/z:2',k,i*j,i)
            end

            -- division and subtraction with abdication (not exist)
            if i~=0 and j-k>=0 and j%10<k%10 then say('not exist','x/y-z',i*j,i,k) end

            -- 47. subtraction with abdication and division (x-y/z)
            if i~=0 and k-j>=0 and k%10<j%10 then say(47,'x-y/z:2',k,i*j,i) end
        end
    end
end

-- grade 2 semester 2
-- from 48 to 53, all operands are multiples of 10
for i=100,1000-100,100 do
    for j=100,1000-100,100 do
        -- 48. addition of whole 100 (x+y)
        if i+j<=1000 then say(48,'x+y:9/10',floor(i/10),floor(j/10),floor((i+j)/10)) end

        -- 49. subtraction of whole 100 (x-y)
        if i>=j then say(49,'x-y:9/10',floor(i/10),floor(j/10),floor((i-j)/10)) end
    end
end

for i=10,1000-10,10 do
    for j=10,1000-10,10 do
        -- 50. carry-save addition of whole 100 and whole 10 (x+y)
        if i+j<=1000 and i%100+j%100<100 then say(50,'x+y:a/10',floor(i/10),floor(j/10),floor((i+j)/10)) end

        -- 51. addition with carry of whole 100 and whole 10 (x+y)
        if i+j<=1000 and i%100+j%100>=100 then say(51,'x+y:b/10',floor(i/10),floor(j/10),floor((i+j)/10)) end

        -- 52. subtraction without abdication of whole 100 and whole 10 (x-y)
        if i>=j and i%100>=j%100 then say(52,'x-y:a/10',floor(i/10),floor(j/10),floor((i-j)/10)) end

        -- 53. subtraction with abdication of whole 100 and whole 10 (x-y)
        if i>=j and i%100<j%100 then say(53,'x-y:b/10',floor(i/10),floor(j/10),floor((i-j)/10)) end
    end
end

for i=1, 53 do
    shuffle(data[i])
    local file = io.open(i..'.txt', 'w+')
    file:write(concat(data[i], '\n'))
    file:close()
end

