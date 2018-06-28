
--判断玩家加入房间后同IP提示

local PlayerIPTips = {}
--local Tips    = import(".TipsGps")

local IPTab = {} --用于存放每个人玩家的ip
function PlayerIPTips:playerIn(data,showp,scene)
	self:addNodeToScene()

	if GameRule.cur_GameCNT > 1 then return end --这个人已经加入过房间了，不进行IP判断

	self:setData(data,showp)
	local str = self:getShowStr()

	if str == nil or #str == 0 then return end
	if scene and scene.isWatch then return end
	self:delayToRun(str)
end 

function PlayerIPTips:addNodeToScene()
	local scene = cc.Director:getInstance():getRunningScene()
	local base = scene:getChildByName("PLAYERIP_TIPS")
	if base == nil then 
		base = cc.Node:create()
		base:setName("PLAYERIP_TIPS")
		scene:addChild(base)

		base:registerScriptHandler(function(state)
			if state == "enterTransitionFinish" then 
				self:onEnter()
			elseif state == "exit" then 
				self:onExit(base)
			end 
		end)
	end 
end 

function PlayerIPTips:onEnter()
	CCXNotifyCenter:listen(self,function(_,_,data) self:playerRemove(data) end ,"playerRemove")
end 

function PlayerIPTips:onExit(base)
	cclog("longma onExit","PlayerIPTips")
	self:cleanAll()
	base:unregisterScriptHandler()
	CCXNotifyCenter:unListenByObj(self)
end 

function PlayerIPTips:setData(data,showp)
	cclog("longma setData",data.id,showp)
	IPTab[data.id] = data
end 

function PlayerIPTips:hasData(showp)
	return IPTab[showp] ~= nil
end 

function PlayerIPTips:getShowStr()
	cclog("longma getShowStr")
	print_r(IPTab)

	local data = {1}
	for k,v in pairs(IPTab) do
		if k ~= PlayerInfo.playerUserID then 
			table.insert(data,v)
		end 
	end 

	local ret = {}
	-- local baseStr = "注意：%s玩家与%s玩家的IP相同！"
	if data[2] and data[3] and self:ipEquals(data[2],data[3]) then 
		-- str = string.format(baseStr,data[2].name,data[3].name)
		table.insert(ret,{{str = data[2].name,color = cc.c3b(255,255,0)},
			{str = " 与 ",color = cc.c3b(230,230,230)},
			{str = data[3].name,color = cc.c3b(255,255,0)},
			{str = " IP相同 ",color = cc.c3b(230,230,230)},
		})
	end 
	if data[3] and data[4] and self:ipEquals(data[3],data[4]) then 
		-- str = str .."\n" .. string.format(baseStr,data[3].name,data[4].name)
		table.insert(ret,{{str = data[3].name,color = cc.c3b(255,255,0)},
			{str = " 与 ",color = cc.c3b(230,230,230)},
			{str = data[4].name,color = cc.c3b(255,255,0)},
			{str = " IP相同",color = cc.c3b(230,230,230)},
		})
	end 
	if data[4] and data[2] and self:ipEquals(data[2],data[4]) then 
		-- str = str .."\n" .. string.format(baseStr,data[4].name,data[2].name)
		table.insert(ret,{{str = data[2].name,color = cc.c3b(255,255,0)},
			{str = " 与 ",color = cc.c3b(230,230,230)},
			{str = data[4].name,color = cc.c3b(255,255,0)},
			{str = " IP相同",color = cc.c3b(230,230,230)},
		})
	end 

	return ret
end 

function PlayerIPTips:showTips(str)
	local runningScene = cc.Director:getInstance():getRunningScene()
	local node = runningScene:getChildByName("IPTips_Layer")
	if node ~= nil then 
		node:setText(str)
		return 
	else
		-- node = Tips.new()
		-- node:setText(str)
		-- node:setName("IPTips_Layer")
	end 

	runningScene:addChild(node,100)
end 

local buff = {}
function PlayerIPTips:delayToRun(str)
	table.insert(buff,str)
	local scheduler = cc.Director:getInstance():getScheduler()  
    local schedulerID = nil
    local callfunc = function(_str) self:showTips(_str) end 
    schedulerID = scheduler:scheduleScriptFunc(function()  
        if callfunc and #buff > 0 and buff[1] ~=nil then 
        	local _str = buff[1]
        	callfunc(_str)
        	table.remove(buff,1)
        	-- buff[1] = nil
       	end
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
    end,0.2,false)
end

function PlayerIPTips:playerRemove(id)
	cclog("longma playerRemove")
	IPTab[id] = nil
end 

-- 判断IP是否相同
function PlayerIPTips:ipEquals(data1,data2)
	if data1.ip == nil or data2.ip == nil then return false end

	if data1.id == data2.id then return false end 

	if data1.ip:find("0.0.0.0") or data2.ip:find("0.0.0.0") then 
		return false
	end 

	if data1.ip == "" or data2.ip == "" then return false end 

	local ipTab1 = Util.split(data1.ip,".")
	local ipTab2 = Util.split(data2.ip,".")

	if #ipTab1 <= 2 or #ipTab2 <= 2 then return false end 

	local ret = true
	for i =1 ,4 do
		if ipTab1[i] ~= ipTab2[i] then 
			ret = false
			break
		end 
	end 

	return ret
end 

-- 无法获取IP
function PlayerIPTips:canNotGetIp(data)
	if data.ip == "" or data.ip == " " then return true end 
	if data.ip == nil then return true end 

	if data.ip:find("0.0.0.0") then return true end 
end 

function PlayerIPTips:cleanAll()
	IPTab = {}
	buff = {}
end 

return PlayerIPTips