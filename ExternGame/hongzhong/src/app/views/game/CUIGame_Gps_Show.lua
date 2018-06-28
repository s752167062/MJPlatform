local CUIGame_Gps_Show = class("CUIGame_Gps_Show",ex_fileMgr:loadLua("packages.mvc.ViewBase"))

local json = ex_fileMgr:loadLua("app.helper.dkjson")

CUIGame_Gps_Show.RESOURCE_FILENAME = "gps/CUIGame_Gps_Show.csb"
CUIGame_Gps_Show.RESOURCE_BINDING = {
	["bg1"] = {["varname"] = "bg1" ,  ["events"] = { {event = "click" ,  method ="onClickBtnClose"    } } },
	["txt_tips"] = {["varname"] = "txt_tips"},
	["Node_1"] = {["varname"] = "Node_1"},
	["Node_2"] = {["varname"] = "Node_2"},
	["Node_3"] = {["varname"] = "Node_3"},
	["Node_4"] = {["varname"] = "Node_4"},
	["dis_12"] = {["varname"] = "dis_12"},
	["dis_13"] = {["varname"] = "dis_13"},
	["dis_14"] = {["varname"] = "dis_14"},
	["dis_23"] = {["varname"] = "dis_23"},
	["dis_24"] = {["varname"] = "dis_24"},
	["dis_34"] = {["varname"] = "dis_34"},
	["line_12"] = {["varname"] = "line_12"},
	["line_13"] = {["varname"] = "line_13"},
	["line_14"] = {["varname"] = "line_14"},
	["line_23"] = {["varname"] = "line_23"},
	["line_24"] = {["varname"] = "line_24"},
	["line_34"] = {["varname"] = "line_34"},
}

function CUIGame_Gps_Show:onCreate()
	self.showLimit = 100 --少于这个距离就报警
	self.animatTab = {}  --需要变色的控件
	self.isRed     = false --变色 红色?
	self.updateT   = 0
end 

function CUIGame_Gps_Show:onEnter()
    local function handler(t)
        self:update(t)
    end
    self:scheduleUpdateWithPriorityLua(handler,0)
end 

function CUIGame_Gps_Show:onExit()
	
end 

function CUIGame_Gps_Show:initSuper(super)
	self.super = super
end

function CUIGame_Gps_Show:update(t)
	self.updateT = self.updateT + t
	if self.updateT < 0.5 then return end
	if self.isRed then 
		for k,v in ipairs(self.animatTab) do
			v:setColor(cc.c3b(255,0,0))
		end 
	else
		for k,v in ipairs(self.animatTab) do
			v:setColor(cc.c3b(255,255,255))
		end 
	end 

	self.updateT = 0
	self.isRed = not self.isRed
end 
-- players 玩家信息
-- location 玩家位置信息
-- locCount 玩家距离信息
function CUIGame_Gps_Show:refreshUI(players, location, locCount)
	print("longma CUIGame_Gps_Show refreshUI ",locCount)

	self:showPlayerLine(true,cc.c3b(255,255,255))
	local names = {}
	local tips = ""
	for k,v in ipairs(players) do
		local id = v.id
		if id and id ~= 0 then 
			names[id] = v.name
			self["Node_" .. k]:setVisible(true)
			self["Node_" .. k]:getChildByName("btn_point"):setBright(location[id] ~= nil)
			if not location[id] then
				self:hidePlayerLine(k,"color",cc.c3b(25,25,25))
			end 
		else
			self["Node_" .. k]:setVisible(false)
			self:hidePlayerLine(k,"hide")
		end 
	end 

	self.animatTab = {}
	for k,v in self:pairsByKeys(locCount) do
		if v.dis ~= -1 and v.dis <= self.showLimit then 
			table.insert(self.animatTab,self["line_" .. k])
			table.insert(self.animatTab,self["dis_" .. k])
		end 
	end 
	for k,v in pairs(locCount) do
		if v.dis ~= -1 then 
			local dis = self:changeToKM(v.dis)
			self["dis_" .. k]:setVisible(true)
			self["dis_" .. k]:setString(dis)
			self["dis_" .. k]:setColor(cc.c3b(255,255,255))

			self["line_" .. k]:setVisible(true)
			self["line_" .. k]:setColor(cc.c3b(255,255,255))
		else
			self["dis_" .. k]:setVisible(false)
		end 
	end 
end

function CUIGame_Gps_Show:changeToKM(data)
	if data ~= -1 then 
		if data <= 1000 then 
			data = string.format("%.2fm",data)
		else
			data = string.format("%.2fkm",data / 1000)
		end 
	end 

	return data
end

-- 隐藏与第k玩家连接的线
-- 或改变颜色
function CUIGame_Gps_Show:hidePlayerLine(key,flag,color)
	for i = 1,4 do 
		for j = i,4 do
			if j ~= i then 
				if i == key or j == key then 
					if flag == "hide" then 
						self["line_" ..i ..j]:setVisible(false)
					elseif flag == "color" then 
						self["line_" ..i ..j]:setColor(color)
					end 
				end 
			end 
		end 
	end
end 

-- 显示/隐藏所有的线
function CUIGame_Gps_Show:showPlayerLine(flag,color)
	for i = 1,4 do 
		for j = i,4 do
			if j ~= i then 
				self["line_" ..i ..j]:setVisible(flag)
				if color then 
					self["line_" ..i ..j]:setColor(color)
				end 
			end 
		end 
	end
end

function CUIGame_Gps_Show:hideBackGround()
	self.bg1:setVisible(false)
	self.bg1:setTouchEnabled(false)
end 

function CUIGame_Gps_Show:onClickBtnClose()
	if self.super and self.super.closeGpsMap then 
		self.super:closeGpsMap()
	end
end 

function CUIGame_Gps_Show:pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do 
        table.insert(a, n) 
    end
    table.sort(a, f)
    local i = 0                 -- iterator variable
    local iter = function ()    -- iterator function
       i = i + 1
       if a[i] == nil then return nil
       else return a[i], t[a[i]]
       end
    end
    return iter
end

return CUIGame_Gps_Show