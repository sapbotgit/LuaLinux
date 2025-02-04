-- DO NOT DELETE
-- Exception: Want to rewrite 90% of code
local cfg = require("../config")
local curdir = {"root"}

local function repeatString(str, times)
    local result = ""
    for i = 1, times do
        result = result .. str
    end
    return result
end

local files = {
    ["root"] = {},
    ["dev"] = {
        ["zero"] = repeatString("0", 1000)
    },
    ["etc"] = {},
    ["home"] = {},
    ["lib"] = {},
    ["media"] = {},
    ["mnt"] = {},
    ["opt"] = {},
    ["proc"] = {},
    ["sbin"] = {},
    ["run"] = {},
    ["sys"] = {},
    ["srv"] = {},
    ["usr"] = {},
    ["tmp"] = {},
    ["var"] = {}
}

local function round(exact)
    return tonumber(string.format("%.0f", exact))
end

local function percentage(v, o, t)
    if v == 0 then
        return 0
    end
    return round((v / o) * t)
end

local function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

local function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

local function genpath(listpath)
    if listpath == {} then
        return "/"
    end
    return "/" .. table.concat(listpath, "/")
end

local function getkeys(tab)
    local keyset={}
    local n=0
    for k,v in pairs(tab) do
        n=n+1
        keyset[n]=k
    end
    return keyset
end

local function clear()
    if not os.execute("clear") then
        os.execute("cls")
    elseif not os.execute("cls") then
        for i = 1,25 do
            print("\n\n")
        end
    end    
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function has_value_l(tabls, val)
    if has_value(tabls, val) then
        return true
    end
    for index, tabl in ipairs(tabls) do
        if type(tabl) == "table" then
            if has_value(getkeys(tabl), val) then
                return true
            end
        end
    end
    return false
end

local function osname()
    local sep = package.config:sub(1,1)
    if sep == "\\" then
        return "Windows"
    elseif sep == "/" then
        return "Linux"
    else
        return "Unknown"
    end
end

local function rawScandir(directory)
    local i, t = 0, {}
    local cmmd = {
        ["Windows"] = 'dir "'..directory..'" /b',
        ["Linux"] = 'ls -a "'..directory..'"'
    }
    local pfile = io.popen(cmmd[osname()])
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

-- Function to access the value in A using the path in B
local function getNestValue(A, B)
    local current = A
    for _, key in ipairs(B) do
        if current[key] then
            current = current[key]
        else
            return nil -- Return nil if the path does not exist
        end
    end
    return current -- Return the final value
end

local function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

return {
    osname = osname,
    mysplit = mysplit,
    has_value = has_value,
    clear = clear,
    getkeys = getkeys,
    TableConcat = TableConcat,
    genpath = genpath,
    rawScandir = rawScandir,
    serializeTable = serializeTable,
    repeatString = repeatString,
    getNestValue = getNestValue,
    curdir = curdir,
    round = round,
    percentage = percentage,
    has_value_l = has_value_l,
    files = files
}
