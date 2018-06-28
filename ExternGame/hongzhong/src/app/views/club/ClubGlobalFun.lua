
ClubGlobalFun = {}
local BaseError_Club  = ex_fileMgr:loadLua("app.views.club.UI_CommonMsg")
local BaseError_Club2 = ex_fileMgr:loadLua("app.views.club.UI_CommonMsg2")

--俱乐部通用提示
function ClubGlobalFun:showError(msg,ok,back,showmode)
    local _tmp = cc.Director:getInstance():getRunningScene():getChildByTag(MSG_TAG)
    if _tmp then
        cc.Director:getInstance():getRunningScene():removeChildByTag(MSG_TAG)
    end
   
    local data = {err = msg,flag = showmode,ok = ok,cancel=back}
    local err = BaseError_Club.new(data)
    err:setTag(MSG_TAG)
    
    cc.Director:getInstance():getRunningScene():addChild(err,100)
end

function ClubGlobalFun:showInviteMsg(_data)
    local _tmp = cc.Director:getInstance():getRunningScene():getChildByTag(MSG_TAG)
    if _tmp then
        cc.Director:getInstance():getRunningScene():removeChildByTag(MSG_TAG)
    end
   
    local err = BaseError_Club2.new(_data)
    err:setTag(MSG_TAG)
    cc.Director:getInstance():getRunningScene():addChild(err,100)
end

--返回身份 posi(0：会员 1：管理员 2：会长)
function ClubGlobalFun:getIdentity(_num)
	_num = tonumber(_num)
	if _num == 0 then
		return "会员"
	elseif _num == 1 then
		return "管理员"
	elseif _num == 2 then
		return "会长"
	end
	return "未知"
end

--计算字符串长度
function ClubGlobalFun:calculateStringLen(_str, _fontSize)
	local lenInByte = #_str
	local width = 0
	local height = 0
	 
	for i = 1, lenInByte do
		local curByte = string.byte(_str, i)
		local byteCount = 1
--		print("curByte:"..curByte)
		if curByte > 0 and curByte <= 127 then			--字母数字(英文)
--			print("byteCount == 1")
			byteCount = 1
		elseif curByte >= 192 and curByte <= 223 then
--			print("byteCount == 2")
			byteCount = 2
		elseif curByte >= 224 and curByte < 239 then	--文字
--			print("byteCount == 3")
			byteCount = 3
		elseif curByte >= 240 and curByte <= 247 then	
--			print("byteCount == 4")
			byteCount = 4
		else	--中文符号
--			print("byteCount == 5")
			byteCount = 5
		end
		 
		local char = string.sub(_str, i, i + byteCount - 1)
		i = i + byteCount -1

--		print("byteCount:"..byteCount)
		if byteCount == 1 then
--			width = width + _fontSize * 0.5
			local tempW = _fontSize * (14 / 26)
			width = width + tempW
		elseif byteCount == 2 or byteCount == 3 or byteCount == 4 then
--			width = width + _fontSize
			local tempW = _fontSize * (29 / 26)
			width = width + tempW
		else
			width = width + 1
		end
	end
	width = math.modf(width)
	height = math.modf(_fontSize * (34 / 26))-- + _fontSize * 0.1
--	print("总宽度:"..width.." 高度:"..height.." 字体大小:".._fontSize)
	return width, height
end

--判断是否有艾特我信息
function ClubGlobalFun:judgeAITEMsgForMe(_content)
	local c1 = "@"
	local c2 = '\001'.." "

	local data = string.split(_content, c1)
	for i, v in ipairs(data) do
		if i > 1 then
			local lineData = string.split(v, c2)
			if #lineData > 1 then
				--ID转玩家名
				local ID = tonumber(lineData[1])
				if ID == PlayerInfo.playerUserID then
					return true
				end
			end
		end
	end
	return false
end

--计算非顺序tb长度
function ClubGlobalFun:getLenForTb(_tb)
	local count = 0
	for i, v in pairs(_tb) do
		count = count + 1
	end
	return count
end