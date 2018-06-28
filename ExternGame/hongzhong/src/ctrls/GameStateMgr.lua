--@游戏状态类
--@Author 	sunfan
--@date 	2017/04/27
local GameStateMgr = class("GameStateMgr")

--游戏状态机状态类型
GameStateMgr.GAMESTATE = {
    STATE_NO                = 0,--无状态
    STATE_LOGO              = 1,--LOGO状态
    STATE_LOGIN             = 2,--登录状态
    STATE_UPDATE            = 3,--更新状态
    STATE_COMMHALL          = 4,--大厅状态(综合大厅)
    STATE_HALL              = 5,--大厅(游戏大厅)
    STATE_ROOM              = 6,--房间状态
    STATE_OVER              = 7,--结算状态(总结算)
    STATE_CLUB              = 8,--俱乐部状态
}

function GameStateMgr:ctor(params)
	self._gameApp = params
	self._currState = {state = GameStateMgr.GAMESTATE.STATE_NO}
	self._nextState = {state = GameStateMgr.GAMESTATE.STATE_NO}
	ex_timerMgr:register(self)
end

function GameStateMgr:update(dt)
	if self._currState.state ~= self._nextState.state then
		self:_handle(self._nextState)
	end
end

function GameStateMgr:_handle(s_data)
	print_r(s_data,"GameStateMgr _handle = ")

	if s_data.state == GameStateMgr.GAMESTATE.STATE_LOGO then		--LOGO状态
		self:_handleLogo(self._currState.state,s_data.state)
	elseif s_data.state == GameStateMgr.GAMESTATE.STATE_LOGIN then 	--登录状态
		self:_handleLogin(self._currState.state,s_data.state)
	elseif s_data.state == GameStateMgr.GAMESTATE.STATE_UPDATE then 	--更新状态
		self:_handleUpdate(self._currState.state,s_data.state)
	elseif s_data.state == GameStateMgr.GAMESTATE.STATE_COMMHALL then --大厅状态(综合大厅)
		self:_handleCommHall(self._currState.state,s_data.state)
	elseif s_data.state == GameStateMgr.GAMESTATE.STATE_HALL then	--大厅状态(游戏大厅)
		self:_handleHall(self._currState.state,s_data.state)
	elseif s_data.state == GameStateMgr.GAMESTATE.STATE_ROOM then	--房间状态
		self:_handleRoom(self._currState.state,s_data.state)
	elseif s_data.state == GameStateMgr.GAMESTATE.STATE_OVER then	--结算状态(总结算)
		self:_handleOver(self._currState.state,s_data.state)
	elseif s_data.state == GameStateMgr.GAMESTATE.STATE_CLUB then    --俱乐部状态
		self:_handleClub(self._currState.state,s_data.state)
	else 												--无类型状态
		dump(msgMgr:getMsg("MSG_NO_TYPE_STATE")..s_data.state)
	end
	self:_handleCallback(s_data.callback)
	self:_changeState()
end

--处理进入LOGO状态
function GameStateMgr:_handleLogo(c_state,n_state)
	-- if self._gameApp then
	-- 	self._gameApp:enterScene({sceneName = "logoScene_view"})
	-- end
end

--处理进入登录状态
function GameStateMgr:_handleLogin(c_state,n_state)
	-- if self._gameApp then
	-- 	self._gameApp:enterScene({sceneName = "loginScene_view"})
	-- 	ex_audioMgr:playMusic("loginMusic.mp3",true)
	-- end
end

--处理进入更新状态
function GameStateMgr:_handleUpdate(c_state,n_state)
	-- if self._gameApp then
	-- 	self._gameApp:enterScene({sceneName = "launcherScene_view"})
	-- end
end

--处理进入大厅状态
function GameStateMgr:_handleCommHall(c_state,n_state)
	-- if self._gameApp then
	-- 	local sceneName = gameConfMgr:getCurrentHallScene()
	-- 	self._gameApp:enterScene({sceneName = sceneName })
	-- 	-- viewMgr:show("notice_view")  --进入场景之后立即弹出公告
	-- 	ex_audioMgr:playMusic("hallMusic.mp3",true)
	-- 	--增加跑马灯
 --    	marqueeMgr:changeScene()
	-- end
end

--处理进入大厅状态
function GameStateMgr:_handleHall(c_state,n_state)
	if self._gameApp then
		self._gameApp:enterScene("LobbyScene")
		ex_audioMgr:playMusic("sound/bgm.mp3",true)
	end
end

--处理进入房间状态
function GameStateMgr:_handleRoom(c_state,n_state)
	if self._gameApp then
		self._gameApp:enterScene("game/CUIGame")
		ex_audioMgr:playMusic("sound/bgm.mp3",true)
	end
end

--处理结算状态(总结算)
function GameStateMgr:_handleOver(c_state,n_state)

end

--处理进入俱乐部状态
function GameStateMgr:_handleClub(c_state,n_state)
	cclog("GameStateMgr:_handleClub >>>> 111")
	if self._gameApp then
		cclog("GameStateMgr:_handleClub >>>>")
		self._gameApp:enterScene("club/ClubScene")
		ex_audioMgr:playMusic("sound/bgm.mp3",true)
	end
end

--处理回调(注意:私有方法，禁止调用)
function GameStateMgr:_handleCallback(callback)
	if callback and callback.fun then
		callback.fun(callback.params)
	end
end

--更改状态(注意:私有方法，禁止调用)
function GameStateMgr:_changeState()
	self._currState = {
	state = self._nextState.state,
	callback = {fun = self._nextState.callback.fun,params = self._nextState.callback.params}
	}
end

--更改状态
function GameStateMgr:changeState(state,callback,params)
	cclog("state = "..state, self._currState.state)
	-- cclog(debug.traceback())
	if not state then
		return
	end
	self._nextState = {state = state,callback = {fun = callback,params = params}}
end

--获取状态
function GameStateMgr:getState()
	return self._currState.state
end

--查看状态
function GameStateMgr:isState(state)
	return self._currState.state == state
end

return GameStateMgr
