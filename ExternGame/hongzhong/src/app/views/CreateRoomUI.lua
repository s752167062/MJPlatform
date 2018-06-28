local CreateRoomUI = class("CreateRoomUI",function() 
   return cc.Node:create()
end)

local myColor = {[false] = cc.c3b(101, 64, 65), [true] = cc.c3b(255, 129, 60)}
function CreateRoomUI:ctor(data)
    self.app = data.app
    self.quickFlag = data.quickFlag
    self.root = display.newCSNode("CreateRoomUI.csb")
    self.root:addTo(self)

    self.playerNum = 4
    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        elseif state == "enterTransitionFinish" then
        --self:onEnterTransitionFinish_()
        elseif state == "exitTransitionStart" then
        --self:onExitTransitionStart_()
        elseif state == "cleanup" then
        --self:onCleanup_()
        end
    end)
    
    self.roundCount = 8 --默认局数
    self.maCount = 4 --默认码数end
    --玩法
    self.is_8gehongzhong = false
    self.is_kedianpao = false


    self.isgz = false
    self.is_qixiaodui = false
    self.is_miluohongzhong = false
    self.is_gpsModel = false

end

function CreateRoomUI:onEnter()

    self.roundCount = UserDefault:getKeyValue("CURoundCount",self.roundCount)
    self.maCount = UserDefault:getKeyValue("CUIMaCount",self.maCount)
    self.playerNum = UserDefault:getKeyValue("CUIPlayerNum",self.playerNum)
    self.is_qixiaodui = UserDefault:getKeyValue("CreateRoomUI_CUIQiXiaoDui",self.is_qixiaodui)
    self.is_miluohongzhong = UserDefault:getKeyValue("CreateRoomUI_CUIMiLuoHongZhong",self.is_miluohongzhong)
    self.is_gpsModel = UserDefault:getKeyValue("CreateRoomUI_GPSMODEL",self.is_gpsModel)

    local ctn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onUIClose() end)

     local btn_wanfa = self.root:getChildByName("bg"):getChildByName("btn_wanfa")
    btn_wanfa:addClickEventListener(function() self:onUIWanfa() end)

    self.ctn_round8 = self.root:getChildByName("bg"):getChildByName("btn_round8") --8局勾选按钮
    self.ctn_round8:addClickEventListener(function() self:onSetRound(8) end)
    
    self.image_round8_checkmark = self.root:getChildByName("bg"):getChildByName("btn_round8"):getChildByName("checkmark8")
    self.txt_round8_checkmark = self.root:getChildByName("bg"):getChildByName("btn_round8"):getChildByName("round8")

    self.ctn_round16 = self.root:getChildByName("bg"):getChildByName("btn_round16") --16局勾选按钮
    self.ctn_round16:addClickEventListener(function() self:onSetRound(16) end)
    
    self.image_round16_checkmark = self.root:getChildByName("bg"):getChildByName("btn_round16"):getChildByName("checkmark16")
    self.txt_round16_checkmark = self.root:getChildByName("bg"):getChildByName("btn_round16"):getChildByName("round16")

    self.img_players3 = self.root:getChildByName("bg"):getChildByName("btn_players3"):getChildByName("checkmark3")
    self.txt_players3 = self.root:getChildByName("bg"):getChildByName("btn_players3"):getChildByName("players3")

    self.img_players4 = self.root:getChildByName("bg"):getChildByName("btn_players4"):getChildByName("checkmark4")
    self.txt_players4 = self.root:getChildByName("bg"):getChildByName("btn_players4"):getChildByName("players4")

    if self.roundCount == 8 then
        self.image_round8_checkmark:setVisible(true)
        self.txt_round8_checkmark:setTextColor(myColor[true])
        self.image_round16_checkmark:setVisible(false)
        self.txt_round16_checkmark:setTextColor(myColor[false])
    elseif self.roundCount == 16 then
        self.image_round8_checkmark:setVisible(false)
        self.txt_round8_checkmark:setTextColor(myColor[false])
        self.image_round16_checkmark:setVisible(true)
        self.txt_round16_checkmark:setTextColor(myColor[true])
    end

    self.root:getChildByName("bg"):getChildByName("btn_gps"):getChildByName("checkmark1"):setVisible(self.is_gpsModel)

    self.ctn_ma2 = self.root:getChildByName("bg"):getChildByName("btn_ma2") --2码勾选按钮
    self.ctn_ma2:addClickEventListener(function() self:onSetMa(2) end)
    
    self.image_ma2_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma2"):getChildByName("checkmark2")
    self.txt_ma2_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma2"):getChildByName("ma2")
    
    self.ctn_ma3 = self.root:getChildByName("bg"):getChildByName("btn_ma3") --3码勾选按钮
    self.ctn_ma3:addClickEventListener(function() self:onSetMa(3) end)
    
    self.image_ma3_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma3"):getChildByName("checkmark3")
    self.txt_ma3_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma3"):getChildByName("ma3")
    
    self.ctn_ma4 = self.root:getChildByName("bg"):getChildByName("btn_ma4") --4码勾选按钮
    self.ctn_ma4:addClickEventListener(function() self:onSetMa(4) end)

    self.image_ma4_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma4"):getChildByName("checkmark4")
    self.txt_ma4_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma4"):getChildByName("ma4")
    
    self.root:getChildByName("bg"):getChildByName("btn_ma6"):addClickEventListener(function() self:onSetMa(6) end)
    self.image_ma6_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma6"):getChildByName("checkmark6")
    self.txt_ma6_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma6"):getChildByName("ma6")
    
    self.root:getChildByName("bg"):getChildByName("btn_ma1"):addClickEventListener(function() self:onSetMa(1) end)
    self.image_ma1_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma1"):getChildByName("checkmark1")
    self.txt_ma1_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma1"):getChildByName("ma1")

    self.root:getChildByName("bg"):getChildByName("btn_ma1_2"):addClickEventListener(function() self:onSetMa(102) end)
    self.image_ma1_2_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma1_2"):getChildByName("checkmark1_2")
    self.txt_ma1_2_checkmark = self.root:getChildByName("bg"):getChildByName("btn_ma1_2"):getChildByName("ma1_2")

    self.root:getChildByName("bg"):getChildByName("btn_players3"):addClickEventListener(function() self:onSetPlayerNum(3) end)
    self.root:getChildByName("bg"):getChildByName("btn_players4"):addClickEventListener(function() self:onSetPlayerNum(4) end)
    
    --玩法选项:
    self.root:getChildByName("bg"):getChildByName("btn_wf1"):addClickEventListener(function() 
        self.is_8gehongzhong = not self.is_8gehongzhong
        self:onSetWanFa(1, self.is_8gehongzhong)
        self.root:getChildByName("bg"):getChildByName("btn_wf1"):getChildByName("checkmark1"):setVisible(self.is_8gehongzhong)
        self.root:getChildByName("bg"):getChildByName("btn_wf1"):getChildByName("gz"):setTextColor(myColor[self.is_8gehongzhong])
    end)

    self.root:getChildByName("bg"):getChildByName("btn_wf2"):addClickEventListener(function() 
        self.is_kedianpao = not self.is_kedianpao
        self:onSetWanFa(2, self.is_kedianpao)
        self.root:getChildByName("bg"):getChildByName("btn_wf2"):getChildByName("checkmark2"):setVisible(self.is_kedianpao)
        self.root:getChildByName("bg"):getChildByName("btn_wf2"):getChildByName("gz"):setTextColor(myColor[self.is_kedianpao])
    end)
    

    self.root:getChildByName("bg"):getChildByName("btn_gz"):addClickEventListener(function() 
        self.isgz = not self.isgz
        self.root:getChildByName("bg"):getChildByName("btn_gz"):getChildByName("checkmark1"):setVisible(self.isgz)
        self.root:getChildByName("bg"):getChildByName("btn_gz"):getChildByName("gz"):setTextColor(myColor[self.isgz])
    end)


    self.root:getChildByName("bg"):getChildByName("btn_qixiaodui"):addClickEventListener(function() 
            self.is_qixiaodui = not self.is_qixiaodui
            self:onSetQiXiaoDui() 
        end)
    self.check_qixiaodui = self.root:getChildByName("bg"):getChildByName("btn_qixiaodui"):getChildByName("check_qixiaodui")
    self.txt_check_qixiaodui = self.root:getChildByName("bg"):getChildByName("btn_qixiaodui"):getChildByName("ma4")

    self.root:getChildByName("bg"):getChildByName("btn_miluohongzhong"):addClickEventListener(function() 
            self.is_miluohongzhong = not self.is_miluohongzhong
            self:onSetMiLuoHongZhong() 
            self:onSetWanFa(3, self.is_miluohongzhong)
        end)
    self.check_miluohongzhong = self.root:getChildByName("bg"):getChildByName("btn_miluohongzhong"):getChildByName("check_miluohongzhong")
    self.txt_check_miluohongzhong = self.root:getChildByName("bg"):getChildByName("btn_miluohongzhong"):getChildByName("miluohonghzong")
    
    self.root:getChildByName("bg"):getChildByName("btn_gps"):addClickEventListener(function() 
        self.is_gpsModel = not self.is_gpsModel
        local msg = "gps防作弊功能"
        msg = self.is_gpsModel and msg .. "已开启" or msg .. "已关闭"
        GlobalFun:showToast(msg,Game_conf.TOAST_SHORT)

        self.root:getChildByName("bg"):getChildByName("btn_gps"):getChildByName("checkmark1"):setVisible(self.is_gpsModel)

        self:onClickGPSBtn()
    end)
    
    self:onSetQiXiaoDui() 
    self:onSetMiLuoHongZhong()
    self:onSetMa(self.maCount)
    self:onSetPlayerNum(self.playerNum)

    --[[
    if self.maCount == 2 then
        self.image_ma2_checkmark:setVisible(true)
        self.image_ma3_checkmark:setVisible(false)
        self.image_ma4_checkmark:setVisible(false)
    elseif self.maCount == 3 then
        self.image_ma2_checkmark:setVisible(false)
        self.image_ma3_checkmark:setVisible(true)
        self.image_ma4_checkmark:setVisible(false)
    elseif self.maCount == 4 then
        self.image_ma2_checkmark:setVisible(false)
        self.image_ma3_checkmark:setVisible(false)
        self.image_ma4_checkmark:setVisible(true)
    end
    ]]
    CCXNotifyCenter:listen(self,function(self,obj,data) self:showRuleByQiPao(data) end, "CreateRoomList_img_shuipao")--监听枫叶按钮点击

    --liebiao 
    local roomlist =  ex_fileMgr:loadLua("app.CreateRoom.CreateRoomList"):new()
    self.root:getChildByName("bg"):getChildByName("bg_leftPanel"):addChild(roomlist)
    roomlist:setPosition(cc.p(5, 20))

    --self:addChild(roomlist)
    --roomlist:setPosition(cc.p(303,318))


    local ctn_createRoom = self.root:getChildByName("bg"):getChildByName("btn_createRoom") --创建房间按钮
    ctn_createRoom:addClickEventListener(function() self:onBTNCreateRoom() end)
    

    --if self.quickFlag == true then
        --按上次配置重置参数
        local tb_str = UserDefault:getKeyValue("CreateRoomUI_LASTSETTING", "")
        if tb_str ~= "" then
            local tb = json.decode(tb_str)
            cclog("fuckfuckfuck")
            print_r(tb)

            self:onSetPlayerNum(tonumber(tb.playerNum))
            self:onSetRound(tonumber(tb.playerNum))
            if tb.PLAY_AK_ONE_ALL == true then
                self:onSetMa(102)
            else
                self:onSetMa(tonumber(tb.maCount))
            end

            self.is_8gehongzhong = tb.PLAY_EIGHT and tb.PLAY_EIGHT or false
            self:onSetWanFa(1, self.is_8gehongzhong)

            self.is_kedianpao = tb.PLAY_CONNON and tb.PLAY_CONNON or false
            self:onSetWanFa(2, self.is_kedianpao)

            self.is_miluohongzhong = tb.PLAY_LEILUO and tb.PLAY_LEILUO or false
            self:onSetWanFa(3, self.is_miluohongzhong)

            self.isgz = tb.canWatch and tb.canWatch or false
            self.root:getChildByName("bg"):getChildByName("btn_gz"):getChildByName("checkmark1"):setVisible(self.isgz)
            self.root:getChildByName("bg"):getChildByName("btn_gz"):getChildByName("gz"):setTextColor(myColor[self.isgz])

            self.is_qixiaodui = tb.PLAY_7D
            self:onSetQiXiaoDui() 

            -- local action = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function() 
            --     self:onBTNCreateRoom()
            -- end))
            -- self.root:getChildByName("bg"):getChildByName("btn_createRoom"):runAction(action)
            
        end
    --end
    if self.quickFlag == true then
        local action = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function() 
            self:onBTNCreateRoom()
        end))
        self.root:getChildByName("bg"):getChildByName("btn_createRoom"):runAction(action)
    end
end

function CreateRoomUI:onExit()
    --GlobalData.connectRoomCNT = nil
    --GlobalData.connectRoomZhaMa = nil

    self:unregisterScriptHandler()--取消自身监听
    CCXNotifyCenter:unListenByObj(self)
end

function CreateRoomUI:onUIClose()
    -- self:removeFromParent()
    platformExportMgr:returnAppPlatform()
end

function CreateRoomUI:onUIWanfa()
    cclog("打开玩法界面")
    local ui = ex_fileMgr:loadLua("app.views.RuleUI")
    self.root:addChild(ui.new())
end

function CreateRoomUI:onSetMiLuoHongZhong()
    self.check_miluohongzhong:setVisible(self.is_miluohongzhong)
    self.txt_check_miluohongzhong:setTextColor(myColor[self.is_miluohongzhong])

    UserDefault:setKeyValue("CreateRoomUI_CUIMiLuoHongZhong",self.is_miluohongzhong)
    UserDefault:write()
end

function CreateRoomUI:onSetQiXiaoDui()
    
    self.check_qixiaodui:setVisible(self.is_qixiaodui)
    self.txt_check_qixiaodui:setTextColor(myColor[self.is_qixiaodui])

    UserDefault:setKeyValue("CreateRoomUI_CUIQiXiaoDui",self.is_qixiaodui)
    UserDefault:write()
end

function CreateRoomUI:onSetRound(round)
    if round == 8 then
        if self.roundCount == 8 then
            return
        elseif self.roundCount == 16 then
            self.image_round8_checkmark:setVisible(true)
            self.txt_round8_checkmark:setTextColor(myColor[true])
            self.image_round16_checkmark:setVisible(false)
            self.txt_round16_checkmark:setTextColor(myColor[false])
            self.roundCount = 8
        end
    elseif round == 16 then
        if self.roundCount == 8 then
            self.image_round8_checkmark:setVisible(false)
            self.txt_round8_checkmark:setTextColor(myColor[false])
            self.image_round16_checkmark:setVisible(true)
            self.txt_round16_checkmark:setTextColor(myColor[true])
            self.roundCount = 16
        elseif self.roundCount == 16 then
            return
        end
    end
    UserDefault:setKeyValue("CURoundCount",self.roundCount)
    UserDefault:write()
end

function CreateRoomUI:onSetMa(ma)
    -- if ma == self.maCount then
    --     return
    -- end
    --cclog("ma = " .. ma)
    self.maCount = ma
    self.image_ma1_checkmark:setVisible(self.maCount == 1)
    self.txt_ma1_checkmark:setTextColor(myColor[self.maCount == 1])

    self.image_ma2_checkmark:setVisible(self.maCount == 2)
    self.txt_ma2_checkmark:setTextColor(myColor[self.maCount == 2])

    self.image_ma3_checkmark:setVisible(self.maCount == 3)
    self.txt_ma3_checkmark:setTextColor(myColor[self.maCount == 3])

    self.image_ma4_checkmark:setVisible(self.maCount == 4)
    self.txt_ma4_checkmark:setTextColor(myColor[self.maCount == 4])

    self.image_ma6_checkmark:setVisible(self.maCount == 6)
    self.txt_ma6_checkmark:setTextColor(myColor[self.maCount == 6])

    self.image_ma1_2_checkmark:setVisible(self.maCount == 102)
    self.txt_ma1_2_checkmark:setTextColor(myColor[self.maCount == 102])

    UserDefault:setKeyValue("CUIMaCount",self.maCount)
    UserDefault:write()
end

function CreateRoomUI:onSetWanFa(index, flag)
    local func = {}
    func[1] = function (flag)
        if flag ~= nil then self.is_8gehongzhong = flag end
        self.root:getChildByName("bg"):getChildByName("btn_wf1"):getChildByName("checkmark1"):setVisible(self.is_8gehongzhong)
        self.root:getChildByName("bg"):getChildByName("btn_wf1"):getChildByName("gz"):setTextColor(myColor[self.is_8gehongzhong])
    end

    func[2] = function (flag)
        if flag ~= nil then self.is_kedianpao = flag end
        self.root:getChildByName("bg"):getChildByName("btn_wf2"):getChildByName("checkmark2"):setVisible(self.is_kedianpao)
        self.root:getChildByName("bg"):getChildByName("btn_wf2"):getChildByName("gz"):setTextColor(myColor[self.is_kedianpao])
    end
     
    func[3] = function (flag)
        if flag ~= nil then self.is_miluohongzhong = flag end
        self.root:getChildByName("bg"):getChildByName("btn_miluohongzhong"):getChildByName("check_miluohongzhong"):setVisible(self.is_miluohongzhong)
        self.root:getChildByName("bg"):getChildByName("btn_miluohongzhong"):getChildByName("miluohonghzong"):setTextColor(myColor[self.is_miluohongzhong])
    end

    for i = 1, #func do
        if i ~= index and flag == true then
            func[i](false)
        elseif i ~= index and flag == false then
            func[i]()
        elseif i == index then
            func[i](flag)
        end
    end    
end

function CreateRoomUI:onSetPlayerNum(num)
    -- if num == self.playerNum then
    --     return
    -- end
    self.playerNum = num
    self.img_players3:setVisible(self.playerNum == 3)
    self.txt_players3:setTextColor(myColor[self.playerNum == 3])
    self.img_players4:setVisible(self.playerNum == 4)
    self.txt_players4:setTextColor(myColor[self.playerNum == 4])

    UserDefault:setKeyValue("CUIPlayerNum",self.playerNum)
    UserDefault:write()
end

function CreateRoomUI:onBTNCreateRoom()
    cclog("self.roundCount=" .. self.roundCount .. ",self.maCount=" .. self.maCount)
   
    GlobalData.openRoom = true
    

    GameRule.MAX_GAMECNT = self.roundCount
    GameRule.cur_GameCNT = 1
    GameRule.ZhaMaCNT = self.maCount

    GameRule.PLAY_EIGHT = self.is_8gehongzhong
    GameRule.PLAY_CONNON = self.is_kedianpao
    GameRule.PLAY_AK_ONE_ALL = self.maCount == 102 and true or false

    GlobalData.connectRoomCNT = self.roundCount
    GlobalData.connectRoomZhaMa = self.maCount
    --ex_hallHandler:createRoom(10240,self.maCount)
    
    --self.is_8gehongzhong = false
    --self.is_kedianpao = false

    local tb = {PLAY_LEILUO = self.is_miluohongzhong, PLAY_7D = self.is_qixiaodui, canWatch = self.isgz,isDelegate = true, isGPS = self.is_gpsModel}
    tb.PLAY_EIGHT = self.is_8gehongzhong
    tb.PLAY_CONNON = self.is_kedianpao
    tb.PLAY_AK_ONE_ALL = self.maCount == 102 and true or false

    local tb_str = json.encode(tb)
    cclog("CreateRoomUI:onBTNCreateRoom >>>>", tb_str)
    cclog("playerNum:"..self.playerNum)
    local maCount = self.maCount == 102 and 0 or self.maCount
    cclog("maCount:"..maCount)

    GlobalData.json_enter = tb_str
    ex_hallHandler:createRoom(self.roundCount,self.playerNum*10 + maCount,tb_str)
    --cclog("打开麻将界面")
    --self.app:enterScene("game/CUIGame") 

    --记录最新一次配置
    tb.roundCount = self.roundCount
    tb.playerNum = self.playerNum
    tb.maCount = maCount
    local tb_str = json.encode(tb)
    UserDefault:setKeyValue("CreateRoomUI_LASTSETTING", tb_str)
    UserDefault:write()
end

function CreateRoomUI:onClickGPSBtn()
    UserDefault:setKeyValue("CreateRoomUI_GPSMODEL",self.is_gpsModel)
    UserDefault:write()
    local btn_gps = self.root:getChildByName("bg"):getChildByName("btn_gps")
    btn_gps:setBright(self.is_gpsModel)   
end

--定位枫叶
function CreateRoomUI:showRuleByQiPao(data)
    cclog("fuckfuckfuck showRuleByQiPao")
    print_r(data)
    local img_shuipao = self.root:getChildByName("img_shuipao")
    local shuipaoContent = img_shuipao:getChildByName("shuipaoContent")
    shuipaoContent:setString(data.content)
    img_shuipao:setPosition(cc.p(data.worldPos.x, data.worldPos.y))
    img_shuipao:setVisible(true)
    img_shuipao:stopActionByTag(8888)
    local action = cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function() 
            img_shuipao:setVisible(false)
        end))
    action:setTag(8888)
    img_shuipao:runAction(action)
end

return CreateRoomUI
