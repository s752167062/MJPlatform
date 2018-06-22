local md5 = require "Manager.md5"

-- local HallClubItem = class("HallClubItem", function() 
--    return cc.Node:create()
-- end)

-- local DownloadImageNode = require("app.common.DownloadImageNode")
local HallClubItem = class("HallClubItem", function() return cc.Node:create() end)



function HallClubItem:ctor()

    self:enableNodeEvents()


	self.root = display.newCSNode(__platformHomeDir .. "ui/layout/ClubItem.csb")
    self.root:addTo(self)

    self.icon = self.root:findChildByName("icon")

end

function HallClubItem:onEnter()
    cclog("HallClubItem:onEnter >>>")
end

function HallClubItem:onExit()
    cclog("HallClubItem:onExit  >>>>")
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end


function HallClubItem:setIcon(url)
    -- self:DownloadImageNode_setIconObj(self.icon)
    -- self:DownloadImageNode_setIcon(url)
end

function HallClubItem:removeHeadImg()
    -- self:DownloadImageNode_removeHeadImg()
end




return HallClubItem