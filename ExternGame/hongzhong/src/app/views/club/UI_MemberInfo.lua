
local UI_MemberInfo = class("UI_MemberInfo", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_MemberInfo:ctor(data)
    self.data = data
    self.root = display.newCSNode("club/UI_MemberInfo.csb")
    self.root:addTo(self)

	UI_MemberInfo.super.ctor(self)
	_w = self._childW
	
    self:initUI()
    self:setMainUI()
end

function UI_MemberInfo:initUI()
    -- body
    self.btn_close = _w["btn_close"]
    self.txt_name = _w["txt_name"]
    self.icon = _w["icon"]
    self.node_icon = _w["node_icon"]
    self.txt_id = _w["txt_id"]
    self.txt_online = _w["txt_online"]
    self.txt_time = _w["txt_time"]
    self.txt_zuijin = _w["txt_zuijin"]
    self.txt_beizhu = _w["txt_beizhu"]
    self.btn_fasongfangka = _w["btn_fasongfangka"]
    self.btn_shenqingfangka = _w["btn_shenqingfangka"]

    self.txt_online:setVisible(false)
    -- self.txt_beizhu:setVisible(false)
    self.img_heimingdan = _w["img_heimingdan"]
    self.beizhu_node = _w["beizhu_node"]

    self.beizhu_node:setVisible(ClubManager:isGuanliyuan())

    -- self.mask = _w["mask"]
    -- self.mask:setTouchEnabled(true)
    -- self.mask:addClickEventListener(function() self:onClick(self.mask) end)

    self.btn_kickout = _w["btn_kickout"]
    self.btn_kickout:setTouchEnabled(true)
    self.btn_kickout:addClickEventListener(function() self:onClick(self.btn_kickout) end)

    self.btn_tianjia = _w["btn_tianjia"]
    self.btn_tianjia:setTouchEnabled(true)
    self.btn_tianjia:addClickEventListener(function() self:onClick(self.btn_tianjia) end)

    self.btn_jiechu = _w["btn_jiechu"]
    self.btn_jiechu:setTouchEnabled(true)
    self.btn_jiechu:addClickEventListener(function() self:onClick(self.btn_jiechu) end)

    _w["Text_zjdl"]:setVisible(false)  -- 暂时隐藏
end

--主设置
function UI_MemberInfo:setMainUI()
    local data = self.data
    print_r(data)

    local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
    self.node_icon:addChild(icon)
    icon:setIcon(data.userID, data.icon)

    self.txt_name:setString(data.name)
    GlobalFun:uiTextCut(self.txt_name)

    self.txt_id:setString(data.userID or "")
    self.txt_online:setString(data.online or "离线")
    self.txt_beizhu:setString(data.beizhu or "")
    self.txt_zuijin:setString(data.zuijin or "")
    self.txt_time:setString(data.jiarutime or "")

    --self.btn_fasongfangka:setVisible(ClubManager:isQunZhu() and  data.userID ~= ClubManager:getInfo("playerID"))
    self.btn_fasongfangka:setVisible(false)
    --self.btn_shenqingfangka:setVisible(not ClubManager:isQunZhu() and data.userID == ClubManager:getInfo("clubQunzhuID") and data.userID ~= ClubManager:getInfo("playerID"))
    self.btn_shenqingfangka:setVisible(false)

    local isHeimingdan = data.isHeimingdan or false
    self.img_heimingdan:setVisible(isHeimingdan)

    self.btn_tianjia:setVisible(false)
    self.btn_jiechu:setVisible(false)
    if isHeimingdan then
        if ClubManager:canRemoveBlackList(data.userID) then
            self.btn_jiechu:setVisible(true)
        end
    else
        if data.userID ~= ClubManager:getInfo("playerID") and data.userID ~= ClubManager:getInfo("clubQunzhuID") and
            data.userID ~= PlayerInfo.playerUserID and ClubManager:isGuanliyuan() then
            self.btn_tianjia:setVisible(true)
        end
    end

    self.btn_kickout:setVisible(false)
    if ClubManager:canKickPeople(data.userID) then
        self.btn_kickout:setVisible(true)
    end
end

function UI_MemberInfo:update(t)
    
end

function UI_MemberInfo:onExit()
    
end

function UI_MemberInfo:onUIClose()
    self:removeFromParent()
end

function UI_MemberInfo:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" or name == "mask" then
        self:checkBeiZhu()
	    self:onUIClose()
       
    elseif name == "btn_kickout" then
        

        local function cb ()
            local data = {userID = self.data.userID, id = self.data.id}
            ex_clubHandler:C2S_KickOut(data)
            self:onUIClose()
        end
        ClubGlobalFun:showError(string.format("你要将id为【%s】的玩家【%s】踢出俱乐部吗？", tostring(self.data.userID), self.data.name),cb,nil,2)
    elseif name == "btn_tianjia" then
        --cclog("添加黑名单")
        local clubID = ClubManager:getClubID()
        ex_clubHandler:toOperateBlackList(clubID, self.data.userID, 0)
        
        self:checkBeiZhu()
        self:onUIClose()

    elseif name == "btn_jiechu" then
        --cclog("解除黑名单")
        local clubID = ClubManager:getClubID()
        ex_clubHandler:toOperateBlackList(clubID, self.data.userID, 1)
        
        self:checkBeiZhu()
        self:onUIClose()

    elseif name == "btn_fasongfangka" then
        cclog("发送房卡")
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_SendRoomCardTips")
        scene:addChild(ui.new({app = nil, data = self.data}))
        
        self:checkBeiZhu()
        self:onUIClose()
        
    elseif name == "btn_shenqingfangka" then
        cclog("申请房卡")
        
	end
end

function UI_MemberInfo:onTouch(_sender, _type)
	
end

function UI_MemberInfo:checkBeiZhu()
    local str = self.txt_beizhu:getString()
    local clubID = ClubManager:getClubID()
    cclog("checkBeiZhu >>>",clubID, self.data.userID, self.data.beizhu ,str)
    if self.data.beizhu ~= str then
        ex_clubHandler:xiuGaiBeiZhu(clubID, self.data.userID, str)
    end
end

return UI_MemberInfo










