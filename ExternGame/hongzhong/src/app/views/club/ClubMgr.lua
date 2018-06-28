
-- function copyTable(_t1, _t2)
-- 	local function func(t1, t2)
-- 		for key, var in pairs(t1) do
-- 			if type(var) == "table" then
-- 				t2[key] = {}
-- 				func(var, t2[key])
-- 			else	
-- 				t2[key] = var
-- 			end
-- 		end
-- 	end
-- 	if _t2 == nil then _t2 = {} end
-- 	func(_t1, _t2)
-- 	return _t2
-- end

-- CLUB_PATH = "app/views/club/"

-- --成员信息
-- local memberInfo = 
-- {
-- 	photoPath = "",
-- 	id = "",
-- 	name = "",
	
-- }
-- --战绩信息
-- local combatGainsInfo = 
-- {
	
-- }
-- --游戏管理
-- local gameMgr = 
-- {
	
-- }
-- --俱乐部信息
-- local clubInfo = 
-- {
-- 	name = "",
-- 	id = "",
-- 	ownerId = "",
-- 	ownerName = "",
-- 	introduce = "",
-- 	introduceDesc = "",
-- 	noticeDesc = "",
-- 	createTime = "",
-- 	location_province = "",
-- 	location_city = "",
-- 	location_area = "",
-- 	condition = 0,
	
-- 	setting = {},
-- 	managerList = {},
-- 	memberList = {},
-- 	roomList = {},
	
	
-- }

-- local ClubMgr = class("ClubMgr")
-- function ClubMgr:ctor()
--     self._netStatus = false
-- 	self._clubProtocol = require(CLUB_PATH.."ClubProtocol").new(self)
-- 	self._callFuncTb = {}
-- 	self._uiTb = {}
	
-- 	self._isAgent = false
-- 	self._joinClubNum = 0
	
-- 	self._clubInfoList = {}
	
-- end

-- --初始网络
-- function ClubMgr:openNet(_func)
--     self._callFuncTb["openNet"] = _func
	

-- end

-- --关闭网络
-- function ClubMgr:closeNet(_func)
--     self._callFuncTb["closeNet"] = _func
	
	
-- end

-- --获取网络状态
-- function ClubMgr:getNetStatus()
--     return self._netStatus
-- end

-- --打开主菜单
-- function ClubMgr:openMainUI()
--     if self._netStatus == true then
-- 		--是否代理
-- 		if self._isAgent == false then
-- 			--加入俱乐部数量
-- 			if self._joinClubNum <= 0 then
-- 				self:getUIObj("UI_ClubMain"):show()
-- 			else
			
-- 			end
-- 		else
			
-- 		end
-- 	end
-- end

-- --关闭所有ui(俱乐部相关)
-- function ClubMgr:closeAllUI()
    
-- end

-- --清空数据
-- function ClubMgr:clearCache()
    
-- end

-- --==============================self=====================================
-- --封装打开ui
-- function ClubMgr:getUIObj(_uiName)
-- 	print("use uiName:".._uiName)
-- 	local obj = require(CLUB_PATH.._uiName)
-- 	table.insert(self._uiTb, obj)
-- 	return obj
-- end

-- --添加俱乐部
-- function ClubMgr:insertClub(_res)
-- 	local obj = copyTable(clubInfo)
-- 	obj.name = _res.name
	
-- 	table.insert(self._clubInfoList, obj)
-- end

-- --获取俱乐部
-- function ClubMgr:getClub()
-- 	--暂时默认1
-- 	return self._clubInfoList[1]
-- end

-- return ClubMgr