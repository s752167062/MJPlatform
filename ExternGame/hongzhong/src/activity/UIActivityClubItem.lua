local uiActivityClubItem = class("uiActivityClubItem", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityClubItem.RESOURCE_FILENAME = "activity2/uiActivityClubItem.csb"
uiActivityClubItem.RESOURCE_BINDING = {
	["bgImage_1"]        = {    ["varname"] = "bgImage_1"     	},
	["bgImage_2"]        = {    ["varname"] = "bgImage_2"     	},
    ["txt_clubname"]        = {    ["varname"] = "txt_clubname"     	},
    ["txt_clubid"]        	= {    ["varname"] = "txt_clubid"     		},
    ["txt_clubusername"]    = {    ["varname"] = "txt_clubusername"     },
    ["txt_clubuserid"]      = {    ["varname"] = "txt_clubuserid"     	},
    ["txt_mynum"]        	= {    ["varname"] = "txt_mynum"     		},
    ["txt_round"]        	= {    ["varname"] = "txt_round"     		},
    ["ctn_icon"]        	= {    ["varname"] = "ctn_icon"     		},
    ["img_select"]        	= {    ["varname"] = "img_select"     		},

    ["ctn_reward"]        	= {    ["varname"] = "ctn_reward"     		},

    ["btn_lingqu_1"]        = {    ["varname"] = "btn_lingqu_1"     	   ,  ["events"] = { {event = "click" ,  method ="onLingqu"    } }  },
    ["btn_lingqu_2"]        = {    ["varname"] = "btn_lingqu_2"     	   ,  ["events"] = { {event = "click" ,  method ="onLingqu"    } }  },
    ["btn_lingqu_3"]        = {    ["varname"] = "btn_lingqu_3"     	   ,  ["events"] = { {event = "click" ,  method ="onLingqu"    } }  },
    ["btn_reason_1"]        	= {    ["varname"] = "btn_reason_1"     	   ,  ["events"] = { {event = "click" ,  method ="onReason"    } }  },
    ["btn_reason_2"]        	= {    ["varname"] = "btn_reason_2"     	   ,  ["events"] = { {event = "click" ,  method ="onReason"    } }  },
    ["btn_reason_3"]        	= {    ["varname"] = "btn_reason_3"     	   ,  ["events"] = { {event = "click" ,  method ="onReason"    } }  },

    ["btn_detail"]      = {    ["varname"] = "btn_detail"              ,  ["events"] = { {event = "click" ,  method ="onDetail"    } }  },
}

function uiActivityClubItem:onCreate()
    cclog("CREATE")
    self.btn_detail:setSwallowTouches(false)
end

function uiActivityClubItem:onEnter()
    cclog("ENTER")
    -- CCXNotifyCenter:listen(self,function(self,obj,data) self:updateItemSelect(data) end ,"onActivityClubListItemSelect")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:removeALLani() 		end ,"onGetActivityUserInfo")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:updateRank(data) 		end, "updateActivityRank")

    local tag = math.fmod(self:getTag() , 2)
    cclog(" #222222 getTag item", self:getTag())
    self.bgImage_1:setVisible(tag == 1)
    self.bgImage_2:setVisible(tag == 0)

end

function uiActivityClubItem:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end

function uiActivityClubItem:initData(data)
	print_r(data)
	self.data = data
	self.txt_clubname:setString(data.clubName or "")
	self.txt_clubid:setString("ID：" ..data.clubID or "")
	self.txt_clubusername:setString(data.userName or "")
	self.txt_clubuserid:setString("ID："..data.userID or "")
	self.txt_mynum:setString(data.ranking or "")
	self.txt_round:setString((data.round_cound or 0 ).. "/300")
	local rank = tonumber(data.ranking or 0) or 0
	self:setRanking(rank)

	local spriteFrame = display.newSpriteFrame(string.format("image2/activity2/icon%s.png",data.icon ))  
  	local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
  	sprite:setPosition(cc.p(44.5,44.5))
  	sprite:addTo(self.ctn_icon)

  	--领取状态check
  	if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_REWARD then
        local  reward_status	= data.reward_status       --领取状态  0 可以领取  1不可领取  -----------------2条件为达成
        local  reward_status_msg= data.reward_status_msg   --未能领取原因 

        if rank == 0 then --处理没有排名的玩家
        	self.txt_mynum:setString("")
			local norank = self.txt_mynum:getChildByName("norank")
			if norank then 
				norank:setVisible(true)
			end
        elseif reward_status == 0 then--可以领取
        	self.txt_mynum:setVisible(false)
        	self["btn_lingqu_"..rank]:setVisible(true)
        	if ActivityMgr.ActivityUserInfo == nil then
        		self:showLingquAnimation(rank)
        	end	
        elseif reward_status == 1 and rank < 4 then -- 1-3 名不可领取
        	self.txt_mynum:setVisible(false)
        	self["btn_reason_"..rank]:setVisible(true)
        end	
    end 
end

function uiActivityClubItem:normalUI()
	for i=1,3 do
		self.txt_mynum:getChildByName("no"..i):setVisible(false)
	end
	self.txt_mynum:getChildByName("norank"):setVisible(false)

end

function uiActivityClubItem:setRanking(rank)
	--还原图标状态
	cclog("-- setRanking ",rank)
	self:normalUI()--ui回归
	for i=1,3 do
		local rank_img = self.txt_mynum:getChildByName("no"..i)
		if rank_img then 
			rank_img:setVisible(false)
		else
			cclog(" no"..i, " node null")
		end	
	end

	self.txt_mynum:setString(rank)
	if rank > 0 and rank < 4 then 
		local rank_img = self.txt_mynum:getChildByName("no"..rank)
		if rank_img then 
			rank_img:setVisible(true)
		end	
	elseif rank == 0 then
		self.txt_mynum:setString("")
		local norank = self.txt_mynum:getChildByName("norank")
		if norank then 
			norank:setVisible(true)
		end
	end	
end

function uiActivityClubItem:updateRank(data)
	cclog(" -- updateRank" , tonumber(self.data.clubID) )
	print_r(data)
	if data then 
		local newrank = data.newrank
		local clubID  = tonumber(data.clubID or 0) or 0 

		if newrank ~= nil and clubID ~= nil and clubID == tonumber(self.data.clubID) then 
			self:setRanking(newrank)
		end	
	end	
end

function uiActivityClubItem:updateItemSelect( clubID )
	if self.data then 
		self.img_select:setVisible(clubID == self.data.clubID)
	end	
end

function uiActivityClubItem:showLingquAnimation(rank)
	local animate = ActivityMgr:getAnimateWithkey(nil , "image2/activity2/rewardno".. rank .. "_%d.png" , 1 , 2 , 0.15)
    local spriteFrame = display.newSpriteFrame("image2/activity2/rewardno".. rank .."_1.png")  
    local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
    sprite:runAction(cc.RepeatForever:create(animate))
    sprite:setPosition(cc.p(27,30))
            
    self["btn_lingqu_"..rank]:addChild(sprite)
end

function uiActivityClubItem:removeALLani()
	self.btn_lingqu_1:removeAllChildren()
	self.btn_lingqu_2:removeAllChildren()
	self.btn_lingqu_3:removeAllChildren()
end

------ 按钮 -------
function uiActivityClubItem:onDetail()
    cclog("-------onReward")
    -- self.img_select:setVisible(true)
    -- CCXNotifyCenter:notify("onActivityClubListItemSelect", self.data.clubID)
    
    ActivityMgr:showActivityDetail(self.data)
end

function uiActivityClubItem:onLingqu()
	ActivityMgr:showActivityLingQu(self.data)
end

function uiActivityClubItem:onReason()
	ActivityMgr:showToast(self.data.reward_status_msg or "未达成领取条件,如有疑问请联系客服")
end

return uiActivityClubItem