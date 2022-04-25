--- ("Hello")[1] = H
debug.getmetatable("").__index = function(self, n)
    if (type(n) == "number") then
        return self:sub(n, n)
    end  

    return string[n]
end

-- AAABBBCCC
string.delrep = function(text)
    local cs = text:sub(1, 1)
    local r = cs
    for s in text:gmatch(".") do
        if (cs ~= s) then
            cs = s
            r = r .. cs
        end
    end

    return r
end

-- ("Hello World!"):slpit()
string.split = function(text, sep)
    local result = {}
    local i = 1
    for s in text:gmatch("[^"..sep.."]+") do
        result[i] = s
        i = i + 1
    end
    return result
end

-- Sub s
assert(("Hello")[1] == "H", "ERROR SUB first symbol not 'H'")

-- Delete rep
assert(("AABBBCCCCD"):delrep() == "ABCD", "ERROR DELREP result not 'ABCD'")

-- Split
assert(("Hello World"):split(" ")[1] == "Hello", "ERROR SPLIT result not 'Hello'")
