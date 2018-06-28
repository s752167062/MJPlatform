local uiActivityRewardDetail_zn = class("uiActivityRewardDetail_zn", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityRewardDetail_zn.RESOURCE_FILENAME = "activity2/uiActivityRewardDetail_zn.csb"
uiActivityRewardDetail_zn.RESOURCE_BINDING = {
    ["btn_close"]        = {    ["varname"] = "btn_close"              ,  ["events"] = { {event = "click" ,  method ="onBack"    } }       },

    ["txt_clubname"]     = {    ["varname"] = "txt_clubname"          },
    ["txt_mynum"]        = {    ["varname"] = "txt_mynum"             },
    ["txt_eggnum"]       = {    ["varname"] = "txt_eggnum"             },--福蛋
    ["txt_fudainum"]     = {    ["varname"] = "txt_fudainum"           },--福袋

    ["txt_1_0"]        = {    ["varname"] = "txt_1_0"             },
    ["txt_2_0"]        = {    ["varname"] = "txt_2_0"             },
    ["txt_3_0"]        = {    ["varname"] = "txt_3_0"             },
    ["txt_4_0"]        = {    ["varname"] = "txt_4_0"             },
    ["txt_5_0"]        = {    ["varname"] = "txt_5_0"             },
    ["txt_6_0"]        = {    ["varname"] = "txt_6_0"             },

    ["txt_1"]        = {    ["varname"] = "txt_1"             },
    ["txt_2"]        = {    ["varname"] = "txt_2"             },
    ["txt_3"]        = {    ["varname"] = "txt_3"             },
    ["txt_4"]        = {    ["varname"] = "txt_4"             },
    ["txt_5"]        = {    ["varname"] = "txt_5"             },
    ["txt_6"]        = {    ["varname"] = "txt_6"             },
    ["txt_7"]        = {    ["varname"] = "txt_7"             },
    ["txt_8"]        = {    ["varname"] = "txt_8"             },
    ["txt_9"]        = {    ["varname"] = "txt_9"             },
    ["txt_10"]       = {    ["varname"] = "txt_10"             },
    ["txt_11"]       = {    ["varname"] = "txt_11"             },
    ["txt_12"]       = {    ["varname"] = "txt_12"             },
    ["txt_13"]       = {    ["varname"] = "txt_13"             },
    ["txt_14"]       = {    ["varname"] = "txt_14"             },
    ["txt_15"]       = {    ["varname"] = "txt_15"             },

    ["ctn_rank1"]       = {    ["varname"] = "ctn_rank1"             },
    ["ctn_rank2"]       = {    ["varname"] = "ctn_rank2"             },
    ["ctn_rank3"]       = {    ["varname"] = "ctn_rank3"             },

    ["btn_closeAll"]  = {    ["varname"] = "btn_closeAll"        ,  ["events"] = { {event = "click" ,  method ="onCloseAll"	} }       },
    ["btn_lottery"]   = {    ["varname"] = "btn_lottery"         ,  ["events"] = { {event = "click" ,  method ="onLottery"	} }       },
    ["btn_myres"]     = {    ["varname"] = "btn_myres"           ,  ["events"] = { {event = "click" ,  method ="onMyRes"	} }       },
    ["btn_ranks"]     = {    ["varname"] = "btn_ranks"           ,  ["events"] = { {event = "click" ,  method ="onRanks"    } }       },
}

uiActivityRewardDetail_zn.KEY_FOR = {
	-- [] = ""
}

function uiActivityRewardDetail_zn:onCreate()
    cclog("CREATE")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:onActivityRewardDetail(data) end ,"onActivityClubDetail")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:removeFromParent() 		  end ,"ActivitysCloseAll")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:setFudaiNum(data)   		  end ,"GetActivityClubFudai")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:checkClubDetail()   		  end ,"reCheckClubDetail")
end

function uiActivityRewardDetail_zn:onEnter()
    cclog("ENTER")
    if ActivityMgr.ACTIVITY_STATUE ~= ActivityMgr.ACTIVITY_STATUE_OPENED then
    	self.btn_lottery:setVisible(false)
    end	
end

function uiActivityRewardDetail_zn:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end

function uiActivityRewardDetail_zn:setClubData( data )
	cclog(" -- uiActivityRewardDetail_zn ")
	print_r(data)
	self.data = data
	self.txt_clubname:setString(data.clubName or "")
	self.txt_mynum:setString(data.ranking or "")

	self:checkClubDetail()--页面数据
end

function uiActivityRewardDetail_zn:checkClubDetail()
	if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
		ActivityMgr:getActivityClubDetail(self.data.clubID)
	elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
		ActivityMgr:getActivityClubDetailClub(self.data.clubID)
	end
end

function uiActivityRewardDetail_zn:setFudaiNum(fudainum)
    self.fudainum = fudainum
    self.txt_fudainum:setString(fudainum or 0)
end


function uiActivityRewardDetail_zn:onActivityRewardDetail(data)
	if data then 
		self:normalUI()
		local ranking = data.ranking
		local fudai   = data.fudai
		local eggNum  = data.eggNum
		local _data   = data._data
		local _rankdata = data._rankdata

		self.txt_mynum:setString(ranking or "0")
		self.txt_eggnum:setString(eggNum or "0")
		self.txt_fudainum:setString(fudai or "0")

		local rank = tonumber(ranking or 0) or 0
		if rank >0 and rank <4 then 
			local img_rank = self.txt_mynum:getChildByName("no"..rank)
			if img_rank then
				img_rank:setVisible(true)
			end	
		elseif rank == 0 then
			self.txt_mynum:setString("")
			local norank = self.txt_mynum:getChildByName("norank")
			if norank then 
				norank:setVisible(true)
			end
		end		

		if _data then 
			self:setTaskData(_data)
		end	

		if _rankdata then 
			self:setRankData(_rankdata)
		end	

		local updatedata = {}
		updatedata.newrank = rank
		updatedata.clubID  = self.data.clubID
		CCXNotifyCenter:notify("updateActivityRank",updatedata)
	
		--重置data 排名数据
		self.data.ranking = ranking
	end	
end

function uiActivityRewardDetail_zn:normalUI()
	for i=1,3 do
		self.txt_mynum:getChildByName("no"..i):setVisible(false)
		self["ctn_rank"..i]:removeAllChildren()
	end
	self.txt_mynum:getChildByName("norank"):setVisible(false)

	--分数重置
	for j=1,6 do
		self["txt_".. j.."_0"]:setString("/")
	end

	for k=1,15 do
		self["txt_"..k]:setString("/")
	end
end

function uiActivityRewardDetail_zn:setTaskData(data)
	for k,v in pairs(data) do
		if v then 
			local _type  = v._type
			local _score = v._score or 0

			local item = ActivityMgr.RewardType[tonumber(_type or 0)]
			if item then 
				local txt = item.txt
				local ctn = "txt_" .. txt or ""
				local basevalue = self[ctn]:getString()
				if basevalue then 
					local num = tonumber(basevalue) or 0
					if num > 0 then
						_score = _score + num
					end		
				end	
				self[ctn]:setString(_score or "-")
			end	
		end	
	end
end

function uiActivityRewardDetail_zn:setRankData(data)
	--排序
	table.sort(data,function(a,b)
        if a._score ~= b._score then
	        return a._score > b._score
	    end
	    return false
	end)

	cclog(" activity 排序后的 列表")
	print_r(data)

	local _rank  = 0
	local socre = 0 
	for i=1,#data do
		local itemdata = data[i]
		if itemdata then
			if itemdata._score < socre or socre == 0 then 
				_rank = _rank + 1
				socre= itemdata._score
			end	
			itemdata._rank = _rank -- 排名

			local item = ex_fileMgr:loadLua("activity.itemRanker").new()
    		item:initData(itemdata)
			
			self["ctn_rank"..i]:addChild(item)
		end	
	end
end	

------ 按钮 -------

function uiActivityRewardDetail_zn:onBack()
    cclog("-------onBack")
    self:removeFromParent()
end

function uiActivityRewardDetail_zn:onCloseAll()
	CCXNotifyCenter:notify("ActivitysCloseAll")
end

function uiActivityRewardDetail_zn:onLottery()
	local lottery = ex_fileMgr:loadLua("activity.UIActivityLottery").new()
    lottery:setLocalZOrder(ActivityMgr.ZOrder_UI)
    lottery:setClubData(self.data)
    lottery:addTo(self:getParent())
end

function uiActivityRewardDetail_zn:onMyRes()
	local myres = ex_fileMgr:loadLua("activity.UIActivityMyRes").new()
    myres:setLocalZOrder(ActivityMgr.ZOrder_UI)
    myres:setClubData(self.data)
    myres:addTo(self:getParent())
end

function uiActivityRewardDetail_zn:onRanks()
    local ranks = ex_fileMgr:loadLua("activity.UIActivityRankDetail").new()
    ranks:setLocalZOrder(ActivityMgr.ZOrder_UI)
    ranks:setClubData(self.data)
    ranks:addTo(self:getParent())

    self:checkClubDetail()
end
return uiActivityRewardDetail_zn
