local CUIGame_HuHandPatterns = class("CUIGame_HuHandPatterns",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")
--local temp = true
function CUIGame_HuHandPatterns:ctor()
    self.root = display.newCSNode("game/CUIGame_HuHandPatterns.csb")
    self.root:addTo(self)
    
    
    self:setVisible(false)
 
end

function CUIGame_HuHandPatterns:setShowCards(cards)
    
    local Image_1 = self.root:getChildByName("Image_1")
    local Image_3 = Image_1:getChildByName("Image_3")
    local ctn_cards = Image_3:getChildByName("ctn_cards")
    if ctn_cards:getChildrenCount() > 0 then
        ctn_cards:removeAllChildren()
    end
--[[
   cclog("CUIGame_HuHandPatterns:setShowCards  temp:"..tostring(temp))
   local abc = {}
    if temp == true then
        for i = 1, 3 do
            table.insert(abc, cards[1])
        end
        temp = false
    else
        for i = 1, 17 do
            table.insert(abc, cards[1])
        end
        temp = true
    end
    cards = abc
--]]
    cclog("#cards:"..#cards) 
    --排个序
    table.sort(cards, function(a, b)
        return a < b
    end)

    local sizeW_1 = 240     -- 3
    local sizeW_2 = 420     -- 6
    local sizeW_3 = 600     -- 9

    if #cards <= 9 then
        local originalSize = Image_1:getContentSize()
        local originalSize2 = Image_3:getContentSize()

        if #cards <= 3 then
            Image_1:setContentSize(sizeW_1, originalSize.height)
            Image_3:setContentSize(sizeW_1 - 60, originalSize2.height)

        elseif #cards <= 6 then
            Image_1:setContentSize(sizeW_2, originalSize.height)
            Image_3:setContentSize(sizeW_2 - 60, originalSize2.height)

        else
            Image_1:setContentSize(sizeW_3, originalSize.height)
            Image_3:setContentSize(sizeW_3 - 60, originalSize2.height)

        end

        for i = 1, #cards do
            local tmp_d = {pos = 0,num = cards[i],state = 4,player = nil}
            local newCard = BaseMahjong.new(tmp_d)

            newCard:setScale(0.7)
            local w, h = newCard:getWidthAndHeight()
            w = w/2 - 2.5
            newCard:setPosition(((i-1)%15)*w/0.35*0.7 + 10, -h*0.7/3 - 5)
            ctn_cards:addChild(newCard)
        end
    else
        local originalSize = Image_1:getContentSize()
        local originalSize2 = Image_3:getContentSize()
        Image_1:setContentSize(sizeW_3, originalSize.height)
        Image_3:setContentSize(sizeW_3 - 60, originalSize2.height)

        for i = 1, #cards do
            local tmp_d = {pos = 0,num = cards[i],state = 4,player = nil}
            local newCard = BaseMahjong.new(tmp_d)
            newCard:setScale(0.4)
            local w,h = newCard:getWidthAndHeight()
            w = w/2 + 2
            local lineNum = math.floor(i / 16)
            if lineNum < 1 then
                newCard:setPosition(((i-1)%30)*w, 0)
            else
                newCard:setPosition(((i-1-lineNum*16)%30)*w , -(h * 0.4 * lineNum + 12))
            end
            ctn_cards:addChild(newCard)
        end
    end 
    
    
    if #cards > 0 then
        self:setVisible(true)
    else
        self:setVisible(false)
    end
end

return CUIGame_HuHandPatterns