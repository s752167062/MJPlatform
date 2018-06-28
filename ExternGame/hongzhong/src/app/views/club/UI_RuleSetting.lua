

local UI_RuleSetting = class("UI_RuleSetting", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_RuleSetting:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_RuleSetting.csb")
    self.root:addTo(self)

	UI_RuleSetting.super.ctor(self)
	_w = self._childW
	
  	self._rule = {}
  	self._rule.playerNum = {3, 4}
  	self._rule.ju = {8, 16}
  	self._rule.PLAY_7D = false
	self._rule.PLAY_LEILUO = false
	self._rule.canWatch = false
	self._rule.za = {1, 2, 3, 4, 6}

	self:setMainUI()

end

function UI_RuleSetting:update(t)
    
end

function UI_RuleSetting:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
		self:closeUI()
	elseif name == "btn_submit" then
		self:submitPlayRule()
	end
end

function UI_RuleSetting:onTouch(_sender, _type)
	local name = _sender:getName()		
	if _type == 2 or _type == 3 then
		cclog("name:"..name)
		--========== 人数 =============	
		if name == "CheckBox_1_1" then
			self:setMenu_1(1, _w[name]:isSelected())
		elseif name == "CheckBox_1_2" then
			self:setMenu_1(2, _w[name]:isSelected())
		--========== 局数 =============	
		elseif name == "CheckBox_2_1" then
			self:setMenu_2(1, _w[name]:isSelected())
		elseif name == "CheckBox_2_2" then
			self:setMenu_2(2, _w[name]:isSelected())
		--========== 玩法 =============	
		elseif name == "CheckBox_3_1" then
			self:setMenu_3(1, _w[name]:isSelected())
		elseif name == "CheckBox_3_2" then
			self:setMenu_3(2, _w[name]:isSelected())
		elseif name == "CheckBox_3_3" then
			self:setMenu_3(3, _w[name]:isSelected())
		elseif name == "CheckBox_3_4" then		--8个红中
			self:setMenu_3(4, _w[name]:isSelected())
		elseif name == "CheckBox_3_5" then		--可点炮
			self:setMenu_3(5, _w[name]:isSelected())
		--========== 扎码 =============	
		elseif name == "CheckBox_4_1" then	--一码全中
			self:setMenu_4(1, _w[name]:isSelected())
		elseif name == "CheckBox_4_6" then	--新一码全中
			self:setMenu_4(6, _w[name]:isSelected())
		elseif name == "CheckBox_4_2" then	--2个码
			self:setMenu_4(2, _w[name]:isSelected())
		elseif name == "CheckBox_4_3" then	--3个码
			self:setMenu_4(3, _w[name]:isSelected())
		elseif name == "CheckBox_4_4" then	--4个码
			self:setMenu_4(4, _w[name]:isSelected())
		elseif name == "CheckBox_4_5" then	--6个码
			self:setMenu_4(5, _w[name]:isSelected())
		elseif name == "btn_gps" then 
			self:setGpsBtn()
		end
	end
end

--主设置
function UI_RuleSetting:setMainUI()
	--========== 人数 =============	
	_w["CheckBox_1_1"]:setSelectedState(true)
	_w["CheckBox_1_2"]:setSelectedState(false)
	
	--========== 局数 =============	
	_w["CheckBox_2_1"]:setSelectedState(true)
	_w["CheckBox_2_2"]:setSelectedState(false)
	
	--========== 玩法 =============	
	_w["CheckBox_3_1"]:setSelectedState(false)
	_w["CheckBox_3_2"]:setSelectedState(true)
	_w["CheckBox_3_3"]:setSelectedState(false)
	_w["CheckBox_3_4"]:setSelectedState(false)
	_w["CheckBox_3_5"]:setSelectedState(false)
	
	--========== 扎码 =============	
	_w["CheckBox_4_1"]:setSelectedState(true)
	
	_w["CheckBox_4_2"]:setSelectedState(false)
	_w["CheckBox_4_3"]:setSelectedState(false)
	_w["CheckBox_4_4"]:setSelectedState(false)
	_w["CheckBox_4_5"]:setSelectedState(false)
	_w["CheckBox_4_6"]:setSelectedState(false)
	
	--防作弊
	_w["btn_gps"]:setBright(false)
end

--设置选项间的互斥关系
function UI_RuleSetting:setMenu_1(_index, _flag)
	cclog("_index:".._index.."  _flag:"..tostring(_flag))
	if _flag == true then
		_w["CheckBox_1_1"]:setSelectedState(_index == 1)
		_w["CheckBox_1_2"]:setSelectedState(_index == 2)
	end
end
function UI_RuleSetting:getMenu_1()
	for i = 1, 2 do
		if _w["CheckBox_1_"..i]:isSelected() == true then
			return i
		end
	end
	return 1
end

function UI_RuleSetting:setMenu_2(_index, _flag)
	cclog("_index:".._index.."  _flag:"..tostring(_flag))
	-- if _flag == true then
	-- 	_w["CheckBox_2_1"]:setSelectedState(_index == 1)
	-- 	_w["CheckBox_2_2"]:setSelectedState(_index == 2)
	-- end

	if 	_index == 1 then
		if not _flag and not _w["CheckBox_2_2"]:isSelected() then
			_w["CheckBox_2_1"]:setSelectedState(true)
		end

	elseif _index == 2 then
		if not _flag and not _w["CheckBox_2_1"]:isSelected() then
			_w["CheckBox_2_2"]:setSelectedState(true)
		end
	end
end
function UI_RuleSetting:getMenu_2()
	-- for i = 1, 2 do
	-- 	if _w["CheckBox_2_"..i]:isSelected() == true then
	-- 		return i
	-- 	end
	-- end
	-- return 1

	if _w["CheckBox_2_1"]:isSelected() and _w["CheckBox_2_2"]:isSelected() then
		return 0
	else
		for i = 1, 2 do
			if _w["CheckBox_2_"..i]:isSelected() == true then
				return i
			end
		end
		return 1
	end
end

function UI_RuleSetting:setMenu_3(_index, _flag)
	cclog("_index:".._index.."  _flag:"..tostring(_flag))
	if _index == 1 or _index == 4 or _index == 5 then
		local func = {}
		func[1] = function (flag)
    		cclog("1")
        	_w["CheckBox_3_1"]:setSelectedState(flag)
    	end
    	func[4] = function (flag)
    		cclog("4")
        	_w["CheckBox_3_4"]:setSelectedState(flag)
    	end

   	 	func[5] = function (flag)
   	 		cclog("5")
        	_w["CheckBox_3_5"]:setSelectedState(flag)
    	end

    	for i, v in pairs(func) do
	        if i ~= _index and _flag == true then
	            func[i](false)
	        end
	    end
    end 
--	if _flag == true then
--		_w["CheckBox_3_1"]:setSelectedState(_index == 1)
--		_w["CheckBox_3_2"]:setSelectedState(_index == 2)
--	end
end
function UI_RuleSetting:getMenu_3()
	for i = 1, 2 do
		if _w["CheckBox_3_"..i]:isSelected() == true then
			return i
		end
	end
end

function UI_RuleSetting:setMenu_4(_index, _flag)
	cclog("_index:".._index.."  _flag:"..tostring(_flag))
	if _flag == true then
		_w["CheckBox_4_1"]:setSelectedState(_index == 1)
		_w["CheckBox_4_2"]:setSelectedState(_index == 2)
		_w["CheckBox_4_3"]:setSelectedState(_index == 3)
		_w["CheckBox_4_4"]:setSelectedState(_index == 4)
		_w["CheckBox_4_5"]:setSelectedState(_index == 5)
		_w["CheckBox_4_6"]:setSelectedState(_index == 6)
	end
end
function UI_RuleSetting:getMenu_4()
	for i = 1, 5 do
		if _w["CheckBox_4_"..i]:isSelected() == true then
			return i
		end
	end
	return 0
end

function UI_RuleSetting:setGpsBtn()
	local isB = not _w["btn_gps"]:isBright()
    local msg = "gps防作弊功能"
    msg = isB and msg .. "已开启" or msg .. "已关闭"
    GlobalFun:showToast(msg,Game_conf.TOAST_SHORT)
	_w["btn_gps"]:setBright(isB)
end

--确定提交玩法
function UI_RuleSetting:submitPlayRule()
	local data = {}
	data.model = 3
	local tb = {}

	local value_1 = self:getMenu_1()
	local value_2 = self:getMenu_2()
	local value_3_1 = _w["CheckBox_3_1"]:isSelected()
	local value_3_2 = _w["CheckBox_3_2"]:isSelected()
	local value_3_3 = _w["CheckBox_3_3"]:isSelected()
	local value_3_4 = _w["CheckBox_3_4"]:isSelected()
	local value_3_5 = _w["CheckBox_3_5"]:isSelected()
	local isGPS = _w["btn_gps"]:isBright()
	local value_4 = self:getMenu_4()

	if value_1 == nil or value_2 == nil or value_4 == nil then

	end

	tb.playerNum = self._rule.playerNum[value_1]
	tb.ju = self._rule.ju[value_2] or 0  --为0 玩家点桌子时自己选局数，否则按规则来
	tb.PLAY_LEILUO = value_3_1
	tb.PLAY_7D = value_3_2
	tb.za = value_4 > 0 and self._rule.za[value_4] or 0
	tb.canWatch = value_3_3
	tb.gameType = ClubManager:getGameTypeForServer()
	tb.PLAY_EIGHT = value_3_4 	--8个红中
	tb.PLAY_CONNON = value_3_5	--可点炮
	tb.PLAY_AK_ONE_ALL = _w["CheckBox_4_6"]:isSelected()	--安康一码全中
	tb.isGPS = isGPS
	
	data.valueJson = json.encode(tb)
	data.operationCode = 0

	print_r(data)

	ex_clubHandler:gotoModifyGameSetting(data)
	self:closeUI()
end

return UI_RuleSetting
