
local UI_ClubMain = class("UI_ClubMain", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubMain:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubMain.csb")
    self.root:addTo(self)
    
	UI_ClubMain.super.ctor(self)
	_w = self._childW

	self.setting_second = 0

	self:initUI()

end

function UI_ClubMain:onEnter()
	-- body
	cclog("UI_ClubMain:onEnter")
	ex_clubHandler:sendPlayingList()


	-- CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onRoomCardStatistics(data) end, "res_onRoomCardStatistics")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:setMainUI() end, "S2C_updateClubSetting")

    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetMemberList(data) end, "S2C_memberList")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetMemberList(data) end, "S2C_JoinResult")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:switchClub(data) end, "onClubList")

    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetRedPoint(false) end, "S2C_clubSetting")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetRedPoint(true, data) end, "CLUB:onRedPoint")

    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetRedPoint_chat(true, data) end, "newClubChatMsg2")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetRedPoint_chat(false, data) end, "resetRedPoint_chat")

    CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onGameSetting(data) end, "res_onGameSetting")

    CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onQuickMatching(data) end, "S2C_onQuickMatching")

    CCXNotifyCenter:listen(self,function(obj,key,data) self:recvPlayingCommonList(data) end, "ClubController.onPlayingList")
    -- ex_clubHandler:C2S_clubSetting()
    
	CCXNotifyCenter:listen(self,function() 
        cclog("UI_ClubMain canGotoClub")
        self:onEnter()
    end, "canGotoClub")


    self:setMainUI()
    

	ex_timerMgr:register(self) 
	self.one_second = 0  --1秒计数变量

	ex_clubHandler.gotoGameSetting()   

	    --ActivityMgr
    local activity_node =  cc.Node:create()
    self.root:addChild(activity_node) 
    ActivityMgr:setClubRoot(self , activity_node)
    ActivityMgr:checkActivityStatusClub()
    ActivityMgr:getActivityUserInfoClub()
    
    self:checkNotice()
end

function UI_ClubMain:onEnterTransitionFinish()
	cclog("UI_ClubMain:onEnterTransitionFinish")

	-- self:res_onGameSetting(ClubManager:getInfo("game_setting"))
	-- self:checkGameSetting()
end

function UI_ClubMain:onExit()
    CCXNotifyCenter:unListenByObj(self)
    ex_timerMgr:unRegister(self)
end

function UI_ClubMain:update(dt)


	self.one_second = self.one_second + dt
	
	if self.one_second >= 1 then
		self.one_second = 0
		self.Unit_RoomInfo:updateReadyRoomCountdown()
		
	end

	
	if self.setting_second >= 0 then
		self.setting_second = self.setting_second +dt
		if self.setting_second >= 2 then
			self:onSetShow(false)
		end
		
	end

end


function UI_ClubMain:initUI()
	-- body
	self.bg    = _w["bg"]






	self.playing_list = _w["setting_list"]
	self.playing_list:setScrollBarEnabled(false)

	self.bg_buttom    = _w["bg_buttom"]

	self.img_clubIcon    = _w["img_clubIcon"]
	self.txt_clubName    = _w["txt_clubName"]
	self.txt_clubID      = _w["txt_clubID"]
	self.txt_peopleNum   = _w["txt_peopleNum"]


	self.roomList1       = _w["roomList1"]

	-- self.fangkaList      = _w["fangkaList"]
	self.btn_switchIcon  = _w["btn_switchIcon"]

	self.txt_rule  = _w["txt_rule"]

	


	self.txt_myname = _w["txt_myname"]
	self.txt_myid = _w["txt_myid"]
	self.my_icon = _w["my_icon"]
	

	self.txt_page = _w["txt_page"]
	self.btn_next = _w["btn_next"]
	self.btn_last = _w["btn_last"]
	self.btn_go = _w["btn_go"]
	self.txt_totalPage = _w["txt_totalPage"]


	self.panel_sq_xiaoxi = _w["panel_sq_xiaoxi"]
    self.txt_sq_xiaoxiNum = _w["txt_sq_xiaoxiNum"]

	self.panel_sq_xiaoxi:setVisible(false)

	self.panel_ltdt_xiaoxi = _w["panel_ltdt_xiaoxi"]
	self.txt_ltdt_xiaoxiNum = _w["txt_ltdt_xiaoxiNum"]

	self.panel_ltdt_xiaoxi:setVisible(false)



	if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_OPENED then --活动开放中
		self.bg:loadTexture("image2/club/bg2.jpg")
		self.bg_buttom:setVisible(true)
	end


	self.isSetShow = true
    self.setting_bg = self:findChildByName("setting_bg")
    self.img_settingOut = self:findChildByName("img_settingOut")
    self:onSetShow(self.isSetShow, true)

    self.p_noGame = self:findChildByName("p_noGame")
    self.p_noGame:setVisible(false)
    self.p_noGame:onClick(function() self.p_noGame:setVisible(false) end)
    -- self.effct_hand = display.newCSNode(__platformHomeDir .. "/ui/layout/ClubView/Effect_hand.csb", 0,45, true)
    -- self.setting_bg:addChild(self.effct_hand)
    -- self.effct_hand:setVisible(false)
    -- self.effct_hand:setPosition(200,280)

    self.btn_setting = self:findChildByName("btn_setting")
    self.btn_setting:onClick(function() self:onSetShow() end)

    self.isInfoShow = true
    self.info_bg = self:findChildByName("info_bg")
    self.img_infoOut = self:findChildByName("img_infoOut")
    self:onInfoShow(self.isInfoShow, true)

    self.btn_showInfo = self:findChildByName("btn_showInfo")
    self.btn_showInfo:onClick(function() self:onInfoShow() end)


    self.img_noGame = self:findChildByName("img_noGame")
    self.img_noGame:setVisible(false)


    	--房间列表逻辑模块使用node节点挂靠当前节点，让节点的移除onExit同步
	self.Unit_RoomInfo = ex_fileMgr:loadLua("app.views.club.Unit_RoomInfo").new({roomList1 = self.roomList1, txt_page = self.txt_page,
						 btn_next = self.btn_next, btn_last = self.btn_last, btn_go = self.btn_go, txt_totalPage = self.txt_totalPage})
	self.root:addChild(self.Unit_RoomInfo)
end

--主设置
function UI_ClubMain:setMainUI()
	self.txt_clubName:setString(ClubManager:getInfo("clubName"))
	self.txt_clubID:setString(string.format("(ID:%s)", tostring(ClubManager:getClubID()) ))
	self.txt_peopleNum:setString( string.format("%s/%s", ClubManager:getInfo("clubPeopleNum"), ClubManager:getInfo("clubPeopleMaxNum")) )


	self.txt_myname:setString(PlayerInfo.nickname)
	self.txt_myid:setString("ID: ".. PlayerInfo.playerUserID)
	local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
	
	local size = self.my_icon:getContentSize()
	icon:setPosition(size.width/2, size.height/2)
	icon:setScale(0.7)
	icon:setIcon(PlayerInfo.playerUserID, PlayerInfo.headimgurl)
	self.my_icon:addChild(icon)





	self.img_clubIcon:loadTexture(ClubManager:getClubIconPath(),1)

	self.btn_switchIcon:setVisible(false)
	self.img_clubIcon:setTouchEnabled(false)
	if ClubManager:isGuanliyuan() then
		self.btn_switchIcon:setVisible(true)
		self.img_clubIcon:setTouchEnabled(true)
    	self.img_clubIcon:addClickEventListener(function() self:onClick(self.img_clubIcon) end)
	end


	-- _w["btn_switchIcon"]:setVisible(false)


	if ClubManager:isGuanliyuan() then
		_w["btn_shenqing"]:setVisible(true)
	else
		_w["btn_shenqing"]:setVisible(false)
	end
	
	-- self:res_onGameSetting(ClubManager:getInfo("game_setting"))

	self:resetRedPoint_chat(0)

end

function UI_ClubMain:resetMemberList(res)
    local num = res.total
    self.txt_peopleNum:setString( string.format("%s/%s", num, ClubManager:getInfo("clubPeopleMaxNum")) )
end

function UI_ClubMain:onClick(_sender)
	local name = _sender:getName()
	cclog("UI_ClubMain:onClick name:"..name)
	if name == "btn_close" or name == "btn_back" then
		-- GlobalFun:showNetWorkConnect("正在直连大厅...")	
		-- ex_clubHandler:reqClubGotoHall()	--顺便把scene也关了
		platformExportMgr:returnAppPlatform()

	elseif name == "btn_switchIcon" or name == "img_clubIcon" then --头像切换按钮
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_SelectClubIcon")
        local function callBack(id)
        	if not id then
        		GlobalFun:showToast("请选择图片", 3)
        		return 
        	end
            ex_clubHandler:C2S_updateClubSetting({type=4,param = id})
            cclog("select iconId:",id)
        end
        scene:addChild(ui.new({app = nil, callBack = callBack}))

	elseif name == "btn_clubSetting" then	--设置
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubSetting")
        scene:addChild(ui.new({app = nil}))
	
	elseif name == "btn_help" then	--帮助
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubHelp")
        scene:addChild(ui.new({app = nil}))

	elseif name == "" then	--返回
		--暂无
	elseif name == "btn_clubNotice" then	--俱乐部公告
	   
	elseif name == "btn_memberList" then	--成员列表
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_MemberMgr")
        scene:addChild(ui.new({app = nil}))

	elseif name == "btn_gameMgr" then	--游戏管理

		if ClubManager:isGuanliyuan() then  --会长和管理员才能搞
			local scene = cc.Director:getInstance():getRunningScene()
	        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_GameSetting")
	        scene:addChild(ui.new({app = nil}))
	        self.isCheckGameSetting = true
	    else
	    	GlobalFun:showToast("只有会长和管理员才能进行设置" , 3)
	    end

	elseif name == "btn_quickOpenRoom" then	--快速开房
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_QuickCheckIn")
        scene:addChild(ui.new({app = nil}))

    elseif name == "btn_endRoom" then	--结束的房    
   		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_EndRoom")
        scene:addChild(ui.new({app = nil}))

    elseif name == "btn_shenqing" then  --申请列表
    	local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubShenqingliebiao")
        scene:addChild(ui.new({app = nil}))

    -- elseif name == "img_switchClub" then  --切换俱乐部
    --     ex_clubHandler:toClubList()

	elseif name == "btn_ltdt" then	--聊天大厅
		--GlobalFun:showToast("尚未开放!", 1)
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubChatSessionWin")
        scene:addChild(ui.new({app = nil}))
	elseif name == "btn_fktj" then	--房卡统计
		-- GlobalFun:showToast("房卡统计!", 1)
		if ClubManager:isGuanliyuan() == true then
			local scene = cc.Director:getInstance():getRunningScene()
	        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_RoomCardStatistics")
	        scene:addChild(ui.new({app = nil}))	
	    else
	    	GlobalFun:showToast("仅会长和管理员拥有查看房卡统计的权限" , 3)
	    end	

	elseif name == "btn_last" then --房间列表上一页
        self.Unit_RoomInfo:onUnitClick(_sender)
    elseif name == "btn_next" then  --房间列表下一页
        self.Unit_RoomInfo:onUnitClick(_sender)
    elseif name == "btn_go" then  --房间列表下一页
    	cclog(">>>>>>")
        self.Unit_RoomInfo:onUnitClick(_sender)

    elseif name == "btn_yaoqing" then	--邀请
    	--GlobalFun:showToast("尚未开放!", 1)

    	if ClubManager:isGuanliyuan() then
	    	local scene = cc.Director:getInstance():getRunningScene()
	        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_YaoQingJiaRu")
	        scene:addChild(ui.new({app = nil, param = {useType = 2}}))	
	    else
	    	GlobalFun:showToast("会长和管理员才能邀请玩家加入俱乐部", 2)
	    end

    elseif name == "btn_zhanji" then	--战绩
    	-- GlobalFun:showToast("暂未开放，请移步游戏大厅查看战绩!", 1)
    	local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubCombatGains")
        scene:addChild(ui.new())	

    elseif name == "btn_kuaisupipei" then	--快速匹配
    	ex_clubHandler:toQuickMatching()
	end
end

function UI_ClubMain:switchClub(res)
    -- body
    local scene = cc.Director:getInstance():getRunningScene()
    local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubEntry")
    local view = ui.new()
    view:updateList(res)
    scene:addChild(view)
end


function UI_ClubMain:res_onGameSetting(data)
	cclog("UI_ClubMain:res_onGameSetting >>>>>")

	if data and data.playRuleTb and next(data.playRuleTb) then
		local info = data.playRuleTb[1]
		local str = GameRule:clubGameRuleText2(info)

		self.txt_rule:setString("玩法：")
		local oneLineHeight = self.txt_rule:getContentSize().height

		self.txt_rule:setString("红中麻将:" .. str)

		self.txt_rule:setTextAreaSize(cc.size(340,0))

		local csize = self.txt_rule:getContentSize()

		local rlabel = self.txt_rule:getVirtualRenderer()
    	local rlsize = rlabel:getContentSize()

    	local h = rlabel:getHeight()
    	cclog("ff >",h)

    	local x,y = self.txt_rule:getPosition()
    	self.txt_rule_y = self.txt_rule_y or y
    	cclog("sssffff >>", self.txt_rule_y, rlsize.height ,csize.height, oneLineHeight)
    	if rlsize.height > oneLineHeight then --先要知道单个行的高才能确定这个常量值
    		self.txt_rule:setPositionY(self.txt_rule_y +14)
    	else
    		self.txt_rule:setPositionY(self.txt_rule_y)
    	end

		cclog("sa >>", rlsize.width, rlsize.height)

        self.txt_rule:setContentSize(cc.size(rlsize.width, rlsize.height))


	else
		self.txt_rule:setString("未设置玩法")
		
	end

	print_r(data)
	self:checkGameSetting(data)
end

function UI_ClubMain:checkGameSetting(data)
	cclog("UI_ClubMain:checkGameSetting >>>")


	-- local data = ClubManager:getInfo("game_setting")
	if data and data.playRuleTb and next(data.playRuleTb) then
		-- ClubGlobalFun:removeWindow(ClubGlobalFun.popType_key1)
	else
		if ClubManager:isGuanliyuan() then
			-- cclog(debug.traceback())
			if self.isCheckGameSetting then
				
				return
			end
			self.isCheckGameSetting = true
			ClubGlobalFun:showError("请到【玩法设置】设置玩法规则", function() 
					cclog("xxxxxx")
					local scene = cc.Director:getInstance():getRunningScene()
			        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_GameSetting")
			        scene:addChild(ui.new({app = nil}))
				end,nil,1)
		end
	end
end

--设置申请列表红点(临时这么搞)
function UI_ClubMain:resetRedPoint(isPush, data)
	if isPush then  --服务器通知红点
		if data.rp_type == 0 then  -- 申请列表的红点
			self.panel_sq_xiaoxi:setVisible(data.isRed)
		end

	else  -- 开始进入俱乐部大厅的推送红点
	    if ClubManager:getInfo("clubJoinReqNum") > 0 then
	        self.panel_sq_xiaoxi:setVisible(true)
	    else
	        self.panel_sq_xiaoxi:setVisible(false)
	    end
	end
end

--刷新聊天的红点
function UI_ClubMain:resetRedPoint_chat(_flag, _data)
	if _flag == true then
		self.panel_ltdt_xiaoxi:setVisible(true)
	elseif _flag == false then
		self.panel_ltdt_xiaoxi:setVisible(false)
	elseif _flag == 0 then
		self.panel_ltdt_xiaoxi:setVisible(false)
		local tb = ClubChatMgr:getMsgByChannel(ClubChatMgr.msgChannel.hall)
		for i, v in ipairs(tb) do
			if v.isRead == false then
				self.panel_ltdt_xiaoxi:setVisible(true)
				break
			end
		end
	end
end

--快速匹配回调
function UI_ClubMain:res_onQuickMatching(data)
	cclog("UI_ClubMain:res_onQuickMatching")
	--[[
	local function cb()
        --创建房间
        local action = cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function() 
    		self.Unit_RoomInfo:createRoomFromQuick()
        end))
        self.root:runAction(action)
    end
    ClubGlobalFun:showError("俱乐部暂时没有空余房间，是否创建房间",cb,nil,2)
	--]]
	self.Unit_RoomInfo:createRoomFromQuick()
end

--弹出公告
function UI_ClubMain:checkNotice()
	-- local ddd = "俱乐部公告\n 123456789"
	-- ClubGlobalFun:showError(ddd, nil, nil, 2)

	-- local content = ClubManager:getInfo("showNoticeOnce")
	-- if content ~= "" then
	-- 	ClubManager:setInfo("showNoticeOnce", "")
	--     ClubGlobalFun:showError("俱乐部公告:"..content, nil, nil, 2)
	-- end
end

function UI_ClubMain:onSetShow(bool, isInit)
	if not isInit then
		self.setting_second = -1
	end
    if bool ~= nil then
        self.isSetShow = bool
    else
        self.isSetShow = not self.isSetShow
    end

    self.img_settingOut:setVisible(not self.isSetShow)

    if self.isSetShow then
        local x,y = self.setting_bg:getPosition()
        local size = self.setting_bg:getContentSize()
        local args = {
            x = 0,
            y = y,
            time = 0.3,
        }
        
        transition.moveTo(self.setting_bg, args)
    else
        local x,y = self.setting_bg:getPosition()
        local size = self.setting_bg:getContentSize()
        local args = {
            x = -size.width,
            y = y,
            time = 0.3,
        }
        transition.moveTo(self.setting_bg, args)
    end
    
end

function UI_ClubMain:onInfoShow(bool, isInit)
    if bool ~= nil then
        self.isInfoShow = bool
    else
        self.isInfoShow = not self.isInfoShow
    end

    self.img_infoOut:setVisible(not self.isInfoShow)

    if self.isInfoShow then
        local x,y = self.info_bg:getPosition()
        local size = self.info_bg:getContentSize()
        local args = {
            x = x,
            y = 640,
            time = 0.3,
        }
        
        transition.moveTo(self.info_bg, args)
    else
        local x,y = self.info_bg:getPosition()
        local size = self.info_bg:getContentSize()
        local args = {
            x = x,
            y = 640+size.height,
            time = 0.3,
        }
        transition.moveTo(self.info_bg, args)
    end
    
end

function UI_ClubMain:recvPlayingCommonList(res)

    -- self.txt_clubName:setString(res.clubName)
    -- self.txt_clubId:setString(res.clubId)
    -- self.txt_renNumb:setString(string.format("%s/%s", res.clubCurMan, res.clubMaxMan))




    self.playing_list:removeAllChildren()

    local list = res.list
    res.canSetNumb = res.canSetNumb or 300

    local canSet = false
    if #list <res.canSetNumb then
        table.insert(list, 1, {})
        canSet = true
    end

    local isShowNull = #list <= 1
    self.img_noGame:setVisible(isShowNull)
    -- self.p_noGame:setVisible(isShowNull)
    -- self.effct_hand:setVisible(isShowNull)
   

    for i, v in ipairs(list) do
        local layout = ccui.Layout:create()
        
        local item = display.newCSNode("club/SettingItem.csb")
        item:addTo(layout)

 

        local bg = item:findChildByName("bg")
        local size = bg:getContentSize()
        cclog("xxx >", size.width, size.height)
        layout:setContentSize(cc.size(size.width, size.height ))
        self.playing_list:pushBackCustomItem(layout)

        if i == 1 and canSet then
            item:findChildByName("img_add"):setVisible(true)
            item:findChildByName("txt_gameName"):setVisible(false)
            item:findChildByName("btn_delete"):setVisible(false)
            item:findChildByName("img_isSel"):setVisible(false)
            if #list == 1 then
                local x,y = item:getPosition()
                item:setPositionX(x +15)
            end
        else
            
            local txt_gameName = item:findChildByName("txt_gameName")
            txt_gameName:setString(v.name)
            item:findChildByName("img_add"):setVisible(false)

            cclog("recvPlayingCommonList >>>", v.clubSecndId, ClubManager:getClubSecndID())
            item:findChildByName("img_isSel"):setVisible(v.clubSecndId == ClubManager:getClubSecndID())
        end



        item:findChildByName("btn_delete"):addClickEventListener(function()
        		self:onPlayingCommonDel(idx, v, canSet)
        	end)

        layout:setTouchEnabled(true)
        layout:setSwallowTouches(false)
        layout:addClickEventListener(function() 
                    self:onPlayingClickCommon(i, v, canSet)
            end)
    end

end

function UI_ClubMain:onPlayingClickCommon(idx, data, canSet)
    if idx == 1 and canSet then
        cclog("onPlayingClickCommon >>add")

        if not ClubManager:isGuanliyuan() then
	   		GlobalFun:showToast("只有管理员和会长才能进行操作", 3)
	   		return
	   end

        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."ClubSelectGame_view")
        scene:addChild(ui.new({app = nil}))
        ui:init(ClubManager:getClubID())

        
    else
        cclog("onPlayingClickCommon >>",idx)
        cclog("onPlayingClickCommon 22>>", GlobalData.game_product , data.product)
        cclog("onPlayingClickCommon 33>>", ClubManager:getClubSecndID() , data.clubSecndId)
        if GlobalData.game_product == data.product then
        	if ClubManager:getClubSecndID() == data.clubSecndId then
			else
				self:removeFromParent()
				ClubManager:setInfo("clubSecndId", data.clubSecndId)
				ex_clubHandler:connectCheck()
				CCXNotifyCenter:notify("resetClub", nil)
			end
        else  --去其他游戏

        end
    end
end

function UI_ClubMain:onPlayingCommonDel(idx, data)
   cclog("UI_ClubMain:onPlayingCommonDel >>", ClubManager:getClubSecndID())
   if not ClubManager:isGuanliyuan() then
   		GlobalFun:showToast("只有管理员和会长才能进行操作", 3)
   		return
   end


   local function ok()
   		
   		if GlobalData.game_product == data.product then
			if ClubManager:getClubSecndID() == data.clubSecndId then  --删的是自己
				
				local schedulerID = false
			    local scheduler = cc.Director:getInstance():getScheduler()
			    local function cb(dt)
			        scheduler:unscheduleScriptEntry(schedulerID)
			        ex_clubHandler:sendRemovePlaying(ClubManager:getClubID(), data.clubSecndId)
			        platformExportMgr:returnAppPlatform()
			    end
			    schedulerID = scheduler:scheduleScriptFunc(cb, 0.00001,false) 
				return
			end
		end

		ex_clubHandler:sendRemovePlaying(ClubManager:getClubID(), data.clubSecndId)
   end

   ClubGlobalFun:showError(string.format("是否要删除玩法[%s](ID:%s)", data.name, data.clubSecndId), ok, nil, 2)
end

return UI_ClubMain
