local CUIGame_playerInfo = class("CUIGame_playerInfo",function() 
    return cc.Node:create()
end)

CUIGame_playerInfo.UTYPE_1 = "CUIPlayer"   -- CUIPlayer调用的
CUIGame_playerInfo.UTYPE_2 = "CUIGame_Require"   -- CUIGame_Require

local PlayerIPTips = import(".PlayerIPTips")

function CUIGame_playerInfo:ctor(scene, utype)
    self.root = display.newCSNode("game/CUIGame_playerinfo.csb")
    self.root:addTo(self)
    self.scale = 0.5
    self.scene = scene
    self.utype = utype
    self.txt_offline = self.root:getChildByName("txt_offline")


    self.liwu_1 = self.root:getChildByName("liwu_1")
    self.liwu_2 = self.root:getChildByName("liwu_2")
    self.liwu_4 = self.root:getChildByName("liwu_4")
    self.liwu_x = self.root:getChildByName("liwu_x")
    self.liwu_1:addClickEventListener(function () self:onLiWu(1) end)
    self.liwu_2:addClickEventListener(function () self:onLiWu(2) end)
    self.liwu_4:addClickEventListener(function () self:onLiWu(4) end)
    self.liwu_x:addClickEventListener(function () self:onLiWu() end)
    
    self:setScale(self.scale)
    
    self:setZhuangVisible(false)
    
    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end)
    
end

function CUIGame_playerInfo:onEnter()
    local btn_icon = self.root:getChildByName("icon_bg")
    btn_icon:addClickEventListener(function() self:showPlayerinfo() end)
    
    CCXNotifyCenter:listen(self,function(obj, key ,data)  self:setPlayerPhoto(data) end,"ICONdownloaded")
end

function CUIGame_playerInfo:onExit()
    self:unregisterScriptHandler()
    CCXNotifyCenter:unListenByObj(self)

    CCXNotifyCenter:notify("clean_WatchGifArea", {playerid = self.player.id})
end

function CUIGame_playerInfo:showPlayerinfo()
    local pinfo = ex_fileMgr:loadLua("app.views.game.CUIPlayerInfo").new()
    cc.Director:getInstance():getRunningScene():addChild(pinfo)
    if self.player ~= nil then
        local data = {}
        data.name = self.player.name 
        data.ip = self.player.ipAddr
        data.iconName = self.player.id.."icon.png"
        data.sex = self.player.sex
        data.ID = self.player.id  
        data.scene = self.scene
        pinfo:setGamePlayerInfo(data)
    end
end

function CUIGame_playerInfo:setPlayerName(name)
    self.root:getChildByName("txt_name"):setString(name)
end

function CUIGame_playerInfo:setZhuangVisible(b)
    self.root:getChildByName("img_zhuang"):setVisible(b)
end

function CUIGame_playerInfo:setPlayerScore(score)
    self.root:getChildByName("txt_score"):setString(score)
end

function CUIGame_playerInfo:getWidthAndHeight()
    local cs = self.root:getChildByName("img_bg"):getContentSize()
    
    return cs.width*self.scale,(cs.height+ 10 )*self.scale
end

function CUIGame_playerInfo:setHolder(pos,showP,flag,isMatch,playerid)
    
    local img_holder = self.root:getChildByName("img_holder")
    -- local p = {x=0,y=0}
    -- if showP == 1 then
    --     p.x = -52.51
    --     p.y = 154.76
    -- elseif showP == 2 then
    --     p.x = 147.49
    --     p.y = 40
    -- elseif showP == 3 then
    --     p.x = 147.49
    --     p.y = 40
    -- else
    --     p.x = -142.51
    --     p.y = 38.76
    -- end
    
    if flag == 0 then
        img_holder:setVisible(GlobalData.roomCreateID == playerid and (isMatch == nil or isMatch == false) )
        return
    end
    if pos ~= 1 then
        img_holder:setVisible(GlobalData.roomCreateID == playerid and (isMatch == nil or isMatch == false) )
    else
        cclog("#### ", playerid)
        cclog("#### ",GlobalData.roomCreateID)
        img_holder:setVisible(GlobalData.roomCreateID == playerid and (isMatch == nil or isMatch == false) )
        -- img_holder:setPosition(p)
    end
end

function CUIGame_playerInfo:setBaseData(data)
    self.player = data
    local filename = self.player.id.."icon.png"
    local url = self.player.iconURL
    if ex_fileMgr:getWritablePath().."/".. filename then
        self:setBaseGameData(data)
        --return
    end
    if url ~= nil and url ~= "" then -- and not ex_fileMgr:getWritablePath().."/".. filename 
        cclog("icon url "..url )
        if self.player.id ~= PlayerInfo.playerUserID then
            -- cpp_downloader("DownloadCallBack" , filename , url)  
            Util.DownloadFile(url , filename , function()
                cclog("download success >>>")
                self:setPlayerPhoto(filename)     
            end)
        else
            self:setPlayerPhoto(PlayerInfo.imghead)  	
        end
    end 
end

function CUIGame_playerInfo:setBaseGameData(data)
    self.player = data
    local filename = self.player.id.."icon.png"
    self:setPlayerPhoto(filename)
    self:showLiWuBtn()
end


function CUIGame_playerInfo:setPlayerPhoto(file)
    local filename = self.player.id.."icon.png"
    if self.player.id == PlayerInfo.playerUserID then
        filename = PlayerInfo.imghead
    end 

    if file == filename then
        local ctn_head = self.root:getChildByName("icon_bg")
        local path = ex_fileMgr:getWritablePath().."/".. filename
        if self.player.id == PlayerInfo.playerUserID then 
            path = platformExportMgr:doGameConfMgr_getInfo("headIconPath")--
        end    

        local headsp =  cc.Sprite:create(path)
        if headsp == nil then
            cc.Director:getInstance():getTextureCache():reloadTexture(path);
            headsp = cc.Sprite:create(path)
            if headsp == nil then
            	return 
            end
        end

        -- headsp:setAnchorPoint(cc.p(0,0))
        -- local Basesize = ctn_head:getContentSize()
        -- local Tsize = headsp:getContentSize()
        -- headsp:setScale(Basesize.width / Tsize.width ,Basesize.height / Tsize.height)
        -- ctn_head:setPosition(1,1)

        GlobalFun:modifyAddNewIcon(ctn_head, headsp, 20, 20, "baseicon")

        ctn_head:setTag(100)
        ctn_head:addChild(headsp)
    end
end

function CUIGame_playerInfo:prePotoh(data)
	self.root:getChildByName("img_game_ok"):setVisible(data.isReady)
	self:setPlayerName(data.name)
	self:setPlayerScore("")
end

function CUIGame_playerInfo:smallSummaryPhoto()
    self.root:getChildByName("img_bg"):setVisible(false)
    self:setPlayerScore("")
end

function CUIGame_playerInfo:setOnAndOff(b)
    local ctn_head = self.root:getChildByName("icon_bg")
    local head = ctn_head:getChildByTag(100)
    if b then
        self.root:getChildByName("txt_name"):setColor(cc.c3b(255,255,255))
        if head then
            head:setColor(cc.c3b(255,255,255))
        end
    else
        self.root:getChildByName("txt_name"):setColor(cc.c3b(0,0,0))
        if head then
            head:setColor(cc.c3b(125,125,125))
        end
    end
	
end


function CUIGame_playerInfo:showLiWuBtn()


    if not self.player then return end
    if self.player.id == PlayerInfo.playerUserID then return end


    local sc = self:getScale()
    local tmp = 1/sc
    self.liwu_1:setScale(tmp*0.8)
    self.liwu_2:setScale(tmp*0.8)
    self.liwu_4:setScale(tmp*0.8)
    self.liwu_x:setScale(tmp*0.8)

    if CUIGame_playerInfo.UTYPE_1 == self.utype then
        -- cclog("showLiWuBtn >>>", self.player.pos)
        self.liwu_1:setVisible(self.player.pos == 1)
        self.liwu_2:setVisible(self.player.pos == 2 or self.player.pos == 3)
        self.liwu_4:setVisible(self.player.pos == 4)

    elseif CUIGame_playerInfo.UTYPE_2 == self.utype then

        self.liwu_x:setVisible(true)
    end

end

function CUIGame_playerInfo:onLiWu(pos)
    cclog("onliwu")

    local x,y = self.root:getPosition()
    local w_xy = self.root:convertToWorldSpace(cc.p(x,y))
    local data = {playerid = self.player.id, pos = pos, w_xy = w_xy, giflist = self.scene:getGifList()}

    CCXNotifyCenter:notify("showGifList", data)
end

function CUIGame_playerInfo:showIPTips(player,showp,isVideo)
    -- if isVideo then return end
    -- if Game_conf.server_type == 1 then return end
    -- if GlobalData.notIP then return end
    -- PlayerIPTips:playerIn({id = player.id,name = player.name ,ip = player.ipAddr},showp,self.scene)
end 

function CUIGame_playerInfo:showFangZhu(isShow)
    
    local img_holder = self.root:getChildByName("img_holder")
    img_holder:setVisible(isShow)
end

function CUIGame_playerInfo:setNameColor(color)
    local txt_name = self.root:getChildByName("txt_name")
    txt_name:setColor(color)

end


return CUIGame_playerInfo
