local ChangeLoadingSceneView = class("ChangeLoadingSceneView",cc.load("mvc").ViewBase)



ChangeLoadingSceneView.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/ChangeLoadingScene.csb"

function ChangeLoadingSceneView:onCreate()
	self.serverId = gameNetMgr:getServerId()
end

function ChangeLoadingSceneView:onEnter()
    cclog("ChangeLoadingSceneView:onEnter >>>")
    self.LoadingBar_2 = self:findChildByName("LoadingBar_2")
  	self.LoadingBar_2:setPercent(0)

  	self.timeCount = 0
  	self.totalTime = 2
  	self:onUpdate(function(dt) 
  		-- cclog("ChangeLoadingSceneView>>>>>",self.timeCount) 
  		self.timeCount = self.timeCount +dt
  		if self.timeCount >=self.totalTime then
  			self.LoadingBar_2:setPercent(80)
  		else
  			local v = self.timeCount*80/self.totalTime
  			self.LoadingBar_2:setPercent(v)
  		end
  	end)


	

  	eventMgr:registerEventListener("changeLoading_view--finish",function(data) 

  			cclog("ChangeLoadingSceneView >>!", data.gotoGame, self.serverId , gameNetMgr:getServerId())
  			if data.gotoGame or self.serverId ~= gameNetMgr:getServerId() then
  				cclog("ChangeLoadingSceneView >>222")
	  			self.LoadingBar_2:setPercent(100) 
	  			self:onUpdate(function() end)
	  		end
  		end, self)


    self:doEnterData()



    marqueeMgr:clear()
end

function ChangeLoadingSceneView:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end


function ChangeLoadingSceneView:setEnterData(params, cb)
    self.enterParams = params
    self.enterCB = cb

end

function ChangeLoadingSceneView:doEnterData()
    externGameMgr:exitGameByName()

    cclog("ChangeLoadingSceneView:doEnterData >>>")

    if self.enterParams and self.enterCB then
      cclog("self.enterParams.gameName >>", self.enterParams.gameName)
      externGameMgr:enterGameByName(self.enterParams.gameName, self.enterCB)
    end
end






return ChangeLoadingSceneView






