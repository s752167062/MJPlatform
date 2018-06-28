local LouHuNode = class("LouHuNode", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

LouHuNode.RESOURCE_FILENAME = "game/CUIPlayer_FengHu.csb"
LouHuNode.RESOURCE_BINDING = {
    -- ["btn_cancel"]       = {    ["varname"] = "btn_cancel"     ,  ["events"] = { {event = "click" ,  method ="onClose"        } }     },
    
    ["txt_bg"]       = {    ["varname"] = "txt_bg"      },
    ["btn_bg"]       = {    ["varname"] = "btn_bg"   , ["events"] = { {event = "click" ,  method ="onClickBtnBg"        } }   },
    ["cards_node"]       = {    ["varname"] = "cards_node"      },
}

local BaseMahjong = ex_fileMgr:loadLua("app.views.game.CSBMahjong")

function LouHuNode:onCreate()

    self.root = self:getResourceNode()
    self:showTxt(false)
end

function LouHuNode:onEnter()


	cclog("LouHuNode:onEnter  >>>>")
end

function LouHuNode:onExit()
	CCXNotifyCenter:unListenByObj(self)
	self:unregisterScriptHandler()
	cclog("LouHuNode:onExit  >>>>")
end

function LouHuNode:onClose()
    self:removeFromParent()
end

-- params 
function LouHuNode:setCards(params)
	self.cards_node:removeAllChildren()

	local cards = params.cards
	for i=1,#cards do
		local card = GlobalFun:ServerCardToLocalCard(cards[i])
        local tmp_d = {pos = 0,num = card,state = 4,player = nil}
        local newCard = BaseMahjong.new(tmp_d)
        newCard:setScale(0.38)
        local w,h = newCard:getWidthAndHeight()
        w = w/2 + 2
        newCard:setPosition(((i-1)%30)*w,0)
        self.cards_node:addChild(newCard)
    end
end

function LouHuNode:onClickBtnBg()
	self:showTxt()
end

function LouHuNode:showTxt(flag)
	
	if flag ~= nil then
		self.isShowTxt = flag
	else
		self.isShowTxt = not self.isShowTxt
	end
	self.txt_bg:setVisible(self.isShowTxt)
end

return LouHuNode








