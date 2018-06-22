local md5 = require "Manager.md5"

-- local GameItem = class("GameItem", function() 
--    return cc.Node:create()
-- end)

local DownloadImageNode = require("app.common.DownloadImageNode")
local GameItem = class("GameItem", DownloadImageNode)



function GameItem:ctor()
    self.super.ctor(self)
    self:enableNodeEvents()
    self:DownloadImageNode_setDownloadDir(externGameMgr:getGameIconDir())

	self.root = display.newCSNode(__platformHomeDir .."ui/layout/GameListView/GameItem.csb")
	self.root:addTo(self)

	self.bg = self.root:getChildByName("bg")
	self.txt_name = self.bg:getChildByName("txt_name")

    self.bg_icon = self.bg:getChildByName("bg_icon")

	self.icon = self.bg_icon:getChildByName("icon_game")
	self.stat_down = self.bg_icon:getChildByName("stat_down")

	self.stat_del = self.bg_icon:getChildByName("stat_del")


    self.stat_hot = self.bg_icon:getChildByName("stat_hot")

    self.stat_update = self.bg_icon:getChildByName("stat_update")

    self.stat_tuijian = self.bg_icon:getChildByName("stat_tuijian")

    self:setState(0, 0)


    -- self.url = ""
end

function GameItem:onEnter()
    cclog("GameItem:onEnter >>>")
end

function GameItem:onExit()
    cclog("GameItem:onExit  >>>>")
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end


function GameItem:setClickFunc(func)
    -- body
    self.bg:addClickEventListener(func)
end

function GameItem:setName(name)
	self.txt_name:setString(name)
end

function GameItem:setVersionState(game, version)
	local flag = false
	cclog("GameItem:setVersionState >>>", game, version)
	if game and version then
		flag = externGameMgr:isNewVersion(game, version)
	end

	-- self.stat_down:setVisible(flag)
	-- self.stat_del:setVisible(false)


    local isExist = externGameMgr:isGameDirExist(game)

    if isExist then
        self:setState(flag and 3 or 0, -1)
    else
        if flag then
            self:setState(1, -1)
        else
            self:setState(0, -1)
        end
    end

    --灰色未下载代码先别删
    -- if self.headsp and not tolua.isnull(self.headsp) then
    --     if isExist then
    --         self.headsp:setGray(false)
    --     else
    --         self.headsp:setGray(true)
    --     end
    -- end



end

function GameItem:setDelState(game, bool)

	-- bool = bool and externGameMgr:isGameDirExist(game)
	-- self.stat_del:setVisible(bool)

    self:setState(2, -1)
	if bool then
		-- self.stat_down:setVisible(false)
	end
end


function GameItem:setListenTouch(callback)

	self.bg:onTouch(callback)
end


-- c_state 控制状态， s_state 显示状态,  0表示该类型状态无显示，-1表示不改变该类型状态
function GameItem:setState(c_state, s_state)
    if c_state ~= -1 then
        self.stat_down:setVisible(c_state == 1)
        self.stat_del:setVisible(c_state == 2)
        self.stat_update:setVisible(c_state == 3)
    end

    if s_state ~= -1 then
        self.stat_hot:setVisible(s_state == 1)
        self.stat_tuijian:setVisible(s_state == 2)
    end
end

function GameItem:setShowState(s_state)

    s_state = s_state or 0
    self:setState(-1, s_state)
end

function GameItem:setIcon(id, url)
    self:DownloadImageNode_setIconObj(self.icon)
    self:DownloadImageNode_setIcon(url)
end

function GameItem:removeHeadImg()
    self:DownloadImageNode_removeHeadImg()
end


-- function GameItem:setIcon(id, url)
--     self.id = id or ""
--     self.url = url or ""

--     self:resetIcon(id, url)
-- end

-- function GameItem:resetIcon(id, url)
--     -- body
--     if self.id == "" and self.url == "" then
--         return
--     end
--     self:removeHeadImg()
    
--     local id = self.id
--     local url = self.url

--     local function get_md5(content)      
--         return md5.sumhexa(content)
--     end
--     print("get_md5 = ", get_md5(self.url))
--     local pathName = get_md5(self.url).."icon.png"
--     local imagepath = externGameMgr:getGameIconDir() ..pathName
--     local image = cc.FileUtils:getInstance():isFileExist(imagepath)
--     release_print("pathName = ",pathName)
--     release_print("url = ",url)
--     release_print("imagepath = ",imagepath)
--     if image then
--         local headsp =  cc.Sprite:create(imagepath)
--         if headsp then
--             headsp:setAnchorPoint(cc.p(0.5,0.5))
--             release_print("show icon image")
--             local Basesize = self.icon:getContentSize()
--             local Tsize = headsp:getContentSize()
--             headsp:setPosition(Basesize.width/2, Basesize.height/2)
--             headsp:setScale((Basesize.width) / Tsize.width ,(Basesize.height) / Tsize.height)
--             self.icon:addChild(headsp)
--             self.headsp = headsp
--         end
--     else
--         local check_id, check_url = id, url
--         local function callback()
--             --检测闭包前的数据是否跟回调时的一致，不一致意味着闭包返回时，图片被重新设置了
--             cclog("Download image ok")
--             if check_url == self.url and check_id == self.id then
--                 eventMgr:dispatchEvent("updateHeadImage")           
--             end
--         end
--         eventMgr:removeEventListenerForTarget(self)
--         eventMgr:registerEventListener("updateHeadImage",handler(self,self.setDownloaded),self)
--         comFunMgr:DownloadFile2(url , imagepath , callback)  
--     end
-- end

-- function GameItem:setDownloaded()
-- 	cclog("GameItem:setDownloaded >>>")
--     if self.id == "" and self.url == "" then
--         return
--     end

--     local id = self.id
--     local url = self.url
--     local function get_md5(content)      
--         return md5.sumhexa(content)
--     end
--     print("get_md5 = ", get_md5(self.url))
--     local pathName = get_md5(self.url).."icon.png"
--     local imagepath = externGameMgr:getGameIconDir() ..pathName
--     local image = cc.FileUtils:getInstance():isFileExist(imagepath)
--     release_print("pathName = ",pathName)
--     release_print("url = ",url)
--     release_print("imagepath = ",imagepath)
--     if image then
--         local headsp =  cc.Sprite:create(imagepath)
--         if headsp and not tolua.isnull(self.icon) then
--             headsp:setAnchorPoint(cc.p(0.5,0.5))
--             release_print("show icon image")
--             local Basesize = self.icon:getContentSize()
--             local Tsize = headsp:getContentSize()
--             headsp:setPosition(Basesize.width/2, Basesize.height/2)
--             headsp:setScale((Basesize.width) / Tsize.width ,(Basesize.height) / Tsize.height)
--             self.icon:addChild(headsp)
--             self.headsp = headsp
--         end
--     end
-- end

-- function GameItem:removeHeadImg()
--     if not tolua.isnull(self.icon) then
--         self.icon:removeAllChildren()
--     end
-- end

return GameItem