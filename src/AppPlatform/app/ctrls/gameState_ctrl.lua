--@游戏状态类
--@Author 	sunfan
--@date 	2017/04/27
local GameState = class("GameState")

function GameState:ctor(params)
	self._gameApp = params
	self._currState = {state = GAMESTATE.STATE_NO}
	self._nextState = {state = GAMESTATE.STATE_NO}
	timerMgr:register(self)
end

function GameState:update(dt)
	if self._currState.state ~= self._nextState.state then
		cclog("GameState:update >> lock,s1,s2", self._currState.isLock, self._currState.state, self._nextState.state)
		if self._currState.isLock then return end
		self:_handle(self._nextState)
	end
end

function GameState:_handle(s_data)
	if s_data.state == GAMESTATE.STATE_LOGO then		--LOGO状态
		self:_handleLogo(self._currState.state,s_data.state)
	elseif s_data.state == GAMESTATE.STATE_LOGIN then 	--登录状态
		externGameMgr:exitGameByName()
		self:_handleLogin(self._currState.state,s_data.state)
	elseif s_data.state == GAMESTATE.STATE_UPDATE then 	--更新状态
		externGameMgr:exitGameByName()
		self:_handleUpdate(self._currState.state,s_data.state)
	elseif s_data.state == GAMESTATE.STATE_COMMHALL then --大厅状态(综合大厅)
		self:_handleHall(self._currState.state,s_data.state)
	elseif s_data.state == GAMESTATE.STATE_HALL then	--大厅状态(游戏大厅)
		
	elseif s_data.state == GAMESTATE.STATE_ROOM then	--房间状态
		self:_handleRoom(self._currState.state,s_data.state)
	elseif s_data.state == GAMESTATE.STATE_OVER then	--结算状态(总结算)
		self:_handleOver(self._currState.state,s_data.state)
	elseif s_data.state == GAMESTATE.STATE_CLUB then    --俱乐部状态
		self:_handleClub(self._currState.state,s_data.state)
	else 												--无类型状态
		dump(msgMgr:getMsg("MSG_NO_TYPE_STATE")..s_data.state)
	end
	self:_handleCallback(s_data.callback)
	self:_changeState()
	--添加调试模块
	if testMgr then
		testMgr:addTest()
	end
end

--处理进入LOGO状态
function GameState:_handleLogo(c_state,n_state)
	if self._gameApp then
		self._gameApp:enterScene({sceneName = "logoScene_view"})
	end
end

--处理进入登录状态
function GameState:_handleLogin(c_state,n_state)
	if self._gameApp then
		self._gameApp:enterScene({sceneName = "loginScene_view"})
		audioMgr:playMusic("loginMusic.mp3",true)
	end
end

--处理进入更新状态
function GameState:_handleUpdate(c_state,n_state)
	if self._gameApp then
		self._gameApp:enterScene({sceneName = "launcherScene_view"})
	end
end

--处理进入大厅状态
function GameState:_handleHall(c_state,n_state)
	if self._gameApp then
		local sceneName = gameConfMgr:getCurrentHallScene()
		self._gameApp:enterScene({sceneName = sceneName })
		-- viewMgr:show("notice_view")  --进入场景之后立即弹出公告
		audioMgr:playMusic("hallMusic.mp3",true)
		--增加跑马灯
    	marqueeMgr:changeScene()
	end
end

--处理进入房间状态
function GameState:_handleRoom(c_state,n_state)

end

--处理结算状态(总结算)
function GameState:_handleOver(c_state,n_state)

end

--处理进入俱乐部状态
function GameState:_handleClub(c_state,n_state)

end

--处理回调(注意:私有方法，禁止调用)
function GameState:_handleCallback(callback)
	if callback and callback.fun then
		callback.fun(callback.params)
	end
end

--更改状态(注意:私有方法，禁止调用)
function GameState:_changeState()
	-- self._currState = {
	-- state = self._nextState.state,
	-- callback = {fun = self._nextState.callback.fun,params = self._nextState.callback.params}
	-- }

	self._currState = self._nextState
end

--更改状态
function GameState:changeState(state,callback,params, isLock)
	cclog("GameState:changeState >>", self._currState.state, state)
	if not state then
		return
	end
	self._nextState = {state = state,callback = {fun = callback,params = params}, isLock = isLock}
end

--获取状态
function GameState:getState()
	return self._currState.state
end

--查看状态
function GameState:isState(state)
	cclog("GameState:isState >>>", self._currState.state , state)
	return self._currState.state == state, self._currState.isLock
end

-- function GameState:lockState(state)
-- 	if self._currState and self._currState.state == state then
-- 		self._currState.isLock = true
-- 	end
-- end

function GameState:unlockState(state)
	if self._currState and self._currState.state == state then
		self._currState.isLock = false
	end
end

return GameState









