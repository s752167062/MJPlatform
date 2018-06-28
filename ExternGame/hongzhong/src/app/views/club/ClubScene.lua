
-- ex_fileMgr:loadLua("requireList")
ex_fileMgr:loadLua("app/views/club/ClubGlobalFun")

--PATH_CLUB_CSB = "club/"

local ClubScene = class("ClubScene", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

ClubScene.RESOURCE_FILENAME = "club/UI_ClubScene.csb"


function ClubScene:onCreate()

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        elseif state == "enterTransitionFinish" then
        --self:onEnterTransitionFinish_()
        elseif state == "exitTransitionStart" then
        --self:onExitTransitionStart_()
        elseif state == "cleanup" then
        --self:onCleanup_()
        end
    end)
    GlobalData.curScene = SceneType_Club
    cpp_log("GlobalData.curScene=" .. GlobalData.curScene)
	
	self.interl = 0


    self.root = self:getResourceNode()
    local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubMain")
    self.root:addChild(ui.new({app = self:getApp()}))
	
end

function ClubScene:onEnter()
    cpp_log("1111")
    
    self.root = self:getResourceNode()
    GlobalData.curScene = SceneType_Club

    -- ex_timerMgr:register(self)  -- 唤起update
    -- CCXNotifyCenter:listen(self,function() self.hT = 0  end,"onClubHeart")      --心跳相关
    -- CCXNotifyCenter:listen(self,function() self.hT = -1 end,"onClubTryConnect")     --心跳相关

    CCXNotifyCenter:listen(self,function(obj,key,data) self:onClubGotoHall(data)  end,"onClubGotoHall") --请求去大厅
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onClubGotoRoom(data)  end,"AcceptRoom") --请求去房间

    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetClub()  end,"resetClub") --请求去房间

	--跳转大厅
	-- local btn_close = self.root:getChildByName("bg"):getChildByName("btn_close")
	-- btn_close:addClickEventListener(function() 
 --            -- self:getApp():enterScene("LobbyScene") 
 --            cclog("ClubScene:onEnter >>> btn_close")
 --            self:reqClubGotoHall()
 --            -- ex_clubHandler:gotoRoom(858094)  --因为没有其他按钮，我在这里测试进入房间
 --        end)
	
	ex_audioMgr:playMusic("sound/bgmlogin.mp3",true)
end

function ClubScene:onClubGotoRoom()
    -- self:getApp():enterScene("game/CUIGame") 
    ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_ROOM)
end

--请求服务器获取去大厅的网络连接数据
function ClubScene:reqClubGotoHall()
    ex_clubHandler:reqClubGotoHall()
end

--去大厅的网络连接数据返回
function ClubScene:onClubGotoHall(res)
    CCXNotifyCenter:listen(self,function(obj,key,data) ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_HALL)  end,"gotoHall")  --监听去大厅
end






-- function ClubScene:update(t)
--     self.interl = self.interl + t

   
-- end

function ClubScene:resetClub()
    local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubMain")
    self.root:addChild(ui.new({app = self:getApp()}))
end

function ClubScene:onStart()
      
end

function ClubScene:onExit()
    CCXNotifyCenter:unListenByObj(self)
    self:unregisterScriptHandler()--取消自身监听
    ex_timerMgr:unRegister(self)
    cclog("清理工作")

    cc.AnimationCache:destroyInstance()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

return ClubScene
