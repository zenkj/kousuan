local concat = table.concat
local insert = table.insert

local random = math.random
local floor = math.floor

local data = {}

for i=1, 53 do
    data[i] = {}
end

local function say(fd, ...)
    insert(data[fd], concat({...}, ' '))
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
        -- 1. addition within 10
        if i+j<=10 then say(1, i, j) end

        -- 2. subtraction within 10
        if i<=10 and i-j>=0 then say(2, i, j) end

        -- 3. carry-save addition within 20
        if (i>=10 or j>=10) and i+j<=20 then say(3, i, j) end

        -- 4. subtraction without abdication within 20
        if i>=10 and i-j>=0 and i%10>=j%10 then say(4, i, j) end

        -- 5. addition with carry within 20
        if i<10 and j<10 and i+j>10 then say(5, i, j) end

        -- 6. subtraction with abdication within 20
        if i-j>0 and i%10<j%10 then say(6, i, j) end

        for k=0,20 do
            -- 7. continuous addition within 10
            if i+j+k <= 10 then say(7, i, j, k) end

            -- 8. continuous subtraction within 10
            if i<=10 and i-j-k>=0 then say(8, i, j, k) end

            -- 9. subtraction and addition within 10
            if i<=10 and i-j>=0 and i-j+k<=10 then say(9, i, j, k) end

            -- 10. addition and subtraction within 10
            if i+j<=10 and i+j-k>=0 then say(10, i, j, k) end

            -- 11. continuous addition within 20
            if i+j+k>10 and i+j+k<=20 then say(11, i, j, k) end

            -- 12. continuous subtraction within 20
            if i>10 and i-j-k>=0 then say(12, i, j, k) end

            -- 13. subtraction and addition within 20
            if i-j>=0 and i-j+k>10 and i-j+k<=20 then say(13, i, j, k) end

            -- 14. addition and subtraction within 20
            if i+j<=20 and i+j-k>=0 then say(14, i, j, k) end
        end
    end
end

-- grade 1 semester 2
for i=20,100 do
    for j=0,100,10 do
        -- 15. carry-save addition of whole 10 within 100
        if i+j<=100 then say(15, i, j); say(15, j, i) end

        -- 16. subtraction without abdication of whole 10 within 100
        if i-j>=0 then say(16, i, j) end
    end 
end

for i=10,100 do
    for j=0,10-1 do
        -- 17. carry-save addition of single digit within 100
        if i+j<=100 and i%10+j<10 then say(17,i,j); say(17,j,i) end

        -- 18. subtraction without abdication of single digit within 100
        if i-j>=0 and i%10>=j then say(18,i,j) end

        -- 19. addition with carry of single digit within 100
        if i+j<=100 and i%10+j>=10 then say(19,i,j) end

        -- 20. subtraction with abdication of single digit within 100
        if i-j>=0 and i%10<j then say(20,i,j) end
    end
end

for i=10,100-1 do
    for j=10,100-1 do
        -- 21. carry-save addition of double-digit within 100
        if i+j<=100 and i%10+j%10<10 then say(21,i,j) end

        -- 22. subtraction without abdication of double-digit within 100
        if i-j>=0 and i%10>=j%10 then say(22,i,j) end

        -- 23. addition with carry of double-digit within 100
        if i+j<=100 and i%10+j%10>=10 then say(23,i,j) end

        -- 24. subtraction without abdication of double-digit within 100
        if i-j>=0 and i%10<j%10 then say(24,i,j) end
    end 
end

-- 25. continuous addition within 100
for i=0,100-1 do
    for j=0,100-1 do
        for k=0,100-1 do
            if i+j+k<=100 and i+j+k>20 then say(25,i,j,k) end
        end
    end
end

-- 26. continous subtraction within 100
for i=21,100-1 do
    for j=0,100-1 do
        for k=0,100-1 do
            if i-j-k>=0 then say(26,i,j,k) end
        end
    end
end

-- grade 2 semester 1
for i=0,10-1 do
    for j=0,10-1 do
        -- 27. multiplication within table
        say(27,i,j)

        -- 28. division within table
        if i~=0 then say(28,i*j,i) end

        for k=0,10-1 do
            if i*j<10 or j*k<10 or i*k<10 then
                -- 29. continuous multiplication within table
                say(29,i,j,k)

                -- 30. continuous division within table
                if i~=0 and j~=0 then say(30,i*j*k,i,j) end
            end
            -- 31. division and multiplication within table
            if i~=0 then say(31,i*j,i,k) end

            -- 32. multiplication and division within table
            if k~=0 and i*j%k==0 then say(32,i,j,k) end
        end

        for k=0,100-1 do
            if i*j+k<=100 and i*j%10+k%10<10 then
                -- 33. multiplication and carry-save addition
                say(33,i,j,k)

                -- 34. carry-save addition and multiplication
                say(34,k,i,j)
            end

            -- 35. multiplication and subtraction without abdication
            if i*j-k>=0 and i*j%10>=k%10 then say(35,i,j,k) end

            -- 36. subtraction without abdication and multiplication
            if k-i*j>=0 and k%10>=i*j%10 then say(36,k,i,j) end

            if i*j+k<=100 and i*j%10+k%10>=10 then
                -- 37. multiplication and addition with carry
                say(37,i,j,k)

                -- 38. addition with carry and multiplication
                say(38,k,i,j)
            end

            -- 39. multiplication and subtraction with abdication
            if i*j-k>=0 and i*j%10<k%10 then say(39,i,j,k) end

            -- 40. subtraction with abdication and multiplication
            if k-i*j>=0 and k%10<i*j%10 then say(40,k,i,j) end

            if i~=0 and j+k<=100 and j%10+k%10<10 then
                -- 41. division and carry-save addition
                say(41,i*j,i,k)

                -- 42. carry-save addition and division
                say(42,k,i*j,i)
            end

            -- 43. division and subtraction without abdication
            if i~=0 and j-k>=0 and j%10>=k%10 then say(43,i*j,i,k) end

            -- 44. subtraction without abdication and division
            if i~=0 and k-j>=0 and k%10>=j%10 then say(44,k,i*j,i) end

            if i~=0 and j+k<=100 and j%10+k%10>=10 then
                -- 45. division and addition with carry
                say(45,i*j,i,k)

                -- 46. addition with carry and division
                say(46,k,i*j,i)
            end

            -- division and subtraction with abdication (not exist)
            if i~=0 and j-k>=0 and j%10<k%10 then say('not exist',i*j,i,k) end

            -- 47. subtraction with abdication and division
            if i~=0 and k-j>=0 and k%10<j%10 then say(47,k,i*j,i) end
        end
    end
end

-- grade 2 semester 2
for i=100,1000-100,100 do
    for j=100,1000-100,100 do
        -- 48. addition of whole 100
        if i+j<=1000 then say(48,i,j) end

        -- 49. subtraction of whole 100
        if i>=j then say(49,i,j) end
    end
end

for i=10,1000-10,10 do
    for j=10,1000-10,10 do
        -- 50. carry-save addition of whole 100 and whole 10
        if i+j<=1000 and i%100+j%100<100 then say(50,i,j) end

        -- 51. addition with carry of whole 100 and whole 10
        if i+j<=1000 and i%100+j%100>=100 then say(51,i,j) end

        -- 52. subtraction without abdication of whole 100 and whole 10
        if i>=j and i%100>=j%100 then say(52,i,j) end

        -- 53. subtraction with abdication of whole 100 and whole 10
        if i>=j and i%100<j%100 then say(53,i,j) end
    end
end

for i=1, 53 do
    shuffle(data[i])
    local file = io.open(i..'.txt', 'w+')
    file:write(concat(data[i], '\n'))
    file:close()
end

