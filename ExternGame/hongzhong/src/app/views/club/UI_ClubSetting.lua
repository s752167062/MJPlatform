

local UI_ClubSetting = class("UI_ClubSetting", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubSetting:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubSetting.csb")
    self.root:addTo(self)

	UI_ClubSetting.super.ctor(self)
	_w = self._childW
	
  	self:initUI()
    self:setMainUI()
end

function UI_ClubSetting:onEnter()
    -- body
    CCXNotifyCenter:listen(self,function(obj,key,data) self:setMainUI(data) end, "S2C_clubSetting")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:setMainUI(data) end, "S2C_updateClubSetting")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:updateGuanLi(data) end, "S2C_onAppointManager")
    
    ex_clubHandler:C2S_clubSetting()
end

function UI_ClubSetting:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function UI_ClubSetting:initUI()
	-- body
	self.img_icon           = _w["img_icon"]
    self.txt_clubname       = _w["txt_clubname"]
    self.txt_clubID         = _w["txt_clubID"]
    self.txt_qunzhuName     = _w["txt_qunzhuName"]
    self.txt_qunzhuID       = _w["txt_qunzhuID"]
    self.txt_clubCreateTime = _w["txt_clubCreateTime"]
    self.txt_jieshao        = _w["txt_jieshao"]
    self.txt_gonggao        = _w["txt_gonggao"]
    self.txt_guanliyuan     = _w["txt_guanliyuan"]
    -- self.txt_condition      = _w["txt_condition"]
    -- self.txt_town           = _w["txt_town"]
    -- self.txt_area           = _w["txt_area"]
    -- self.txt_city           = _w["txt_city"]
    self.btn_lishi          = _w["btn_lishi"]
    self.btn_jiesan           = _w["btn_jiesan"]
    self.btn_tuichu           = _w["btn_tuichu"]

    self.cb_shenqing           = _w["cb_shenqing"]
    self.cb_jujue           = _w["cb_jujue"]
    self.cb_shenqing:onEvent(function(event) self:onSelectCondition(event.name, 0) end)
    self.cb_jujue:onEvent(function(event) self:onSelectCondition(event.name, 2) end)


    -- self.panel_condition = _w["panel_condition"]
    -- self.txt_condition = _w["txt_condition"]
    self.btn_jieshao = _w["btn_jieshao"]
    self.btn_gonggao = _w["btn_gonggao"]
    self.btn_xiugaiguanli = _w["btn_xiugaiguanli"]
    -- self.btn_selectCondition = _w["btn_selectCondition"]
    self.btn_xiugai = _w["btn_xiugai"]

    self.scroll_jieshao = _w["scroll_jieshao"]
    self.scroll_gonggao = _w["scroll_gonggao"]

end

function UI_ClubSetting:setMainUI(_data)
    cclog("wtf UI_ClubSetting:setMainUI")
    self.img_icon:loadTexture(ClubManager:getClubIconPath(),1)
    self.txt_clubname:setString(ClubManager:getInfo("clubName"))
    self.txt_clubID:setString("ID: " .. ClubManager:getInfo("clubID"))
    self.txt_qunzhuID:setString("ID: " .. ClubManager:getInfo("clubQunzhuID"))

    self.txt_qunzhuName:setString(ClubManager:getInfo("clubQunzhuName"))
    GlobalFun:uiTextCut(self.txt_qunzhuName)
    self.txt_guanliyuan:setString(ClubManager:getInfo("clubGuanliyuanName"))
    GlobalFun:uiTextCut(self.txt_guanliyuan)

    self.txt_clubCreateTime:setString(ClubManager:getInfo("clubCreateTime"))
    self:setScrollText(self.scroll_jieshao, self.txt_jieshao, ClubManager:getInfo("clubDesc"))
    self:setScrollText(self.scroll_gonggao, self.txt_gonggao, ClubManager:getInfo("clubNotice"))
    -- self.txt_condition:setString(ClubManager:getClubConditionTxt())

    self.scroll_jieshao:jumpToTop()
    self.scroll_gonggao:jumpToTop()

    local condition = ClubManager:getInfo("clubCondition")
    self:onSelectCondition(nil, tonumber(condition))

    

    -- self.panel_condition:setTouchEnabled(false)
    self.btn_jieshao:setVisible(false)
    self.btn_gonggao:setVisible(false)
    self.btn_xiugaiguanli:setVisible(false)
    -- self.btn_selectCondition:setVisible(false)
    self.img_icon:setTouchEnabled(false)
    self.btn_xiugai:setVisible(false)
    self.cb_shenqing:setTouchEnabled(false)
    self.cb_jujue:setTouchEnabled(false) 
    if ClubManager:isGuanliyuan() then
        self.cb_shenqing:setTouchEnabled(true)
        self.cb_jujue:setTouchEnabled(true) 
        self.btn_xiugai:setVisible(true)
        self.img_icon:addClickEventListener(function() self:onClick(self.img_icon) end)
        self.img_icon:setTouchEnabled(true)
        self.btn_jieshao:setVisible(true)
        self.btn_gonggao:setVisible(true)

        self.btn_xiugaiguanli:setVisible(true)
        -- self.btn_selectCondition:setVisible(true)
        -- self.panel_condition:setTouchEnabled(true)
        -- self.panel_condition:addClickEventListener(function() self:onClick(self.panel_condition) end)
    end

    if ClubManager:canDismissClub() and ClubManager:isQunZhu() then
        self.btn_funcTitleText = "解散俱乐部"


        self.btn_tuichu:setVisible(false)

    else
        self.btn_funcTitleText = "退出俱乐部"


        self.btn_jiesan:setVisible(false)
    end


end

function UI_ClubSetting:updateGuanLi(res)
    self.txt_guanliyuan:setString(res.amName)
end

function UI_ClubSetting:onUIClose()
    self:removeFromParent()
end

function UI_ClubSetting:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_back" then
		self:onUIClose()
    elseif name == "btn_help" then
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubHelp")
        scene:addChild(ui.new({app = nil}))


    elseif name == "btn_jiesan" or name == "btn_tuichu" then
        local function cb ()
            if ClubManager:canDismissClub() and ClubManager:isQunZhu() then
                ex_clubHandler:C2S_DismissClub()
            else
                ex_clubHandler:C2S_ExitClub()
            end
            self:onUIClose()
        end

        ClubGlobalFun:showError(string.format("你确定要【%s】吗？", self.btn_funcTitleText), cb, nil, 2)

    elseif name == "btn_xiugaiguanli" then
        --GlobalFun:showToast("暂未开放" , 3)

        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_MemberOperation")
        scene:addChild(ui.new({app = nil, param = {useType = 1}}))

	elseif name == "img_icon" or name == "btn_xiugai" then	--设置头像
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_SelectClubIcon")
        local function callBack(id)
            ex_clubHandler:C2S_updateClubSetting({type=4,param = id})
            cclog("select iconId:",id)
        end
        scene:addChild(ui.new({app = nil, callBack = callBack}))

	elseif name == "btn_shenqing" then	--申请消息
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubShenqingliebiao")
        scene:addChild(ui.new({app = nil}))

	elseif name == "btn_lishi" then	--俱乐部历史消息
		-- local scene = cc.Director:getInstance():getRunningScene()
  --       local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubMsgHistory")
  --       scene:addChild(ui.new({app = nil}))

            GlobalFun:showToast("暂未开放" , 3)

	elseif name == "btn_jieshao" then	--俱乐部介绍
        local function callBack(content)
            ex_clubHandler:C2S_updateClubSetting({type=1,param = content})
            cclog("change jieshao =", content)
        end
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubXiugaijieshao")
        scene:addChild(ui.new({app = nil, callBack = callBack, txt = self.txt_jieshao:getString()}))

	elseif name == "btn_gonggao" then	--俱乐部公告
		local function callBack(content)
            ex_clubHandler:C2S_updateClubSetting({type=2,param = content})
            cclog("change gonggao =", content)
        end
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubXiugaijieshao")
        scene:addChild(ui.new({app = nil, callBack = callBack, txt = self.txt_gonggao:getString()}))

    elseif name == "btn_xiala" then
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubExit")
        scene:addChild(ui.new({app = nil}))

    elseif name == "btn_fuzhi" then

        local cn = ClubManager:getInfo("clubName")
        local cid = ClubManager:getInfo("clubID")


        local data = {}
        data.msg = string.format("搜索俱乐部ID：%s,加入我的俱乐部 “%s”！", cid, cn)
        data.stype = "俱乐部"
        data.params = {cid, cn,GlobalData.game_product}
        local str = GlobalFun:makeCopyStr(data)
        SDKController:getInstance():copy_To_Clipboard(str or "ERR")
        GlobalFun:showToast("复制邀请成功",Game_conf.TOAST_SHORT)


    -- elseif name == "panel_condition" then
        -- local row = 1
        -- local list = ClubManager.joinConditionTable
        -- local cIndex = -1
        -- for i, v in ipairs(list) do
        --     if v.v == ClubManager:getClubConditionTxt() then
        --         cIndex = i
        --         break
        --     end
        -- end
        -- cclog("wtf cIndex:"..cIndex)
        -- local function callBack(id)
        --     cclog("select id:",id)
        --     ex_clubHandler:C2S_updateClubSetting({type=3,param = id})
        -- end
        -- local scene = cc.Director:getInstance():getRunningScene()
        -- local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_xialaxuanze")
        -- scene:addChild(ui.new({w = 150, h = 50, row = row, list = list, callBack = callBack, posx = _sender:getPositionX() + 160, posy = _sender:getPositionY() + 20, curIndex = cIndex}))
	elseif name == "btn_xiugaiClubName" then
        cclog("修改俱乐部名称")
        local newName = self.txt_clubname:getString()
        cclog("newName:"..newName)
        ex_clubHandler:C2S_updateClubSetting({["type"] = 0, ["param"] = newName})
    end
end

function UI_ClubSetting:onSelectCondition(event, id)
    cclog("onSelectCondition >>>", id)
    if event and event.name == "unselected" then 
        event.target:setSelectedState(true)
    else
        self.cb_shenqing:setSelectedState(id == 0)
        self.cb_jujue:setSelectedState(id == 2)
        if event then
            ex_clubHandler:C2S_updateClubSetting({type=3,param = id})
        end
    end
end

function UI_ClubSetting:setScrollText(scrObj, textObj, str)
    local js_size = scrObj:getContentSize()
    textObj:setString(str)
    textObj:setTextAreaSize(cc.size(js_size.width, 0))
    textObj:ignoreContentAdaptWithSize(false)
    local size = textObj:getVirtualRendererSize()
    cclog(">>>>", size.width, size.height)
    textObj:setTextAreaSize(size)

    local w = js_size.width <size.width and size.width or js_size.width
    local h = js_size.height <size.height and size.height or js_size.height
    textObj:setPosition(2, h)
    scrObj:setInnerContainerSize(cc.size(w, h))
end



return UI_ClubSetting
