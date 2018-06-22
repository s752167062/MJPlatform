--@场景UI管理器
--@Author 	sunfan
--@date 	2017/04/27
local ViewMgr = class("ViewMgr")

--@UI层级
--特效层2000
--ui层 1000
--操作面板层 500
function ViewMgr:ctor(params)
	--当前游戏APP
	self._appGame = params
	--当前所处场景
	self._scene = nil
	--当前场景所有UI
	self._views = {}
	--UI层
	self._uiLayout = nil
	--特效层
	self._effectLayout = nil
	--操作层
	self._opLayout = nil
end

function ViewMgr:setScene(params)
	self._scene = params
	self:initScene(self._scene)

	-- if eventMgr then
	-- 	eventMgr:dispatchEvent("changeScene",nil)
	-- end
end

function ViewMgr:getScene()
	return self._scene
end

function ViewMgr:initScene(scene)
	self._views = {}
	if scene then
		self._uiLayout = cc.Layer:create()
		scene:addChild(self._uiLayout)
		self._uiLayout:setLocalZOrder(1000)

		self._effectLayout = cc.Layer:create()
		scene:addChild(self._effectLayout)
		self._effectLayout:setLocalZOrder(2000)

		self._opLayout = cc.Layer:create()
		scene:addChild(self._opLayout)
		self._opLayout:setLocalZOrder(500)
	else
		self._uiLayout = nil
		self._effectLayout = nil
		self._opLayout = nil
	end
end

--[[
    local tb = {}
    
    local x = {xxx, n = self.ctn_start}

    cclog(" =====  =   == = = = == = ")
    cclog(tolua.isnull(tb), type(tb))  --- true table
    cclog(tolua.isnull(x), type(x))  --- true table
    cclog(tolua.isnull(self.ctn_start), type(self.ctn_start))  --- false userdata
    cclog(" =====  =   == = = = == = ")
]]

function ViewMgr:checkIsNull(obj)
	

	if obj then
		if type(obj) ~= "userdata" then
			cclog("Warnning :  ViewMgr:checkIsNull >> this obj not userdata")
			return false
		else
			local bool = tolua.isnull(obj)
			cclog(" ViewMgr:checkIsNull >> ", bool)
			return bool
		end
	else
		return true
	end
end

function ViewMgr:sceneCheck()
	local scene = self:getScene()
	if self:checkIsNull(scene) then
		scene = cc.Director:getInstance():getRunningScene()
		self:setScene(scene)
	end
end

function ViewMgr:show(name,level,rootview)
	cclog("ViewMgr:show name = ",name, gameState:isState(GAMESTATE.STATE_UPDATE))
	

	-- cclog(debug.traceback())
	self:sceneCheck()

	if self._uiLayout and self._scene and self._appGame then
		local view = self._appGame:createView(name,rootview)
		
		local isState, isLock = gameState:isState(GAMESTATE.STATE_UPDATE)
		if isState and isLock then  -- 不要打扰更新
			return view
		end

		if level then
			view:setLocalZOrder(level)
		end
		if not self._views[name] then
			self._views[name] = {}
		end
		self._views[name][#self._views[name] + 1] = view

		if not tolua.isnull(self._uiLayout) then
			self._uiLayout:addChild(view)
		end
		return view
	end
	return nil
end

function ViewMgr:showUI(name, view, level)
	-- body
	print("ViewMgr:showUI name = ",name)
	self:sceneCheck()

	if self._uiLayout and self._scene and self._appGame then
		local view = view
		if level then
			view:setLocalZOrder(level)
		end
		if not self._views[name] then
			self._views[name] = {}
		end
		self._views[name][#self._views[name] + 1] = view
		self._uiLayout:addChild(view)
		return view
	end
	return nil
end


function ViewMgr:closeWithObject(name,obj)
	if self:checkIsNull(self._uiLayout) then return end

	if self._views[name] then
		local temp = {}
		for loop = 1,#self._views[name] do
			if self._views[name][loop]  then
				if self._views[name][loop] == obj then
					print("ViewMgr:closeWithObject name=",name)
					self._uiLayout:removeChild(self._views[name][loop])
				else
					temp[#temp + 1] = self._views[name][loop]
				end
			end
		end
		if #temp >= 1 then
			self._views[name] = temp
		else
			self._views[name] = nil
		end
	end
end

--@判断哪个标记为target的界面是否打开
function ViewMgr:isShow(name)
	if self._views[name] and #self._views[name] > 0 then
		return self._views[name][#self._views[name]]
	end
	return nil
end

function ViewMgr:close(name)
	cclog("ViewMgr:close >>>", self:checkIsNull(self._uiLayout))
	if self:checkIsNull(self._uiLayout) then return end

	if self._views[name] then
		for loop = 1,#self._views[name] do
			if self._views[name][loop] then
				self._uiLayout:removeChild(self._views[name][loop])
			end
		end
		self._views[name] = nil
	end
end

function ViewMgr:addEffect(effect)
	self:sceneCheck()

	if self._effectLayout and self._scene and self._appGame then
		self._effectLayout:addChild(effect)
		return true
	end
	return false
end

function ViewMgr:removeEffect(effect)
	if self:checkIsNull(self._effectLayout) then return end
	self._effectLayout:removeChild(effect)
end

function ViewMgr:addOpView(view)
	self:sceneCheck()

	if self._opLayout and self._scene and self._appGame then
		self._opLayout:addChild(view)
		return true
	end
	return false
end

function ViewMgr:removeOpView(view)
	if self:checkIsNull(self._opLayout) then return end
	self._opLayout:removeChild(view)
end

--@获取当前场景model
function ViewMgr:getCurModel()
    local scene = viewMgr:getScene()
    local model = scene:getModel()
    return model
end

--@获取当前场景ctrl
function ViewMgr:getCurCtrl()
    local scene = viewMgr:getScene()
    local ctrl = scene:getCtrl()
    return ctrl
end

return ViewMgr
