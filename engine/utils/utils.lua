function math.clamp(min, value, max)
    if min > max then min, max = max, min end
    return math.max(min, math.min(max, value))
end

function math.lerp(a, b, t)
    if type(a) == "table" and type(b) == "table" and a.x and a.y and b.x and b.y then
        return Vector(
            math.lerp(a.x, b.x, t),
            math.lerp(a.y, b.y, t)
        )
    end
    return a + t * (b - a)
end

local serpent = require "lib.serpent.serpent"
vardump = function(...)
    local args = {...}
    print("================VARDUMP=====================")
    if #args == 1 then
        print(serpent.block(args))
    else
        for key, value in pairs(args) do
            if key then print(key..':') end
            print(serpent.block(value))
        end
    end
    print("============================================")
end

local Utils = {}

Utils.importRecursively = function (path, resultList)
    local lfs = love.filesystem
    local files = lfs.getDirectoryItems(path)
    resultList = resultList or {}
    for _, file in ipairs(files) do
        if file and file ~= ''  then -- packed .exe finds "" for some reason
            local path_to_file = path..'/'..file
            if love.filesystem.getInfo(path_to_file).type == 'file' then
                local requirePath = path_to_file:gsub('/', '.'):gsub('%.lua$', '')
                local newFile = require(requirePath)
                table.insert(resultList, newFile)
            elseif love.filesystem.getInfo(path_to_file).type == 'directory' then
                Utils.importRecursively(path_to_file, resultList)
            end
        end
    end
    return resultList
end

-- see associateBy() in Kotlin
Utils.associateBy = function(t, keySelector, valueTransform)
    local result = {}
    valueTransform = valueTransform or function(v) return v end
    for k, v in pairs(t) do
        result[keySelector(v, k)] = valueTransform(v, k)
    end
    return result
end

-- it's like #t but working not only on ipairs
Utils.count = function(t)
    local n = 0
    for _, _ in pairs(t) do
        n = n + 1
    end
    return n
end

-- see Object.assign() in JS
-- example: Utils.assign({foo = 1, baz = 2}, {foo = 2, fooz = 3}, {foo = 5, ff = 11}) => {foo = 5, baz = 2, fooz = 3, ff = 11}
-- shallow copy, target can be {} to not modify it
Utils.assign = function (target, ...)
    local sources = {...}
    if not target then target = {} end
    for _, source in pairs(sources) do
        for k, v in pairs(source) do
            target[k] = v
        end
    end
    return target
end

Utils.mergeAndClone = function (from, to) -- shallow copy of 'to' with replased values from 'from' table
    local result = {}
    if not from then from = {} end
    for k, v in pairs(to) do
        result[k] = v
    end
    for k, v in pairs(from) do
        result[k] = v
    end
    return result
end

Utils.colorFromHex = function (hex, value)  -- s-walrus/hex2color
    return {tonumber(string.sub(hex, 1, 2), 16)/256, tonumber(string.sub(hex, 3, 4), 16)/256, tonumber(string.sub(hex, 5, 6), 16)/256, value or 1}
end

function vectorsToVerticies(array)
    local result = {}
    for _, point in pairs(array) do 
        local x, y = point:unpack()
        table.insert(result, x)
        table.insert(result, y)
    end
    return result
end

function verticiesToVectors(array)
    local result = {}
    for ind, point in pairs(array) do
        if ind % 2 ~= 0 then
            result[math.floor(ind/2)] = Vector(point, 0)
        else
            result[math.floor(ind/2)-1].y = point
        end
    end
    return result
end

return Utils