require "mime"
local LuaFileUtils = class("LuaFileUtils")

function LuaFileUtils:data_write(file, data, indent_count, isHavBase64)
    -- indent_count = indent_count or 1
    local indent = ""
    for i = 1, indent_count do
        indent = indent .. "\t"
    end

    if indent_count == 1 then
        file:write(string.format("local data = {\n"))
    end

    local dou_hao = ""
    for k,v in pairs(data) do

        if type(v) == "table" then
            if type(k) == "number" then
                file:write(string.format("%s\n%s[%d] = {", dou_hao, indent, k))
            else
                file:write(string.format("%s\n%s%s = {", dou_hao, indent, k))
            end
            self:data_write(file, v, indent_count +1, isHavBase64)
            file:write(string.format("\n%s}", indent))
        else
            local tmp_k = ""
            if type(k) == "number" then
                tmp_k = string.format("[%d]", k)
            elseif type(k) == "string" then
                tmp_k = k
            end

            local tmp_v = ""
            if type(v) == "number" then
                tmp_v = v
            elseif type(v) == "string" then
                -- tmp_v = quotestring(v)
                if v ~= "" then  -- 空串返回的b64是类型nil，不合需求
                    if isHavBase64 then
                        local tmp = mime.b64(v)
                        tmp_v = string.format("\"%s|StringForBase64\"", tmp)
                    else
                        tmp_v = string.format("\"%s\"", v)
                    end
                else
                    tmp_v = string.format("\"%s\"", v)
                end
            elseif type(v) == "boolean" then
                tmp_v = string.format("%s", v and "true" or "false")
            elseif type(v) == "nil" then
                tmp_v = string.format("%s", "nil")
            end

            file:write(string.format("%s\n%s%s = %s", dou_hao, indent, tostring(tmp_k), tostring(tmp_v)))
        end
        dou_hao = ","
    end

    if indent_count == 1 then
        file:write(string.format("\n}\nreturn data"))
    end
end


function LuaFileUtils:saveToFile(tab, fname, isHavBase64)
    local file = io.open( fname .. ".lua", "w")
    self:data_write(file, tab, 1, isHavBase64)
    io.close(file)

    cclog("LuaFileUtils:saveToFile >>>", fname)


end

function LuaFileUtils:readFromFile(fname, isHavBase64)

    local utils = cc.FileUtils:getInstance()
    local data = {}
    local path = fname .. ".lua"
    if utils:isFileExist(path) then
        
        --容错机制
        xpcall(function () 
                data = dofile(path)
            end, __G__TRACKBACK__)
    end

    cclog("LuaFileUtils:readFromFile >>", data, path)

    data = data or {}

    if isHavBase64 then
        self:decodeTableBase64Str(data)
    end

    return data

end

function LuaFileUtils:decodeTableBase64Str(tab)
    for k,v in pairs(tab) do
        if type(v) == "table" then
            self:decodeTableBase64Str(v)
        else
            if type(v) == "string" then
                cclog("fff", v, string.match(v,"|StringForBase64"))
                if string.match(v,"|StringForBase64") then
                    local tmp = string.gsub(v,"|StringForBase64", "")
                    cclog("decodeTableBase64Str >>", v, tmp)
                    tab[k] = mime.unb64(tmp)
                end
            end
        end
    end
end

function LuaFileUtils:copyFile(srcPath, desPath)
    local utils = cc.FileUtils:getInstance()
    srcPath = srcPath .. ".lua"
    desPath = desPath .. ".lua"

    if srcPath == desPath then return end
    
    if not utils:isFileExist(srcPath) then 
        cclog("LuaFileUtils:copyFile >> not found file", srcPath)
        return 
    end


    local BUFSIZE = 8192
    local f_src = io.open( srcPath, "r")
    local f_des = io.open( desPath, "w")

    if not f_des then 
        io.close(f_src)
        return 
    end 


    while true do
        local lines,rest = f_src:read(BUFSIZE,"*line")
        if not lines then
            break
        end
        if rest then
            lines = lines .. rest .. "\n"
        end
        f_des:write(lines)

    end

    io.close(f_src)
    io.close(f_des)
end


return LuaFileUtils


