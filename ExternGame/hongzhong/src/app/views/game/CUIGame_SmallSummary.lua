local CUIGame_SmallSummary = class("CUIGame_SmallSummary",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")

function CUIGame_SmallSummary:ctor(data,scene)
    self.root = display.newCSNode("game/CUIGame_SmallSummary.csb")
    self.root:addTo(self)
    
    
    local id = nil
    local offset = nil
    for i=1,4 do
        if scene.player[i].serverPos == 1 then
            id = scene.player[i].id
            break
        end
    end
    if id then
        for i=1,4 do
            if data.p_data[i].playerid == id then
                offset = i-1
                break
            end
        end
    end
    if offset then
        local tmp_data = {}
        for i=1,4 do
            local tmp_index = i-offset
            if tmp_index < 1 then
                tmp_index = tmp_index + 4
            end
            tmp_data[tmp_index] = data.p_data[i]
        end
        data.p_data = tmp_data
    end
    
    
    local BaseItem = ex_fileMgr:loadLua("app.views.game.item_SmallSummary")
    for i=1,3 do
        if data.p_data[i] == nil then
            data.p_data[i] = data.p_data[i+1]
            data.p_data[i+1] = nil
        end
    end

    local iswin = false
    for i=1,#data.p_data do
        self.root:getChildByName(string.format("ctn_%d",i)):addChild(BaseItem.new(data.p_data[i],scene,i))
        if scene.player[1].openid == data.p_data[i].playerid then
            for j=1 , #scene.winBean do
                if scene.winBean[j] == data.p_data[i].playerid then
                    iswin = true
                    break
                end
            end
        end
    end
    self.root:getChildByName("title"):setVisible(iswin)
    self.root:getChildByName("title_2"):setVisible(not iswin)
    
    for i=1,#data.remaining do
        local tmp_d = {pos = 0,num = data.remaining[i],state = 4,player = nil}
        local newCard = BaseMahjong.new(tmp_d)
        newCard:setScale(0.47)
        local w,h = newCard:getWidthAndHeight()
        w = w/2 + 2
        h = h*5/11
        local start_x = -w*15+w/2
        newCard:setPosition(start_x+((i-1)%30)*w,0-math.floor((i-1)/30)*h)
        self.root:getChildByName("ctn_showcard"):addChild(newCard)
    end
    
    scene.winBean = nil
    scene.zhama = nil
    self.scene = scene
    
    --scene.smallSummary = nil

    self.root:getChildByName("ctn_btn"):getChildByName("btn_share"):addClickEventListener(function() self:onShare() end)
    self.root:getChildByName("ctn_btn"):getChildByName("btn_continue"):addClickEventListener(function() self:onContinue() end)
    
    if true then
        self.updata_t = 0
        local function handler(t)
            self:update(t)
        end
        self:scheduleUpdateWithPriorityLua(handler,0)
    end
    
    self.dmt = 10--比赛多少秒后开始
    if GameRule.cur_GameCNT < GameRule.MAX_GAMECNT and scene.isMatch then
        self.root:getChildByName("ctn_match"):setVisible(true)
        self.root:getChildByName("ctn_match"):getChildByName("txt_time"):setString(math.floor(self.dmt))
    end


    

    self:registerScriptHandler(function(state)
        if state == "enter" then
        self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
end



function CUIGame_SmallSummary:onEnter()

    CCXNotifyCenter:notify("ActivitysStarGotLock", false) -- 活动任务显示解锁
end
function CUIGame_SmallSummary:onExit()
    
end

function CUIGame_SmallSummary:update(t)
    if self.updata_t >= 0 then
        self.updata_t = self.updata_t + t
        if self.updata_t > 0.1 then
            self.updata_t = -1
            if self.scene.isMatch ~= true then
                if self.scene.videoData then
                    LocalDataFile:writeVideo(self.scene.videoData, self.scene.originType, self.scene.originKey)
                end
            end
        end
    end
    
    self.dmt = self.dmt - t
    if self.dmt < 0 then
        self.dmt = 0
    end
    self.root:getChildByName("ctn_match"):getChildByName("txt_time"):setString(math.floor(self.dmt))
end

function CUIGame_SmallSummary:onShare()
    
    cclog("on Share")
    self.root:addChild(ex_fileMgr:loadLua("app/Common/CUIShareType").new(1))
end

function CUIGame_SmallSummary:onContinue()
    --cclog("on Continue")
    --CCXNotifyCenter:notify("retrySaveVideo",nil)
    CCXNotifyCenter:notify("continueGame",nil)

    local i_am_watch = self.scene:checkMeIsWatch()

    if self.scene.isWatch and i_am_watch then
        if GameRule.cur_GameCNT < GameRule.MAX_GAMECNT and self.scene.allSummaryData == nil then--判断是不是打完了所有的局

        else
            CCXNotifyCenter:notify("AllSummaryNotify",nil)
        end
        self.scene.smallSummary = nil
        self:removeFromParent()
        return
    end


    if GlobalData.log == nil then
        GlobalData.log = ""
    end
    if self.scene.isMatch ~= true then
        UserDefault:writeFile("timeError.log",GlobalData.log)
    end
    GlobalData.log = "" --把上一局的数据清了
    if GameRule.cur_GameCNT < GameRule.MAX_GAMECNT and self.scene.allSummaryData == nil then--判断是不是打完了所有的局
        --重新开局
        CCXNotifyCenter:notify("reOpen",nil)
    else
        if self.scene.isMatch then
            --GlobalFun:showToast("比赛未结束，请耐心等待其他玩家!",Game_conf.TOAST_SHORT)
            self.scene.isOverWait = true
            local sMSG = "比赛未结束，请耐心等待其他玩家!"
            if self.scene.MatchOver then
                sMSG = sMSG .. "(还剩" .. self.scene.MatchOver.total - self.scene.MatchOver.remaining  .."桌)"
            end
            GlobalFun:showError(sMSG,nil,nil,3)
        else
            CCXNotifyCenter:notify("AllSummaryNotify",nil)
        end
    end
    self.scene.smallSummary = nil
    self:removeFromParent()
end

return CUIGame_SmallSummary
