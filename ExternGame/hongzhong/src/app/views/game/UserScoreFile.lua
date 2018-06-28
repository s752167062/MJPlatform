-- ex_fileMgr:loadLua("mime")

UserScoreFile = {}



local path = ex_fileMgr:getWritablePath()
UserScoreFile.records_rootDir = path .. "records/" --记录的根目录
UserScoreFile.max_round = 10  --保存的最多大局数

-- 服务器约定来源类型
UserScoreFile.originType_0 = 0  -- 普通房间
UserScoreFile.originType_1 = 1  -- 俱乐部







--==============  dkjson  string code block >> begin ======================

local floor, huge = math.floor, math.huge
local strrep, gsub, strsub, strbyte, strchar, strfind, strlen, strformat =
      string.rep, string.gsub, string.sub, string.byte, string.char,
      string.find, string.len, string.format
local strmatch = string.match
local concat = table.concat

local function fsub (str, pattern, repl)
  -- gsub always builds a new string in a buffer, even when no match
  -- exists. First using find should be more efficient when most strings
  -- don't contain the pattern.
  if strfind (str, pattern) then
    return gsub (str, pattern, repl)
  else
    return str
  end
end

local function quotestring (value)
  -- based on the regexp "escapable" in https://github.com/douglascrockford/JSON-js
  value = fsub (value, "[%z\1-\31\"\\\127]", escapeutf8)
  if strfind (value, "[\194\216\220\225\226\239]") then
    value = fsub (value, "\194[\128-\159\173]", escapeutf8)
    value = fsub (value, "\216[\128-\132]", escapeutf8)
    value = fsub (value, "\220\143", escapeutf8)
    value = fsub (value, "\225\158[\180\181]", escapeutf8)
    value = fsub (value, "\226\128[\140-\143\168-\175]", escapeutf8)
    value = fsub (value, "\226\129[\160-\175]", escapeutf8)
    value = fsub (value, "\239\187\191", escapeutf8)
    value = fsub (value, "\239\191[\176-\191]", escapeutf8)
  end
  return "\"" .. value .. "\""
end

local escapecodes = {
  ["\""] = "\\\"", ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f",
  ["\n"] = "\\n",  ["\r"] = "\\r",  ["\t"] = "\\t"
}

local function escapeutf8 (uchar)
  local value = escapecodes[uchar]
  if value then
    return value
  end
  local a, b, c, d = strbyte (uchar, 1, 4)
  a, b, c, d = a or 0, b or 0, c or 0, d or 0
  if a <= 0x7f then
    value = a
  elseif 0xc0 <= a and a <= 0xdf and b >= 0x80 then
    value = (a - 0xc0) * 0x40 + b - 0x80
  elseif 0xe0 <= a and a <= 0xef and b >= 0x80 and c >= 0x80 then
    value = ((a - 0xe0) * 0x40 + b - 0x80) * 0x40 + c - 0x80
  elseif 0xf0 <= a and a <= 0xf7 and b >= 0x80 and c >= 0x80 and d >= 0x80 then
    value = (((a - 0xf0) * 0x40 + b - 0x80) * 0x40 + c - 0x80) * 0x40 + d - 0x80
  else
    return ""
  end
  if value <= 0xffff then
    return strformat ("\\u%.4x", value)
  elseif value <= 0x10ffff then
    -- encode as UTF-16 surrogate pair
    value = value - 0x10000
    local highsur, lowsur = 0xD800 + floor (value/0x400), 0xDC00 + (value % 0x400)
    return strformat ("\\u%.4x\\u%.4x", highsur, lowsur)
  else
    return ""
  end
end

--==============  dkjson  string code block >> end ======================


function UserScoreFile:data_write(file, data, indent_count)
    indent_count = indent_count or 1
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
            self:data_write(file, v, indent_count +1)
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
                    local tmp = mime.b64(v)
                    tmp_v = string.format("\"%s|StringForBase64\"", tmp)
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


function UserScoreFile:saveToFile(tab, fname)
    local file = io.open( fname .. ".lua", "w")
    self:data_write(file, tab, nil)
    io.close(file)

    cclog("UserScoreFile:saveToFile >>>", fname)

    -- local dkj = ex_fileMgr:loadLua("app.helper.dkjson")
    -- local tmp = {}
    -- for k,v in ipairs(tab) do
    --     table.insert(tmp,v)
    -- end
    -- tab = tmp
    -- print_r(tab)
    -- local str = dkj.encode(tab)
    
    -- local utils = ex_fileMgr
    -- local path = fname .. ".lua"
    -- local file = io.open( path, "w")
    -- io.close(file)
    -- if utils:isFileExist(path) and str then
    --     ccx_write(path, str)
    -- end
end

function UserScoreFile:decodeTableBase64Str(tab)
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

function UserScoreFile:readFromFile(fname)

    local utils = ex_fileMgr
    local data = {}
    local path = fname .. ".lua"
    if utils:isFileExist(path) then
        
        --容错机制
        xpcall(function () 
                data = dofile(path)
            end, __G__TRACKBACK__)
    end

    cclog("UserScoreFile:readFromFile >>", data, path)

    data = data or {}
    self:decodeTableBase64Str(data)
    return data


    -- local dkj = ex_fileMgr:loadLua("app.helper.dkjson")
    -- local utils = ex_fileMgr
    -- local data = {}
    -- local path = fname .. ".lua"
    -- if utils:isFileExist(path) then
    --     local str = ccx_read(path)
    --     data = dkj.decode(str)
    -- end

    -- cclog("UserScoreFile:readFromFile >>", data, path)

    -- return data or {}

end

function UserScoreFile:copyFile(srcPath, desPath)
    local utils = ex_fileMgr
    srcPath = srcPath .. ".lua"
    desPath = desPath .. ".lua"

    if srcPath == desPath then return end
    
    if not utils:isFileExist(srcPath) then 
        cclog("UserScoreFile:copyFile >> not found file", srcPath)
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

function UserScoreFile:getOriginTypeDirPath(originType)
    local utils = ex_fileMgr
    local dir = string.format("%soriginType_%s/", UserScoreFile.records_rootDir, originType)

    if not utils:isDirectoryExist(dir) then
        utils:createDirectory(dir)
    end

    return dir
end

function UserScoreFile:getOriginKeyDirPath(originType, originKey)
    local utils = ex_fileMgr

    local otDir = self:getOriginTypeDirPath(originType)
    local dir = string.format("%sorigin_%s/", otDir, originKey)

    if not utils:isDirectoryExist(dir) then
        utils:createDirectory(dir)
    end

    return dir
end

function UserScoreFile:getUniqueKeyVideoDir(originType, originKey, uniqueKey)
    local utils = ex_fileMgr

    local originDir_path = self:getOriginKeyDirPath(originType, originKey)
    local uniqueKey_videoDir = originDir_path .. uniqueKey .. "/"

    if not utils:isDirectoryExist(uniqueKey_videoDir) then
        utils:createDirectory(uniqueKey_videoDir)
    end

    return uniqueKey_videoDir
end




















 -- local utils = ex_fileMgr
 -- utils:createDirectory()
 --  utils:isFileExist(filename)
--  local path = utils:getWritablePath()
-- utils:removeFile(path)
-- utils:isDirectoryExist(path)
-- utils:removeDirectory(path) 

--[[
    originType 类型索引值, 本文前几行跟服务器约定了来源 UserScoreFile.originType_
    originKey  来源索引值，根据使用的值来分类（ 用俱乐部id则为该俱乐部的记录），该值意味着创建该来源的数据文件夹
    uniqueKey  唯一值，该房间的唯一值（自己定义，目前我以房间号来做唯一值），通过该值来创建该房间的录像数据文件夹
    data  数据table
    branchId  小局索引
    
    例如：originType = 1 则，目录结构是 records/originType_1/    (俱乐部的记录)
        originKey = 123456 则，目录结构是 records/originType_1/origin_123456/123456.lua   (origin_123456 该俱乐部123456的数据，123456.lua 该俱乐部数据大纲，大纲内每个房间都有uniqueKey去映射它的录像目录)
        且 uniqueKey = 10086 则，目录结构是 records/originType_1/origin_123456/10086/   （10086 唯一索引创建的录像目录）
        且 roomId = 888000 , branchId = 1 则 records/originType_1/origin_123456/10086/888000_1.lua  (意思为 888000 房间的 第 1 小局的录像数据)

    映射关系由 1.lua 的uniqueKey 找到 10086 这个目录，获取这个目录的录像
]]
function UserScoreFile:setRecardData(originType, originKey, uniqueKey, data, branchId)
    
    local record_data = UserScoreFile:readFileByOriginKey(originType, originKey)
    
    data.uniqueKey = uniqueKey


    for k,v in pairs(record_data) do
        -- 保存uniqueKey的第一小局数据的时候，发现有数据了，则意味着这个roomdata是重复的，清除它的相关信息
        if v.uniqueKey == uniqueKey and branchId == 1 and v.branch and next(v.branch) then
            table.remove(record_data, k)
            self:deleteUniqueKeyVedioDir(originType, originKey, uniqueKey)
            break
        end
    end

    -- 拿列表最后一个的房间数据,从1开始
    local room_data = record_data[#record_data == 0 and 1 or #record_data]


    --如果没有数据就新建一条，如果有数据但是uniqueKey不一样也新建一条
    --如果有数据，uniqueKey也是一样的，那就意味着还是这个房间的数据，所以继续记录该房间数据
    if not room_data or room_data.uniqueKey ~= uniqueKey then   
        room_data = {}
        record_data[#record_data +1] = room_data
        room_data.uniqueKey = uniqueKey
    end

    --  如果设置的不是这条房间的数据，则不设置
    if room_data.uniqueKey ~= uniqueKey then return end 


    if #record_data > UserScoreFile.max_round then   -- 记录只记录最新n条
        self:deleteUniqueKeyVedioDir(originType, originKey, record_data[1].uniqueKey)
        table.remove(record_data, 1)
    end



    --data里的小局数变量名字必须为currLevel

    local branch = room_data.branch or {}
    room_data.branch = branch
    
    if branchId and data.branch then -- 如果设置小局数据，则找到该小局，设置该房间小局数据
        -- branch[branchId] = data.branch

        local isfind = false
        for k,v in pairs(branch) do
            if v.currLevel == data.branch.currLevel then --找到当局数据则覆盖
                isfind = true
                branch[k] = data.branch
                break
            end
        end

        if not isfind then -- 未找到则新建
            branch[#branch +1] = data.branch
        end
    end

    for k,v in pairs(data) do
        if k ~= "branch" then  -- 除了小局数据的其他数据
            room_data[k] = v
        end
    end


    self:saveFileByOriginKey(originType, originKey, record_data)
end



function UserScoreFile:readFileByOriginKey(originType, originKey)

    local dir_path = self:getOriginKeyDirPath(originType, originKey)
    local origin_file = dir_path .. originKey

    local record_data = self:readFromFile(origin_file)

    -- print_r(record_data)

    return record_data
end


function UserScoreFile:saveFileByOriginKey(originType, originKey, record_data)

    local dir_path = self:getOriginKeyDirPath(originType, originKey)
    local fname = dir_path .. originKey

   
    self:saveToFile(record_data, fname)

    cclog("UserScoreFile:saveFileByOriginKey >>>", fname)
end


function UserScoreFile:copyVideoByOriginKeyAndUniqueKey(srcFile, originType, originKey, uniqueKey, roomId, branchId)
    local fname = self:getUniqueKeyBranchVideoFilePath(originType, originKey, uniqueKey, roomId, branchId)
    self:copyFile(srcFile, fname)
end

function UserScoreFile:saveVideoByOriginKeyAndUniqueKey(originType, originKey, uniqueKey, roomId, branchId, data)
    
    data.uniqueKey = uniqueKey
    local fname = self:getUniqueKeyBranchVideoFilePath(originType, originKey, uniqueKey, roomId, branchId)
    self:saveToFile(data, fname)

    return fname
end


function UserScoreFile:readVideoByOriginKeyAndUniqueKey(originType, originKey, uniqueKey, roomId, branchId)


    local vedio_file = self:getUniqueKeyBranchVideoFilePath(originType, originKey, uniqueKey, roomId, branchId)

    

    local vedio_data = self:readFromFile(vedio_file)

    -- print_r(vedio_data)

    return vedio_data
end

function UserScoreFile:getUniqueKeyBranchVideoFilePath(originType, originKey, uniqueKey, roomId, branchId)

    local uniqueKey_videoDir = self:getUniqueKeyVideoDir(originType, originKey, uniqueKey)
    local fname = string.format("%s%s_%s", uniqueKey_videoDir, roomId, branchId)

    return fname
end





function UserScoreFile:deleteOriginTypeDir(originType)
    local utils = ex_fileMgr

    local dir = self:getOriginTypeDirPath(originType, originKey)
    if utils:isDirectoryExist(dir) then
        utils:removeDirectory(dir) 
    end
end

function UserScoreFile:deleteOriginKeyFileDir(originType, originKey)
    local utils = ex_fileMgr

    local dir = self:getOriginKeyDirPath(originType, originKey)
    if utils:isDirectoryExist(dir) then
        utils:removeDirectory(dir) 
    end
end


function UserScoreFile:deleteUniqueKeyVedioDir(originType, originKey, uniqueKey)
    local utils = ex_fileMgr

    local dir = self:getUniqueKeyVideoDir(originType, originKey, uniqueKey)
    if utils:isDirectoryExist(dir) then
        utils:removeDirectory(dir) 
    end
end









