Util = {}

-- 字符串切分成数组
function Util.split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

-- 字符串去除指定字符
function Util.removeChar(s , char)
	if type(char) ~= "string" or string.len(char) <= 0  then
		return 
	end
	
	local start = 1 
	local newStr = ""
	while true do
		local pos = string.find(s,char,start,true) 
		if not pos then
			break
		end
		
        newStr = newStr .. string.sub(s, start, pos - 1)
        start = pos + string.len(char)
	end
    newStr = newStr .. string.sub (s, start)
    return newStr
end

function Util.ChangeToYun(baseurl , yunpartment)
    if baseurl ~= nil and yunpartment ~= nil then
		if yunpartment == "" then 
            return baseurl
		end
		
        local last = string.sub(baseurl,string.find(baseurl,":",7,true) , string.len(baseurl))
        if last ~= nil and last ~= "" then 
            return "http://" .. yunpartment .. last
        end
	end
end

function Util.getCenter(s , startstr , endstr)
	if type(s) ~= "string" or string.len(s) <= 0  then
		return nil
	end
	
    local startp = string.find(s,startstr,1,true) + string.len(startstr)
    local endp   = string.find(s,endstr  ,1,true)
    if startp ~= nil and endp ~= nil then
        return string.sub(s,startp ,endp - 1)
    end
    return nil
end

function Util.sort(list, key, desc)
    if list == nil or #list == 0 then
        cclog("************** sort list nil")
        return list
    end

    local function sortFunc(a, b)
        cclog("************** "..key .."   " .. a[key].."  "..type(a[key]))
        cclog("************** "..key .."   " .. b[key].."  "..type(b[key]))
        if desc == true then
            return a[key] > b[key]
        end
        return a[key] < b[key]
    end

    table.sort(list,sortFunc)
    return list
end

---------下载
function Util.DownloadFile(url , filename , callfunc)
    if url == nil or filename == nil then
        return 
    end
    cclog("开始下载文件 " .. url)
    if true then
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
        xhr:open("GET", url)
        local function onReadyStateChanged()
            if xhr.readyState == 4 and xhr.status == 200 then
                local response = xhr.response
                local size     = table.getn(response)
                release_print("Http Status Code:" .. xhr.statusText .. ",size=" .. size)
                local file = io.open(ex_fileMgr:getWritablePath().."/"..filename,"wb")
                for i = 1, size do
                    file:write(string.char(response[i]))
                end
                file:close() 
                if callfunc then 
                    callfunc() 
                end 
            else
                release_print("xhr.readyState is:" .. xhr.readyState .. ",xhr.status is: " .. xhr.status)
            end
            xhr:unregisterScriptHandler()
        end
        xhr:registerScriptHandler(onReadyStateChanged)
        xhr:send()
    end
end

-- http 请求
function Util.getJSONFromUrlOut8(path,func,async)
    local fun = func
    local isTimeOut = false
    local function timeout()
        if isTimeOut == false then 
            if fun ~= nil then
                fun(nil)
                fun = nil
            end
        end   
    end
    GlobalFun:timeOutCallfunc(4 , timeout)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET",path,async)
    --    xhr.timeout = 6  // ???
    local function onReady()
        cclog("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 and isTimeOut == false and fun~= nil then
            fun(xhr.response , nil)
            fun = nil
        elseif fun ~= nil then 
            fun(nil, xhr.status , xhr.response)
            fun = nil
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=utf-8")
    xhr:send()
end

-- http 请求
function Util.getJSONFromUrl(path,fun,async)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET",path,async)
    xhr.timeout = 5
    local function onReady()
        cclog("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 then
            fun(xhr.response , nil)
        else
            fun(nil, xhr.status , xhr.response)
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=utf-8")
    xhr:send()
end

function Util.postJSONFromUrl(path,data,fun,async)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST",path,async)
    xhr.timeout = 5
    local function onReady()
        cclog("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 then
            fun(xhr.response , nil)
        else
            fun(nil, xhr.status)
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=utf-8") 
    xhr:send(data)
end

-- http 请求
function Util.getStringFromUrl(path,fun,async,timeout)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET",path,async)
    xhr.timeout = timeout or 5
    local function onReady()
        cclog("HTTP STATUS :"..xhr.status)
        if xhr.status == 200 then
            fun(xhr.response ,nil )
        else
            fun(nil, xhr.status)
        end
    end
    xhr:registerScriptHandler(onReady)
    xhr:send()
end

--获取公网IP
function Util.getPublicIP(callfunc)
	local publicNet = "http://1212.ip138.com/ic.asp"
    Util.getStringFromUrl(publicNet,callfunc,true);
end

-------------------------------------
--截取指定的位置 i ~ j
--@return 
--      s : 返回的string
--      offset : 返回偏移的 长度  (-  j  +)
function Util.CATString(str , i , j)
    if str == nil or str == "" then
        return 
    end

    local s = ""
    local length = #str
    local offset = 0    
    for index = i, j  do
        local curByte = string.byte(str, index)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end

        local char = ""
        if byteCount > 0 then
            char = string.sub(str, index , index + byteCount - 1)
            index = index + byteCount - 1
        end
        s = s .. char
        offset = j - index
    end

    return s , offset
end

function Util.CATStringWithoutEmoji(str , i , j)
    if str == nil or str == "" then
        return 
    end

    local s = ""
    local length = #str
    local offset = 0    
    for index = i, j  do
        local curByte = string.byte(str, index)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
--        elseif curByte>=240 and curByte<=247 then
--            byteCount = 4
        end

        local char = ""
        if byteCount > 0 then
            char = string.sub(str, index , index + byteCount - 1)
            index = index + byteCount - 1
        end
        s = s .. char
        offset = j - index
    end

    return s , offset
end


function Util.downloadFileFromUrl(url , func)

end


function Util.to_utf8(a)  
    local n, r, u = tonumber(a)  
    if n<0x80 then                        -- 1 byte  
        return char(n)  
    elseif n<0x800 then                   -- 2 byte  
        u, n = tail(n, 1)  
        return char(n+0xc0) .. u  
    elseif n<0x10000 then                 -- 3 byte  
        u, n = tail(n, 2)  
        return char(n+0xe0) .. u  
    elseif n<0x200000 then                -- 4 byte  
        u, n = tail(n, 3)  
        return char(n+0xf0) .. u  
    elseif n<0x4000000 then               -- 5 byte  
        u, n = tail(n, 4)  
        return char(n+0xf8) .. u  
    else                                  -- 6 byte  
        u, n = tail(n, 5)  
        return char(n+0xfc) .. u  
    end  
end  

function Util.HttpCharEncode(str)
    local news = ""
    if str ~= nil and string.len(str) > 0 then
        news = string.gsub(str ,"%%","%%25",nil)
        news = string.gsub(news,"%+","%%2B",nil)
        news = string.gsub(news,"% ","%%20",nil)
        news = string.gsub(news,"%/","%%2F",nil)
        news = string.gsub(news,"%#","%%23",nil)
        news = string.gsub(news,"%&","%%26",nil)
        news = string.gsub(news,"%=","%%3D",nil)
    end
    return news
end

function Util.HttpCharDecode(str)
    local news = ""
    if str ~= nil and string.len(str) > 0 then
        news = string.gsub(str ,"%%2B","%+",nil)
        news = string.gsub(news,"%%20","% ",nil)
        news = string.gsub(news,"%%2F","%/",nil)
        news = string.gsub(news,"%%23","%#",nil)
        news = string.gsub(news,"%%26","%&",nil)
        news = string.gsub(news,"%%3D","%=",nil)
        news = string.gsub(news,"%%25","%%",nil)
    end
    return news
end
