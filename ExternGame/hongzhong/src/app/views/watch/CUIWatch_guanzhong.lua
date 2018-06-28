local CUIWatch_guanzhong = class("CUIWatch_guanzhong",function() 
    return cc.Node:create()
end)

function CUIWatch_guanzhong:ctor(data)
    self.root = display.newCSNode("watch/CUIWatch_guanzhong.csb")
    self.root:addTo(self)
    self.data = data
    CCXNotifyCenter:listen(self,function(obj, key ,data)  self:setPhoto(data) end,"ICONdownloaded")
    
    local btn_info = self.root:getChildByName("btn_info")
    btn_info:setVisible(data.id == PlayerInfo.playerUserID)
    btn_info:addClickEventListener(function()

        local data = {}
        data.name = PlayerInfo.nickname
        data.ip = PlayerInfo.ip
        data.iconName = PlayerInfo.playerUserID.."icon.png"
        data.sex = PlayerInfo.sex
        data.ID = PlayerInfo.playerUserID 
        local pinfo = ex_fileMgr:loadLua("app.views.game.CUIPlayerInfo").new()
        cc.Director:getInstance():getRunningScene():addChild(pinfo)
        pinfo:setGamePlayerInfo(data)
    end)
    
    local file = data.id .. "icon.png"
    local sp = self:getPhotoImg(file)
    
    self.root:getChildByName("bg1"):setVisible(data.id == PlayerInfo.playerUserID)
    self.root:getChildByName("bg2"):setVisible(data.id ~= PlayerInfo.playerUserID)
   
    if sp then
        self:setPhoto(file)
    else
        --self.t = 0
        -- cpp_downloader("DownloadCallBack" , file , data.img) 
        Util.DownloadFile(data.img , file , function()
                cclog("download success >>>")
                self:setPhoto(file)     
            end)
        
    end
      
    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:onExit()
        end
    end)
end

function CUIWatch_guanzhong:getPhotoImg(file)
    local path = ex_fileMgr:getWritablePath().."/".. file
    local headsp =  cc.Sprite:create(path)
    if headsp == nil then
        cc.Director:getInstance():getTextureCache():reloadTexture(path);
        headsp = cc.Sprite:create(path)
        if headsp == nil then
            return nil
        else
            return headsp
        end
    else
        return headsp
    end
end

function CUIWatch_guanzhong:setPhoto(file)
    local tmp_file = self.data.id .. "icon.png"
    cclog("finish **********************")
    if true then--tmp_file == file then
        local path = ex_fileMgr:getWritablePath().."/".. tmp_file
        local headsp =  cc.Sprite:create(path)
        if headsp == nil then
            cc.Director:getInstance():getTextureCache():reloadTexture(path);
            headsp = cc.Sprite:create(path)
            if headsp == nil then
                return 
            end
        end
        --headsp:setAnchorPoint(cc.p(0,0))
        local Tsize = headsp:getContentSize()
        headsp:setScale(51 / Tsize.width ,50 / Tsize.height)
        self.root:addChild(headsp,100)
    end
end

function CUIWatch_guanzhong:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

return CUIWatch_guanzhong