local ClubMgr = class("ClubMgr")

function ClubMgr:ctor()

	self.iconList = {}
    local iconDir = __platformHomeDir .."ui/image_club/com_icon/"
    for i =1, 10 do
    	self.iconList[i] = {id =tostring(i), path = string.format("%sicon%d.png", iconDir, i)}
    end

    self:init()
end

function ClubMgr:init()
	self.info = {
		clubName = "",
		clubId = 0,

		huiZhangName = "",
		huiZhangId = 0,
		guanLiYuanName = "",
		guanLiYuanId = 0,

	}

end

function ClubMgr:getInfoByKey(key)
	return self.info[key]
end

function ClubMgr:setInfo(key, data)
	self.info[key] = data
end

--id是string
function ClubMgr:getIconPathById(id)
	local path = ""
	for k,v in pairs(self.iconList) do
		if v.id == id then
			path = v.path
			break
		end
	end
	return path
end

function ClubMgr:getIconList()
	return self.iconList
end

function ClubMgr:canGuanli(isShowHint, msg)
	local myId = gameConfMgr:getInfo("userId")
	myId = tonumber(myId)


	local huiZhangId = self:getInfoByKey("huiZhangId")
	local guanLiYuanId = self:getInfoByKey("guanLiYuanId")

	cclog("ClubMgr:canGuanli >>>", myId, huiZhangId, guanLiYuanId)
	if myId == huiZhangId or myId == guanLiYuanId then
		return true
	else
		if isShowHint then
			msgMgr:showToast(msg or "只有会长和管理员才能进行操作", 3)
		end
		return false
	end
end


return ClubMgr





