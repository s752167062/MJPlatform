--[[
自定义游戏盾
多个备用组key可选
]]

UrNetMgr = {}
UrNetMgr.BASE_GROUP_KEY_LIST = {
	[1] = { key = 1 , group = "http://pic.58pic.com/58pic/15/54/06/30J58PICqMA_1024.png" },
	[2] = { key = 2 , group = "http://pic.58pic.com/58pic/14/80/54/79b58PICrq8_1024.jpg" },
	[3] = { key = 3 , group = "http://www.taopic.com/uploads/allimg/140126/234794-140126145J946.jpg" },
} --基础的本地组key列表 （一个游戏配备多个基础组，服务器会下发一个优先组，在优先组获取不到的情况下才使用基础的 , 基础的组不应该被移除 ， 优先组有可能被重新分配给其他游戏）
UrNetMgr.GROUP_FILE_NAME = "GROUP_NET%d.json"
UrNetMgr.DOWNLOAD_MAX  = 3

UrNetMgr.ip_list = {} --组名包含的地址
UrNetMgr.list_index = 1 --地址遍历开始位置
UrNetMgr.ipAfterDownload = true --在下载完之后才能获取IP
UrNetMgr.ERR_MSG = ""
UrNetMgr.group_index = 1 --当前使用的组 
function UrNetMgr:init()
	--
	print = release_print
	self:baseGroupRand()
	self:initGroupkey()
	-- self:initGroupIpList()
	-- self:randTheIndex()--随机下开始读取的位置
end

--对本地基础组做随机的重排(不包含优先组)
function UrNetMgr:baseGroupRand()
	if #UrNetMgr.BASE_GROUP_KEY_LIST > 1 then 
		math.randomseed(os.time())
		local frist_index = math.random(1,#UrNetMgr.BASE_GROUP_KEY_LIST)
		local frist_ = UrNetMgr.BASE_GROUP_KEY_LIST[frist_index]
		UrNetMgr.BASE_GROUP_KEY_LIST[frist_index] = UrNetMgr.BASE_GROUP_KEY_LIST[1]
		UrNetMgr.BASE_GROUP_KEY_LIST[1]			  = frist_
		print(">> UrNetMgr rand index to frist :" , frist_index)
	end	
	print_r(UrNetMgr.BASE_GROUP_KEY_LIST)
end
--使用本地存储的key (初始有一个基础的，后面服务器下发新的会替换本地的那份文件)
function UrNetMgr:initGroupkey()
	local Group_key = cc.UserDefault:getInstance():getStringForKey("Group_key")
	if Group_key ~= nil and Group_key ~= "" then 
		print(">> UrNetMgr add the server group")
		local group = { key = #UrNetMgr.BASE_GROUP_KEY_LIST + 1 , group = Group_key } 
		table.insert(UrNetMgr.BASE_GROUP_KEY_LIST, 1 , group)
	end	
	print(">> UrNetMgr use Group_key #list:", #UrNetMgr.BASE_GROUP_KEY_LIST)
end

--修改本地使用的key (修改组后 重新下载新的组和初始化新IP组)
function UrNetMgr:changeGroupKey(newkey)
	if newkey ~= nil and newkey ~= "" then 
		print(">> UrNetMgr set new Group_key :", newkey)
		-- local Group_key = cc.UserDefault:getInstance():getStringForKey("Group_key")
		-- local Group_key = UserDefault:getKeyValue("Group_key", nil)
		if Group_key ~= nil and Group_key ~= "" then
			--如果原本就有存优先组
			local group = { key = #UrNetMgr.BASE_GROUP_KEY_LIST  , group = newkey } 
			UrNetMgr.BASE_GROUP_KEY_LIST[1] = group
		else
			--新加的优先组
			local group = { key = #UrNetMgr.BASE_GROUP_KEY_LIST +1 , group = newkey } 
			table.insert(UrNetMgr.BASE_GROUP_KEY_LIST, 1 , group)
		end	

		print_r(UrNetMgr.BASE_GROUP_KEY_LIST)

		local function callback()
			--检查如果新的组文件正常下载才存储这个组 (不轻易抛弃上一个可用的组)
			local writeablePath = cc.FileUtils:getInstance():getWritablePath()
			local isExist = cc.FileUtils:getInstance():isFileExist(writeablePath .. UrNetMgr.GROUP_FILE_NAME)
			if isExist then
				-- cc.UserDefault:getInstance():setStringForKey("Group_key", newkey)
				-- UserDefault:setKeyValue("Group_key", newkey)
				-- UserDefault:write()
			else
				UrNetMgr.ERR_MSG = UrNetMgr.ERR_MSG .. " 新的Group文件下载失败"
			end	
		end

		--下载最新的那个
		UrNetMgr.group_index = 1
		local group = UrNetMgr.BASE_GROUP_KEY_LIST[1];
		local filename = string.format(UrNetMgr.GROUP_FILE_NAME , group.key) --优先组的key = 3
		local url = group.group
		print(">> UrNetMgr download the group file : ", filename)
		self:downloadGroupFile(url, filename ,callback )
	else
		UrNetMgr.ERR_MSG = UrNetMgr.ERR_MSG .. " 新Group_key空的"
	end	
end

function UrNetMgr:initGroupIpList(key)
	--本地的服务文件
	local filename = ""
	local url = ""
	if key == nil or key == "" then
		local group = UrNetMgr.BASE_GROUP_KEY_LIST[ UrNetMgr.group_index ]
		filename = string.format(UrNetMgr.GROUP_FILE_NAME , group.key)
		url = group.group
	else
		filename = string.format(UrNetMgr.GROUP_FILE_NAME , key)
		url = group.group
	end	
	print(">> UrNetMgr initGroupIpList filename :", filename )

	local writeablePath = cc.FileUtils:getInstance():getWritablePath()
	local isExist = cc.FileUtils:getInstance():isFileExist(writeablePath .. filename)
	if isExist then 
		--json
		local str_data   = cc.FileUtils:getInstance():getStringFromFile(writeablePath .. filename)
		if str_data ~= nil and str_data ~= "" then 
			print(">> UrNetMgr:initGroupIpList read Group file succefull !" , str_data)
			-- UrNetMgr.ip_list = json.decode(str_data) or {}
		else
			print(">> UrNetMgr:initGroupIpList read Group file err ! download a new one")
			--读取失败的情况重新下载一份
			self:downloadGroupFile(url,filename ,nil)
		end	
	else
		--没有发现文件：下载一份
		print(">> UrNetMgr:initGroupIpList download a Group file ")
		self:downloadGroupFile(url,filename ,nil)
	end
end	

--下载新的需要时间，是否等下完再获取到IP (删除原本旧的组文件，下载新的组文件) (多次下载依然失败?是否用回基础的)
function UrNetMgr:downloadGroupFile(url ,filename ,callback )
	if filename == nil or filename == "" then 
		print(">> UrNetMgr downloadGroupFile filename nil ")
		return
	end
	if url == nil or url == "" then 
		print(">> UrNetMgr downloadGroupFile url nil ")
		return
	end	

	-- local url = url --下载地址
	local writeablePath = cc.FileUtils:getInstance():getWritablePath()
	local isExist = cc.FileUtils:getInstance():isFileExist(writeablePath .. filename)
	if isExist then 
		os.remove(writeablePath..filename)
		print(">> UrNetMgr remove old Group file : ",filename)
	end	
	--是否要下载完才能获取到IP?

	local download_times = 1
	local function downloadcall()
		--检查是否下载完成 (回调这里请求是通的)
		local isExist = cc.FileUtils:getInstance():isFileExist(writeablePath .. filename)
		if isExist then 
			print(">> UrNetMgr download new Group file finish !")
			self:initGroupIpList()--重新初始组的IP (这里会有一个情况， 在下载完成之前如果存在网络请求会用到旧的组 IP)
			if callback ~= nil then 
				callback() --下载结束返回回调
			end	
		else
			--下载失败 ：重新下载 
			download_times = download_times +1
			if download_times <= UrNetMgr.DOWNLOAD_MAX then 
				print(">> UrNetMgr download new Group file failed ! , download it again !" , download_times)
				self:downloadNetFile(url , filename , downloadcall , errfunc)
			elseif callback ~= nil then 
				UrNetMgr.ERR_MSG = UrNetMgr.ERR_MSG .. " 下载Group文件失败"
				callback() --下载结束返回回调
			end	
		end	
	end
	local function errfunc()
		--请求不通，切换下载下一个组文件
		print(">> UrNetMgr downloadNetFile errfunc")
		UrNetMgr.ERR_MSG = UrNetMgr.ERR_MSG .. " 下载Group文件下载失败"
		self:useNextGroupFile()
	end
	self:downloadNetFile(url , filename , downloadcall , errfunc)
end

--使用下一个组
function UrNetMgr:useNextGroupFile()
	UrNetMgr.group_index = UrNetMgr.group_index +1 
	if UrNetMgr.group_index > #UrNetMgr.BASE_GROUP_KEY_LIST then
		-- UrNetMgr.group_index = 1
		print(">> UrNetMgr useNextGroupFile all the group err (start at index 1)")
		return
	end	

	print(">> UrNetMgr use next group : ",UrNetMgr.group_index)
	self:initGroupIpList()
end

function UrNetMgr:getGroupIp()
	if UrNetMgr.ip_list ~= nil then
		return UrNetMgr.ip_list[UrNetMgr.list_index] 
	end	
	UrNetMgr.ERR_MSG = UrNetMgr.ERR_MSG .. " 没有获取到IP"
	return nil --
end

function UrNetMgr:setNext()
	UrNetMgr.list_index = UrNetMgr.list_index +1
end

--随机下开始的index
function UrNetMgr:randTheIndex()
	if UrNetMgr.ip_list ~= nil and #UrNetMgr.ip_list > 1 then 
		math.randomseed(os.time())
	    UrNetMgr.list_index = math.random(1,#UrNetMgr.ip_list)
	    print(">> UrNetMgr randTheIndex ip start at ", UrNetMgr.list_index)
	end    	
end

function UrNetMgr:getErrMsg()
	print(">> UrNetMgr ERR_MSG ::: " , UrNetMgr.ERR_MSG)
	local msg = UrNetMgr.ERR_MSG or ""
	UrNetMgr.ERR_MSG = "" --清除原本的错误信息
	return msg
end
--下载
function UrNetMgr:downloadNetFile(url , filename , callfunc , errfunc)
	print(">> UrNetMgr downloadNetFile url filename : ",url , filename)
    if url == nil or filename == nil then
    	print(">> UrNetMgr download miss url or filename !")
        return 
    end
    local callfunc = callfunc
    local errfunc  = errfunc
    if true then
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
        xhr:open("GET", url)
        local function onReadyStateChanged()
            if xhr.readyState == 4 and xhr.status == 200 then
                local response = xhr.response
                local size     = table.getn(response)
                print(">> UrNetMgr Http Status Code:" .. xhr.statusText .. ",size=" .. size)
                local file = io.open(cc.FileUtils:getInstance():getWritablePath().."/"..filename,"wb")
                for i = 1, size do
                    file:write(string.char(response[i]))
                end
                file:close() 

                print(">> UrNetMgr downloadNetFile do callfunc",callfunc)
                if type(callfunc) == "function" then 
                    callfunc() 
                end 
            else
                print(">> UrNetMgr xhr.readyState is:" .. xhr.readyState .. ",xhr.status is: " .. xhr.status)
                print(">> UrNetMgr downloadNetFile do err callfunc",errfunc)
                if type(errfunc) == "function" then 
                	errfunc()
                end	
            end
            xhr:unregisterScriptHandler()
        end
        xhr:registerScriptHandler(onReadyStateChanged)
        xhr:send()
    end
end











