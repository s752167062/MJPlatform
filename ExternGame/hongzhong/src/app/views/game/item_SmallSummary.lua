local item_SmallSummary = class("item_SmallSummary",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")
local BasePlayerInfo = ex_fileMgr:loadLua("app.views.game.CUIGame_playerinfo")

function item_SmallSummary:ctor(data,scene,index)
    self.root = display.newCSNode("game/item_SmallSummary.csb")
    self.root:addTo(self)
    
    -- self.root:getChildByName("img_holder"):setVisible(data.playerid == GlobalData.roomCreateID and scene.isMatch ~= true)
    
    local flag = scene.player[1].openid == data.playerid
    --self.root:getChildByName("bg_1"):setVisible(flag)
    --self.root:getChildByName("bg_2"):setVisible(not flag)
    
    
    local pos = 1
    for i=1,4 do
        if scene.player[i].openid == data.playerid then
            pos = i
            break
        end
    end
    cclog("*********ITEM SMALL BASEDATA SET")
    local photo = BasePlayerInfo.new()
    photo:setScale(0.35)
    photo:setBaseData(scene.player[pos])
    photo:setPlayerName(scene.player[pos].name)
    photo:smallSummaryPhoto()
    photo:setZhuangVisible(scene.player[pos].isBanker)
    photo:showFangZhu(data.playerid == GlobalData.roomCreateID and scene.isMatch ~= true)
    photo:setNameColor(cc.c3b(255,231,178))
    self.root:getChildByName("ctn_player"):addChild(photo)

    
    
    scene.player[pos]:setScore(data.score)
    
    if data.score > 0 then
        self.root:getChildByName("txt_score_win"):setString(string.format("+%d",data.score))
        self.root:getChildByName("txt_score_lose"):setVisible(false)
    else
        self.root:getChildByName("txt_score_lose"):setString(string.format("%d",data.score))
        self.root:getChildByName("txt_score_win"):setVisible(false)
    end
    
    local card_width = 0
    local start_x = -420
    local txt_ming_i = 1
    for i=1,#data.mingpai do
        local state = 5
        for j=1,#data.mingpai[i] do
            if data.mingpai[i][j].flag == 5 and j ~= 4 then
                state = 6
            else
                state = 5
            end
            local tmp_d = {pos = 0,num = data.mingpai[i][j].cardnum,state = state,player = nil}
            local newCard = BaseMahjong.new(tmp_d)
            newCard:setScale(0.7)
            local w,h = newCard:getWidthAndHeight()
            w = w*0.35 +4
            h = h*5/11
            if card_width == 0 then
                card_width = w
            end
            newCard:setPosition(start_x,10)
            start_x = start_x + w
            self.root:addChild(newCard)
            if data.mingpai[i][j].flag == 2 and j == 2 then--接杠
                local txt_ming = self.root:getChildByName(string.format("txt_ming%d",txt_ming_i))
                txt_ming:setVisible(true)
                txt_ming:setString("接杠")
                txt_ming:setPositionX(start_x - w/2)
                txt_ming_i = txt_ming_i + 1
            elseif data.mingpai[i][j].flag == 3 and j == 2 then--公杠
                local txt_ming = self.root:getChildByName(string.format("txt_ming%d",txt_ming_i))
                txt_ming:setVisible(true)
                txt_ming:setString("公杠")
                txt_ming:setPositionX(start_x - w/2)
                txt_ming_i = txt_ming_i + 1
            elseif data.mingpai[i][j].flag == 5 and j == 2 then--暗杠
                local txt_ming = self.root:getChildByName(string.format("txt_ming%d",txt_ming_i))
                txt_ming:setVisible(true)
                txt_ming:setString("暗杠")
                txt_ming:setPositionX(start_x - w/2)
                txt_ming_i = txt_ming_i + 1
            end
            
        end
        start_x = start_x + 15
    end
    

    local iswin = false
    for i=1 , #scene.winBean do
        if scene.winBean[i] == data.playerid then
            iswin = true
            break
        end
    end

    if flag then
        self.root:getChildByName("bg_1"):setVisible(iswin)
        self.root:getChildByName("bg_2"):setVisible(not iswin)
    end

    for i=1,#data.handcard do
        if iswin then
            if (#data.handcard % 3) == 1 then--抢杠胡  需要加一张牌
                data.handcard[#data.handcard + 1] = scene.winValue
                break
            end
            if data.handcard[i] == scene.winValue then--找到自摸的牌插到最后
                table.remove(data.handcard,i)
                table.insert(data.handcard,#data.handcard+1,scene.winValue)
                break
            end
        else
            break
        end
    end

    for i=1,#data.handcard do
        local tmp_d = {pos = 0,num = data.handcard[i],state = 3,player = nil}
        local newCard = BaseMahjong.new(tmp_d)
        newCard:setScale(0.35)
        local w,h = newCard:getWidthAndHeight()
        w = w*0.35 + 4
        if card_width == 0 then
            card_width = w
        end
        if i == #data.handcard and iswin then
            cclog("data.handcard[i] == scene.winValue >>", data.handcard[i] , scene.winValue)
            -- if data.handcard[i] == scene.winValue then
                start_x = start_x + 40
                --self.root:getChildByName("img_hu"):setVisible(true)
                -- self.root:getChildByName("img_hu"):setPositionX(start_x)
            -- end
        end
        newCard:setPosition(start_x,10)
        start_x = start_x + w
        self.root:addChild(newCard)
    end
    
    --处理显示扎码
    self.root:getChildByName("ctn_zhama"):setVisible(iswin)
    local txt_title = self.root:getChildByName("txt_title")
    txt_title:setPositionX(start_x -card_width)
    txt_title:setVisible(iswin)
    
    local txt_title_str = ""
    if iswin then
        if scene.huPaiType == 1 then
            if data.isFanggang then
                txt_title_str = "放杠自摸"
                -- txt_title:setString("放杠自摸")
            else
                txt_title_str = "自摸"
                -- txt_title:setString("自摸")
            end
        elseif scene.huPaiType == 2 then
            if data.isFanggang then
                txt_title_str = "放杠抢杠胡"
                -- txt_title:setString("放杠抢杠胡")
            else
                txt_title_str = "抢杠胡"
                -- txt_title:setString("抢杠胡")
            end
        elseif scene.huPaiType == 3 then
            txt_title_str = "点炮"
        else
            txt_title:setVisible(false)
        end


        if scene.player_hu_info and next(scene.player_hu_info) then
            local htype = false
            for k,v in ipairs(scene.player_hu_info) do
                for m,n in ipairs(v.info or {}) do
                    if n.hu_type == 0 then
                        txt_title_str = txt_title_str .. "七小对"
                        htype = true
                        break
                        -- txt_title:setString("七小对")
                    end
                end
                if htype then break end
            end
        end


        txt_title:setString(txt_title_str)



        local a = 5--间隔
        start_x = -(a + card_width)*(#scene.zhama-1)/2
        local gou_index = 1
        for i=1,#scene.zhama do
            local tmp_d = {pos = 0,num = scene.zhama[i],state = 3,player = nil}
            local newCard = BaseMahjong.new(tmp_d)
            newCard:setScale(0.35)
            newCard:setPosition(start_x,20)
            start_x = start_x + (card_width + a)
            self.root:getChildByName("ctn_zhama"):addChild(newCard)
            
            if (scene.zhama[i]%10)%4 == 1 or GameRule.ZhaMaCNT == 1 then
                local img_gou = self.root:getChildByName("ctn_zhama"):getChildByName(string.format("img_gou%d",gou_index))
                img_gou:setVisible(true)
                img_gou:setLocalZOrder(100)
                gou_index = gou_index + 1
                img_gou:setPosition(newCard:getPositionX(),newCard:getPositionY() - 20)
            end
        end
    end
    
    
    local txt_title_str = ""
    if iswin ~= true then
        if data.isFanggang then
            -- txt_title:setVisible(true)
            -- txt_title:setString("放杠")
            txt_title_str = "放杠"
        end

        if scene.fangpao_player > 0 and data.playerid == scene.fangpao_player then
            if txt_title_str ~= "" then txt_title_str = txt_title_str .. " " end
            txt_title_str = txt_title_str .. "放炮"
        end

        txt_title:setVisible(true)
        txt_title:setString(txt_title_str)
    end
end

return item_SmallSummary
