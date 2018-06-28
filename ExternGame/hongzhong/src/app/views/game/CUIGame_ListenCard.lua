local CUIGame_ListenCard = class("CUIGame_ListenCard",function() 
    return cc.Node:create()
end)

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")

function CUIGame_ListenCard:ctor()
    self.root = display.newCSNode("game/CUIGame_ListenCard.csb")
    self.root:addTo(self)
    
    
    self:setVisible(false)
end

function CUIGame_ListenCard:setShowCards(cards)

    if self.root:getChildByName("ctn_cards"):getChildrenCount() > 0 then
        self.root:getChildByName("ctn_cards"):removeAllChildren()
    end
    
    for i=1,#cards do
        local tmp_d = {pos = 0,num = cards[i],state = 4,player = nil}
        local newCard = BaseMahjong.new(tmp_d)
        newCard:setScale(0.38)
        local w,h = newCard:getWidthAndHeight()
        w = w/2 + 2
        newCard:setPosition(((i-1)%30)*w,0)
        self.root:getChildByName("ctn_cards"):addChild(newCard)
    end
    
    if #cards > 0 then
        self:setVisible(true)
    else
        self:setVisible(false)
    end
end

return CUIGame_ListenCard