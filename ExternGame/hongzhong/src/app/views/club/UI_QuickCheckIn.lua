

local UI_QuickCheckIn = class("UI_QuickCheckIn", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_QuickCheckIn:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_QuickCheckIn.csb")
    self.root:addTo(self)

	UI_QuickCheckIn.super.ctor(self)

	-- self._listItem = function() return display.newCSNode("club/UI_QuickCheckIn_Item_Rule.csb"):getChildByName("itemLayout") end

	CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onGameSetting(data) end, "res_onGameSetting")

	_w = self._childW
	self._ruleData = {}
  	
  	self:setMainUI()

end

function UI_QuickCheckIn:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function UI_QuickCheckIn:update(t)
    
end

function UI_QuickCheckIn:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then

        self:closeUI()
    end
end

function UI_QuickCheckIn:onTouch(_sender, _type)
	
end

--主设置
function UI_QuickCheckIn:setMainUI()
	_w["list"]:removeAllItems()
	_w["txt_hint"]:setVisible(false)
	ex_clubHandler:gotoGameSetting()
end

function UI_QuickCheckIn:res_onGameSetting(_data)
	cclog("UI_QuickCheckIn:res_onGameSetting")
	print_r(_data)
	self:copyTable(_data, self._ruleData)
	if _data.playRuleNum > 0 then
		_w["txt_hint"]:setVisible(false)
		for i = 1, #(_data.playRuleTb) do
		--设置item
			-- local item = self._listItem() 
			-- local _itemW = self:loadChildrenWidget(item)

			-- -- -- _itemW["btn_start"]:setTag(i)
			-- -- _itemW["btn_start"]:setTouchEnabled(true)
			-- _itemW["btn_start"]:btn_start(
			-- 	function(sender)
			-- 		-- local index = sender:getTag()
			-- 		cclog("I'm a btn_start index:"..index)
			-- 		-- ex_clubHandler:gotoRequestCreateRoom(index)
			-- 	end
			-- )
			-- -- _itemW["btn_open_test"]:setTag(i)
			-- -- _itemW["btn_open_test"]:addClickEventListener(
			-- -- 	function(sender)
			-- -- 		local index = sender:getTag()
			-- -- 		cclog("I'm a btn_open_test index:"..index)
			-- -- 		ex_clubHandler:gotoRequestCreateRoom(index)
			-- -- 	end
			-- -- )

			local layout = ccui.Layout:create()
        	layout:setContentSize(cc.size(650,100))

        	local item = display.newCSNode("club/UI_QuickCheckIn_Item_Rule.csb")
        	item:addTo(layout)
        	local _itemW = self:loadChildrenWidget(item)
        	-- item:setTag(i)

        	local str = GameRule:clubRoomRuleText(_data)
        	_itemW["txt_roomRule"]:setString(str)
        	_itemW["txt_roomRule"]:ignoreContentAdaptWithSize(false)
        	_itemW["txt_roomRule"]:setTextAreaSize(cc.size(330,60))

        	local str = GameRule:clubGameRuleText(_data.playRuleTb[i])
        	_itemW["txt_gameRule"]:setString(str)
        	_itemW["txt_gameRule"]:ignoreContentAdaptWithSize(false)
        	_itemW["txt_gameRule"]:setTextAreaSize(cc.size(330,60))

        	local btn_start = item:getChildByName("itemLayout"):getChildByName("btn_start")
        	btn_start:addClickEventListener(function (sender)
        			-- local index = sender:getTag()
        			cclog("btn_start >>>>>>>>")
        			ex_clubHandler:gotoRequestCreateRoom(i)
        		end)

			
			_w["list"]:pushBackCustomItem(layout)
		end
	else
		_w["txt_hint"]:setVisible(true)
	end
end

return UI_QuickCheckIn
