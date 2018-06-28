local CUIGame_Gps = class("CUIGame_Gps",ex_fileMgr:loadLua("packages.mvc.ViewBase"))

local json = ex_fileMgr:loadLua("app.helper.dkjson")

CUIGame_Gps.RESOURCE_FILENAME = "gps/CUIGame_Gps.csb"
CUIGame_Gps.RESOURCE_BINDING = {
	["btn_gps"] = {["varname"] = "btn_gps" ,  ["events"] = { {event = "click" ,  method ="onClickBtnGps"    } } },
}

local GPSShowView = ex_fileMgr:loadLua("app.views.game.CUIGame_Gps_Show")
-- scene 房间界面
function CUIGame_Gps:onCreate()
	cclog("longma onCreate")
	self.platfrom = cc.Application:getInstance():getTargetPlatform()
    self.location = {}        --玩家的位置信息 {id = {-1,-1},}
    self.locCount = {}        --玩家的距离信息 {12 = 123.11,}
    self.player   = {}        --所有玩家的信息
    self.myLocation = {-1,-1} --精度,纬度
    self.myLocation_old = {-1,-1} --精度,纬度
    self.updateTimeUpload = 0        --定时器跑的时间 发数据
    self.updateTimeDownload = 0      --定时器跑的时间 拿数据
    self.intervalUpload = 3		     --向服务器发数据的间隔
    self.intervalDownload = 5        --向服务器拿数据的间隔
    self.isDelay = false
end 

function CUIGame_Gps:onEnter()
	CCXNotifyCenter:listen(self,function(_,_,data) self:onServerGetAllPlayersGps(data) end,"onServerGetAllPlayersGps")
	CCXNotifyCenter:listen(self,function(_,_,data) self:stopGPSUpdate(data) end,"onNotifyUserDisMiss")
	CCXNotifyCenter:listen(self,function(_,_,data) self:retrySocket(data) end,"ROOM_SOCKET_RETRY")

	
	SDKController:getInstance():set_GPS_Location_Callfunc(handler(self,self.gpsUpdate))
	self:sendProtocal("getAllPlayersGps")

	self.btn_gps:setBright(false)
	--注册计时器
    local function handler(t)
        self:update(t)
    end
    self:scheduleUpdateWithPriorityLua(handler,0)
end 

function CUIGame_Gps:onExit()
	SDKController:getInstance():Stop_GPS()
    CCXNotifyCenter:unListenByObj(self)
end 

function CUIGame_Gps:update(t)
	--发数据
	self.updateTimeUpload = self.updateTimeUpload + t
	if self.updateTimeUpload >= self.intervalUpload then 
		self.updateTimeUpload = 0
		self:sendData()
	end

	--拿数据
	self.updateTimeDownload = self.updateTimeDownload + t
	if self.updateTimeDownload >= self.intervalDownload then 
		self.intervalDownload = self.isDelay and self.intervalDownload + 2 or self.intervalDownload
		self.intervalDownload = self.intervalDownload > 30 and 30 or self.intervalDownload
		self.updateTimeDownload = 0
		self:sendProtocal("getAllPlayersGps")
	end 
end 

-- 向服务器发送数据
function CUIGame_Gps:sendData()
	if self.myLocation_old[1] and tonumber(self.myLocation_old[1]) > 0.1 then
		if self.myLocation_old[1] ~= self.myLocation[1] or self.myLocation_old[2] ~= self.myLocation[2] then 
			self.myLocation[1] = self.myLocation_old[1]
			self.myLocation[2] = self.myLocation_old[2]
			self:sendProtocal("requestLocation",json.encode(self.myLocation))
		end
	end 
end 

-- 从主界面调用过来的函数
function CUIGame_Gps:refreshUI(players, isDelay)
	cclog("longma CUIGame_Gps refreshUI",#players)
	self.location = self.location or {}
	self.isDelay = isDelay
	self.player = clone(players)

	self:getDisAndShow()
end 

--gps状态 地址刷新
-- data.state = "place" 地址更新， = "state" 状态更新
function CUIGame_Gps:gpsUpdate(data)
	cclog("longma gpsUpdate",data)
	local pos = Util.split(data,",")
	if self.myLocation[1] == -1 then 
		self:sendProtocal("requestLocation",json.encode(pos))
	end 

	self.myLocation_old[1] = tonumber(pos[1])
	self.myLocation_old[2] = tonumber(pos[2])

	self.btn_gps:setBright(pos[1] ~= -1)
end 

function CUIGame_Gps:onClickBtnGps()
	cclog("longma onClickBtnGps")
	if not self.showView then 
		self.showView = GPSShowView.new()
		self.showView:initSuper(self)
		self.showView:refreshUI(self.player,self.location , self.locCount)
		self:getParent():getParent():addChild(self.showView)

		self:sendProtocal("getAllPlayersGps")
	end 
end 

function CUIGame_Gps:onServerGetAllPlayersGps(data)
	for i,v in ipairs(data) do
		local location = json.decode(v.location)
		-- 自己把所有人的gps信息保存起来
		self.location[v.playerid] = location
	end 

	self:getDisAndShow()
end 

function CUIGame_Gps:showGpsMap()
	if not self.showView then 
		self.showView = GPSShowView.new()
		self.showView:initSuper(self)
		showView:hideBackGround()
		showView:refreshUI(self.player,self.location,self.locCount)
		self:getParent():getParent():addChild(self.showView)

		self:sendProtocal("getAllPlayersGps")
	end 
end

function CUIGame_Gps:closeGpsMap()
	if self.showView ~= nil then 
		self.showView:removeFromParent()
		self.showView = nil
	end 
end

function CUIGame_Gps:getDisAndShow()
	local player = self.player
	if player[1] == nil then return end 
	
	self.locCount = {}
	for i = 1,4 do 
		for j = i,4 do
			if j ~= i then 
				if player[i] and player[j] then 
					local idI = player[i].id or 0
					local idJ = player[j].id or 0
					if idI ~= 0 and idJ ~= 0 then 
						self.locCount[i .. j] = {dis = self:getDistanceById(idI,idJ),i = idI ,j = idJ}
					else
						self.locCount[i .. j] = {dis = -1 ,i = idI,j = idJ}
					end
				end 
			end 
		end 
	end

	if self.showView then 
		print("longma showView",self.locCount)
		self.showView:refreshUI(player, self.location, self.locCount)
	end 
end 

function CUIGame_Gps:changeToKM(data)
	if data ~= -1 then 
		if data > 1000 then 
			data = string.format("%.2f 千米",data/1000)
		else
			data = string.format("%.2f 米",data)
		end 
	end 

	return data
end

local pi = math.pi
local EARTH_RADIUS = 6378.137
function CUIGame_Gps:rad(d)
	return d * math.pi / 180
end 

-- 获取两点间的距离
function CUIGame_Gps:getDistance(lat1,lng1,lat2,lng2)
	local radLat1 = self:rad(lat1)
	local radLat2 = self:rad(lat2)
	local a = radLat1 - radLat2
	local b = self:rad(lng1) - self:rad(lng2)

	local s = 2 * math.asin(math.sqrt(math.pow(math.sin(a/2),2) +
    math.cos(radLat1)*math.cos(radLat2)*math.pow(math.sin(b/2),2)));

	s = s * EARTH_RADIUS
	return s * 1000
end 

-- 从两个人的id获取距离 
-- ret -1为距离计算失败
function CUIGame_Gps:getDistanceById(id1,id2)
	local a1 = self.location[id1]
	local a2 = self.location[id2]
	if not a1 or not a2 then 
		return -1
	end
	local lng1 ,lat1 = tonumber(a1[1] + 0.99) ,tonumber(a1[2] + 0.99)
	local lng2 ,lat2 = tonumber(a2[1] + 0.99) ,tonumber(a2[2] + 0.99)

	if a1[1] ~= -1 and a1[2] ~= -1 and a2[1] ~= -1 and a2[2] ~= -1 then 
		if lng1 >= 1 and lat1 >= 1 and lng2 >= 1 and lat2 >= 1 then 
			return self:getDistance(a1[2],a1[1],a2[2],a2[1])
		end 
	end 

	return -1
end 

function CUIGame_Gps:stopGPSUpdate(data)
	-- body
	if data.state == 0 then --有人不同意解散
		return 
	end
	SDKController:getInstance():Stop_GPS()
	self:unscheduleUpdate()
end

-- 发送协议到服务器
function CUIGame_Gps:sendProtocal(method, ...)
	if self.retryState then 
		return 
	end

	if GameClient.server and ClientController and ClientController[method] then  
		ClientController[method](...)
	end
end

-- state:true 重连中 false 重连成功
function CUIGame_Gps:retrySocket(state)
	self.retryState = state
end
return CUIGame_Gps