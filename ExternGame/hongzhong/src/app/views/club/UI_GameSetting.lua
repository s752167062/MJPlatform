

local UI_GameSetting = class("UI_GameSetting", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_GameSetting:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_GameSetting.csb")
    self.root:addTo(self)

	UI_GameSetting.super.ctor(self)
	_w = self._childW
	
	-- self._listItem = function() return display.newCSNode("club/UI_GameSetting_Item_Template.csb"):getChildByName("itemLayout") end

	CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onGameSetting(data) end, "res_onGameSetting")
	CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onModifyGameSetting(data) end, "res_onModifyGameSetting")
	CCXNotifyCenter:listen(self,function(obj,key,data) self:onDeleteSetting(data) end, "CLUB:onDeleteSetting")
	




	self.cbx_groups = {
		kfqx = {
			btn_item_1_1 = {obj = _w["btn_item_1_1"], state = true },
			btn_item_1_2 = {obj = _w["btn_item_1_2"], state = false}
			},
		kfk = {
			btn_item_2_1 = {obj = _w["btn_item_2_1"], state = true },
			btn_item_2_2 = {obj = _w["btn_item_2_2"], state = false}
			},
		jrtj = {
			btn_item_3_1 = {obj = _w["btn_item_3_1"], state = true },
			btn_item_3_2 = {obj = _w["btn_item_3_2"], state = false}
			},
	}
	self:checkboxGroupSel("btn_item_1_1")
	self:checkboxGroupSel("btn_item_2_1")
	self:checkboxGroupSel("btn_item_3_1")
	


  	self:setMainUI()

end

function UI_GameSetting:checkboxGroupSel(cbx_name)
	cclog("checkboxGroupSel >>>", cbx_name)
	local group = {}
	for k,v in pairs(self.cbx_groups) do
		
		if v[cbx_name] then
			group = v
			break
		end
		
	end

	for k,v in pairs(group) do
		if k == cbx_name then
			v.obj:setSelected(true)
			v.obj:setTouchEnabled(false)
			v.state = true

		else
			v.obj:setSelected(false)
			v.obj:setTouchEnabled(true)
			v.state = false
		end
	end
end



function UI_GameSetting:onEnter()
-- 	PLAY_LEILUO
-- PLAY_7D
-- canWatch
-- PLAY_EIGHT
-- PLAY_CONNON
-- PLAY_AK_ONE_ALL
	-- local res = {}

 --    res.type_1 = 1
 --    res.type_2 = 1
 --    res.type_3 = 1
 --    res.playRuleNum = 0
 --    res.playRuleTb = {}
 --    for i = 1, res.playRuleNum do
 --        local item = '{"gameType" : "hz", "PLAY_LEILUO" : true, "PLAY_7D" : true, "PLAY_EIGHT": true,"PLAY_CONNON" : true, "PLAY_AK_ONE_ALL" : true, "za" : 0}'
 --        table.insert(res.playRuleTb, item)
 --    end

 --    GameRule.GameSetting.type_1 = res.type_1
 --    GameRule.GameSetting.type_2 = res.type_2
 --    GameRule.GameSetting.type_3 = res.type_3


	-- self:res_onGameSetting(res)
end

function UI_GameSetting:onExit()
    CCXNotifyCenter:unListenByObj(self)
end


function UI_GameSetting:update(t)
    
end

function UI_GameSetting:onClick(_sender)
	local name = _sender:getName()
	cclog("onClick >", name)
	if name == "btn_close" then

        self:closeUI()
	-- elseif name == "btn_save" then --储存
		
	elseif name == "btn_help" then --帮助
		local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubHelp")
        scene:addChild(ui.new({app = nil}))
	elseif name == "btn_item_1_1" then --1_1
		-- self:setMenu_1_CMD()
		self:checkboxGroupSel(name)
		ex_clubHandler:gotoModifyGameSetting({model = 0, value = 0})
	elseif name == "btn_item_1_2" then --1_2
		-- ex_clubHandler:gotoModifyGameSetting(data)
		self:checkboxGroupSel(name)
		ex_clubHandler:gotoModifyGameSetting({model = 0, value = 1})
	elseif name == "btn_item_2_1" then --1_1
		self:checkboxGroupSel(name)
		ex_clubHandler:gotoModifyGameSetting({model = 1, value = 0})
	elseif name == "btn_item_2_2" then --1_1
		self:checkboxGroupSel(name)
		ex_clubHandler:gotoModifyGameSetting({model = 1, value = 1})
	elseif name == "btn_item_3_1" then --1_1
		self:checkboxGroupSel(name)
		ex_clubHandler:gotoModifyGameSetting({model = 2, value = 0})
	elseif name == "btn_item_3_2" then --1_1
		self:checkboxGroupSel(name)
		ex_clubHandler:gotoModifyGameSetting({model = 2, value = 1})
		
	end
end

function UI_GameSetting:onTouch(_sender, _type)
	
end

--主设置
function UI_GameSetting:setMainUI()




	
	ex_clubHandler:gotoGameSetting()

	self:setList()
end



function UI_GameSetting:setList()
	_w["methodList"]:removeAllItems()
	

end


function UI_GameSetting:setCurRoomRuleUiState(params)
	if params.type_1 == 0 then
		self:checkboxGroupSel("btn_item_1_1")
	else
		self:checkboxGroupSel("btn_item_1_2")
	end

	if params.type_2 == 0 then
		self:checkboxGroupSel("btn_item_2_1")
	else
		self:checkboxGroupSel("btn_item_2_2")
	end

	if params.type_3 == 0 then
		self:checkboxGroupSel("btn_item_3_1")
	else
		self:checkboxGroupSel("btn_item_3_2")
	end

	
end


function UI_GameSetting:res_onGameSetting(_data)
	cclog("UI_GameSetting:res_onGameSetting")
	print_r(_data)
	_w["methodList"]:removeAllItems()
	self:setCurRoomRuleUiState(_data)


	if _data.playRuleNum > 0 then
		for i = 1, #(_data.playRuleTb) do
			-- local item = self._listItem()
			local info = json.decode(_data.playRuleTb[i])
			local name = ClubManager:getGameTypeNameText(info.gameType)
			cclog("name >>>", name)  ---现在的ui没有用上，预留拓展

			local layout = ccui.Layout:create()
        	layout:setContentSize(cc.size(980,100))
        	_w["methodList"]:pushBackCustomItem(layout)

        	local item = display.newCSNode("club/UI_GameSetting_Item_Template.csb")
        	item:addTo(layout)

			local _itemW = self:loadChildrenWidget(item)
			-- _itemW["title"]:setString("红中麻将")
			_itemW["node_add"]:setVisible(false)
			local str = GameRule:clubRoomRuleText(_data)
			_itemW["content"]:setString(str)

			local str = GameRule:clubGameRuleText(_data.playRuleTb[i])
			_itemW["content2"]:setString(str)

			--动态修改字体大小
			local function modifyFontSize(senderText)
				local str = senderText:getString()
				local count = self:utf8len(str)
				if count < 25 then
					senderText:setFontSize(23)
				end
			end
			modifyFontSize(_itemW["content"])
			modifyFontSize(_itemW["content2"])

			-- _itemW["btn_set"]:addClickEventListener(
			-- 	function (_sender)
			-- 		cclog("I'm a btn_set")
			-- 	end)
			_itemW["btn_delete"]:addClickEventListener(
				function (_sender)
					cclog("I'm a btn_delete")
					ex_clubHandler:deleteSetting(ClubManager:getClubSecndID(), i)
				end)

		end
	end

	if _data.playRuleNum <= 0 then  --只给添加一个
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(980,100))
		_w["methodList"]:pushBackCustomItem(layout)

		local item = display.newCSNode("club/UI_GameSetting_Item_Template.csb")
		item:addTo(layout)

		local _itemW = self:loadChildrenWidget(item)
		_itemW["itemLayout"]:setVisible(false)
		layout:setTouchEnabled(true)
		layout:addClickEventListener(function() 
		
				local scene = cc.Director:getInstance():getRunningScene()
		        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_RuleSetting")
		        scene:addChild(ui.new({app = nil}))
			end)
	end
end

function UI_GameSetting:onDeleteSetting()
	self:setList()
	ex_clubHandler:gotoGameSetting()
end


function UI_GameSetting:res_onModifyGameSetting(_data)
	cclog("UI_GameSetting:res_onModifyGameSetting")
	if _data.result == 0 then
		--刷新
		self:setMainUI()
	end
end

return UI_GameSetting
