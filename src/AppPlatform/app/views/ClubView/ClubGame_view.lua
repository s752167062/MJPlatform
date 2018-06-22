
--断线重连等，当前ui数据必须重新请求
local ClubGameView = class("ClubGameView",cc.load("mvc").ViewBase)

local DownloadImageNode = require("app.common.DownloadImageNode")
local gameItem = require("app.views.gameListView.GameItem")

ClubGameView.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/ClubView/ClubGameView.csb"

function ClubGameView:init(clubId)
    self.clubId = clubId
end

function ClubGameView:onEnter()
    clubMgr:init()



    self.isSetShow = true
    self.setting_bg = self:findChildByName("setting_bg")
    self.img_settingOut = self:findChildByName("img_settingOut")
    self:onSetShow(self.isSetShow)

    self.p_noGame = self:findChildByName("p_noGame")
    self.p_noGame:setVisible(false)
    self.p_noGame:onClick(function() self.p_noGame:setVisible(false) end)
    self.effct_hand = display.newCSNode(__platformHomeDir .. "ui/layout/ClubView/Effect_hand.csb", 0,45, true)
    self.setting_bg:addChild(self.effct_hand)
    self.effct_hand:setVisible(false)
    self.effct_hand:setPosition(200,280)

    self.btn_setting = self:findChildByName("btn_setting")
    self.btn_setting:onClick(function() self:onSetShow() end)

    self.isInfoShow = true
    self.info_bg = self:findChildByName("info_bg")
    self.img_infoOut = self:findChildByName("img_infoOut")
    self:onInfoShow(self.isInfoShow)

    self.btn_showInfo = self:findChildByName("btn_showInfo")
    self.btn_showInfo:onClick(function() self:onInfoShow() end)


    self.img_noGame = self:findChildByName("img_noGame")
    self.img_noGame:setVisible(false)


    self.txt_clubName = self:findChildByName("txt_clubName")
    self.txt_clubName:setString("")
    self.txt_clubId = self:findChildByName("txt_clubId")
    self.txt_clubId:setString("")
    self.txt_renNumb = self:findChildByName("txt_renNumb")
    self.txt_renNumb:setString("0/0")


    self.setting_list = self:findChildByName("setting_list")
    self.btn_back = self:findChildByName("btn_back")
    self.btn_back:onClick(function() self:onClose() end)

    self.setting_list:setScrollBarEnabled(false)

    self.panel_touch = self:findChildByName("panel_touch")
    self.panel_touch:onClick(function() self:onClickOther() end)

    self.img_head = self:findChildByName("img_head")
    self.node_head = DownloadImageNode.new()
    self.node_head:addTo(self)
    self.node_head:DownloadImageNode_setIconObj(self.img_head)
    self.node_head:DownloadImageNode_setDownloadDir(writePathManager:getAppPlatformWritePath())
    self.node_head:DownloadImageNode_setIcon( gameConfMgr:getInfo("headUrl"))

    self.txt_name = self:findChildByName("txt_name")
    self.txt_name:setString(gameConfMgr:getInfo("playerName"))
    self.txt_id = self:findChildByName("txt_id")
    self.txt_id:setString("ID: ".. gameConfMgr:getInfo("userId"))
    
    




    self.btn_jieshufangjian = self:findChildByName("btn_jieshufangjian")
    self.btn_jieshufangjian:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_jieshufangjian:setGray(true)

    self.btn_shenqing = self:findChildByName("btn_shenqing")
    self.btn_shenqing:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_shenqing:setGray(true)

    self.btn_yaoqing = self:findChildByName("btn_yaoqing")
    self.btn_yaoqing:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_yaoqing:setGray(true)

    self.btn_youxiguanli = self:findChildByName("btn_youxiguanli")
    self.btn_youxiguanli:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_youxiguanli:setGray(true)

    self.btn_julebushezhi = self:findChildByName("btn_julebushezhi")
    self.btn_julebushezhi:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_julebushezhi:setGray(true)

    self.btn_chengyuanliebiao = self:findChildByName("btn_chengyuanliebiao")
    self.btn_chengyuanliebiao:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_chengyuanliebiao:setGray(true)

    self.btn_fangkatongji = self:findChildByName("btn_fangkatongji")
    self.btn_fangkatongji:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_fangkatongji:setGray(true)

    self.btn_zhanjiliebiao = self:findChildByName("btn_zhanjiliebiao")
    self.btn_zhanjiliebiao:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_zhanjiliebiao:setGray(true)

    self.btn_kuaishukaishi = self:findChildByName("btn_kuaishukaishi")
    self.btn_kuaishukaishi:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_kuaishukaishi:setGray(true)

    self.btn_talk = self:findChildByName("btn_talk")
    self.btn_talk:onTouch(function(sender) self:onShowDisenableInfo(sender) end)
    self.btn_talk:setGray(true)

    self.img_clubIcon = self:findChildByName("img_clubIcon")
    


    eventMgr:registerEventListener("HallProtocol.onClubData",handler(self,self.recvCommonList), self)
    eventMgr:registerEventListener("HallProtocol.onUpdatePlayingList",handler(self,self.recvCommonList), self)
end

function ClubGameView:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end

function ClubGameView:onClose()
    viewMgr:close("ClubView.ClubGame_view")
end

function ClubGameView:onShowDisenableInfo(event)
    if event.name == "ended" or event.name == "cancelled" or event.name == "moved" then
        event.target:setGray(true)

        msgMgr:showToast("该功能需要进入指定玩法", 3)
    end
end

function ClubGameView:onClickOther()
    msgMgr:showToast("该功能需要进入指定玩法", 3)
end



function ClubGameView:recvCommonList(res)
    if res.clubName then
        self.txt_clubName:setString(res.clubName)
        self.txt_clubId:setString(string.format("(ID:%s)", res.clubId))
        self.txt_renNumb:setString(string.format("%s/%s", res.clubCurMan, res.clubMaxMan))
        self.img_clubIcon:loadTexture(clubMgr:getIconPathById(res.clubIconId or "1"), 1)
    end



    self.setting_list:removeAllChildren()

    local list = res.gameList
    res.canSetNumb = res.canSetNumb or 300

    local canSet = false
    if #list <res.canSetNumb then
        table.insert(list, 1, {})
        canSet = true
    end

    local isShowNull = #list <= 1
    self.img_noGame:setVisible(isShowNull)
    self.p_noGame:setVisible(isShowNull)
    self.effct_hand:setVisible(isShowNull)
   

    for i, v in ipairs(list) do
        local layout = ccui.Layout:create()
        
        local item = display.newCSNode(__platformHomeDir .. "ui/layout/ClubView/SettingItem.csb")
        item:addTo(layout)

 

        local bg = item:findChildByName("bg")
        local size = bg:getContentSize()
        cclog("xxx >", size.width, size.height)
        layout:setContentSize(cc.size(size.width, size.height ))
        self.setting_list:pushBackCustomItem(layout)

        if i == 1 and canSet then
            item:findChildByName("img_add"):setVisible(true)
            item:findChildByName("txt_gameName"):setVisible(false)
            item:findChildByName("btn_delete"):setVisible(false)
            if #list == 1 then
                local x,y = item:getPosition()
                item:setPositionX(x +15)
            end
        else
            
            local txt_gameName = item:findChildByName("txt_gameName")
            txt_gameName:setString(v.name)
            item:findChildByName("img_add"):setVisible(false)
        end

        item:findChildByName("img_isSel"):setVisible(false)

        
        item:findChildByName("btn_delete"):addClickEventListener(function()
                self:onPlayingCommonDel(idx, v, canSet)
            end)

        layout:setTouchEnabled(true)
        layout:setSwallowTouches(false)
        layout:addClickEventListener(function() 
                    self:onClickCommon(i, v, canSet)
            end)
    end

end

function ClubGameView:onSetShow(bool)
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

function ClubGameView:onInfoShow(bool)
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

function ClubGameView:onClickCommon(idx, data, canSet)
    if idx == 1 and canSet then
        cclog("ClubGameView >>add")
        if not clubMgr:canGuanli(true) then
            return
        end

        local view = viewMgr:show("ClubView.ClubSelectGame_view")
        view:init(self.clubId)
    else
        cclog("ClubGameView >>",idx)

        local version = externGameMgr:getGameVersionByName(data.game)
        -- hallSendMgr:sendEnterGame(data.product, version)
        externGameMgr:reqGotoGame(0, data.product)
        platformExportMgr:setEnterParams(platformExportMgr.epType_gotoGameClub, {clubId = self.clubId, clubSecndId = data.clubSecndId})
    end
end


function ClubGameView:onPlayingCommonDel(idx, data)
   cclog("ClubGameView:onPlayingCommonDel >>", data.clubSecndId)
    if not clubMgr:canGuanli(true) then
        return
    end


    local function ok()
         hallSendMgr:sendRemovePlaying(self.clubId, data.clubSecndId)
    end
    msgMgr:showAskMsg(string.format("是否要删除玩法[%s](ID:%s)", data.name, data.clubSecndId), ok)
end


return ClubGameView










