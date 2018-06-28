UserDefault = {}

UserDefault.keys = nil

UserDefault.byteKey = 2 --加密key，大小为一个字节

function UserDefault:setKeyValue(key , value)
    --self:clean()
    if self.keys == nil then
        self.keys = self:read()
    end
    if self.keys == nil then
        self.keys = {}
    end
	self.keys[key] = value
end

function UserDefault:getKeyValue(key,value)
    if self.keys == nil then
        self.keys = self:read()
    end
    if self.keys ~= nil and self.keys[key] ~= nil then
        return self.keys[key]
    else
        return value
    end
end

function UserDefault:write()
    UserDefault:setKeyValue("localdata",nil)
    local json = ex_fileMgr:loadLua("app.helper.dkjson")
    local path = ex_fileMgr:getWritablePath() .. "UDInfo.json" --可写目录
    local tableStr = json.encode(self.keys)

    local secretStr = cpp_string_bit_xor(tableStr, UserDefault.byteKey)
--    for i = 1, string.len(tableStr) do
--        secretStr = string.format("%s%c",secretStr,self:bitXor(string.byte(tableStr,i,i+1),2))
--        --cclog("tableStr :" .. string.format("%c",string.byte(tableStr,i,i+1)))
--    end
    ccx_write(path,secretStr)
end

function UserDefault:read()
    local json = ex_fileMgr:loadLua("app.helper.dkjson")
    local path = ex_fileMgr:getWritablePath() .. "UDInfo.json"
    local tableStr = ccx_read(path)
    if tableStr == nil or tableStr == "" then
    	return nil
    end
    local secretStr = cpp_string_bit_xor(tableStr, UserDefault.byteKey)
    return json.decode(secretStr)
--    for i = 1, string.len(tableStr) do
--        secretStr = string.format("%s%c",secretStr,self:bitXor(string.byte(tableStr,i,i+1),2))
--    end
--    if secretStr == "" then--decode_str == "null" or decode_str == "" then
--        return {}
--    else
--        return json.decode(secretStr)
--    end 
end

function UserDefault:writeFile(filename , context)
	local path = ex_fileMgr:getWritablePath()..filename..".cc"
	if path ~= nil then
		ccx_write(path, context)
	end
end

function UserDefault:readFile(filename)
	local context = nil
    local path = ex_fileMgr:getWritablePath()..filename..".cc"
    if path ~= nil then 
        context = ccx_read(path)    
    end
 
	return context 
end

function UserDefault:cleanFile(filename)
    local path = ex_fileMgr:getWritablePath() .. filename..".cc"
    ccx_write(path,"")--清空文件
end

function UserDefault:clean()
    local path = ex_fileMgr:getWritablePath() .. "UDInfo.json"
    UserDefault.keys = {}
    ccx_write(path,"")--清空文件
end

function UserDefault:bitXor(srcNum,bitNum)
    local src_tb = self:to2(srcNum)
    local bit_tb = self:to2(bitNum)
    for i = 1, 8 do
        if src_tb[i] ~= bit_tb[i] then
            src_tb[i] = 1
        else
            src_tb[i] = 0
        end
    end
    local num = 0
    for i=1,8 do
        num = num + src_tb[i]*math.pow(2,8-i)
    end
    return num
end

function UserDefault:to2(num)
    local num_tb = {}
    for i=8,1,-1 do
        if num > 0 then
            num_tb[i] = num % 2
            num = math.floor(num/2)
        else
            num_tb[i] = 0
        end
    end
    return num_tb
end