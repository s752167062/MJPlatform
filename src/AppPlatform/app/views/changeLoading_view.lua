-- local ChangeLoadingView = class("ChangeLoadingView",cc.load("mvc").ViewBase)



-- ChangeLoadingView.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/ChangeLoadingView.csb"

-- function ChangeLoadingView:onCreate()
-- 	self.serverId = gameNetMgr:getServerId()
-- 	gameState:changeState(GAMESTATE.STATE_LOADING)
-- end

-- function ChangeLoadingView:onEnter()
-- 	self.LoadingBar_2 = self:findChildByName("LoadingBar_2")
--   	self.LoadingBar_2:setPercent(0)

--   	self.timeCount = 0
--   	self.totalTime = 2
--   	self:onUpdate(function(dt) 
--   		-- cclog("ChangeLoadingView>>>>>",self.timeCount) 
--   		self.timeCount = self.timeCount +dt
--   		if self.timeCount >=self.totalTime then
--   			self.LoadingBar_2:setPercent(80)
--   		else
--   			local v = self.timeCount*80/self.totalTime
--   			self.LoadingBar_2:setPercent(v)
--   		end
--   	end)


	

--   	eventMgr:registerEventListener("changeLoading_view--finish",function(data) 

--   			cclog("ChangeLoadingView >>!", data.gotoGame, self.serverId , gameNetMgr:getServerId())
--   			if data.gotoGame or self.serverId ~= gameNetMgr:getServerId() then
--   				cclog("ChangeLoadingView >>222")
-- 	  			self.LoadingBar_2:setPercent(100) 
-- 	  			self:onUpdate(function() end)
-- 	  		end
--   		end, self)
--     marqueeMgr:clear()
-- end

-- function ChangeLoadingView:onExit()
-- 	self:unregisterScriptHandler()
--     eventMgr:removeEventListenerForTarget(self)
-- end









return ChangeLoadingView