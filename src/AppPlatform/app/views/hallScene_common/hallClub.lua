
local HallClubItem = require("app.views.hallScene_common.hallClubItem")


-- local clubItem = require("app.views.gameListView.HallClub")

local HallClub = class("HallClub", function() return cc.Node:create() end )

function HallClub:ctor(root, list, emtyImg)
	cclog("HallClub:ctor >>>>", root, list)
	self.list_club = list
    self.emtyImg = emtyImg

    self.emtyImg:setVisible(false)

	list:setScrollBarEnabled(false)



	self:enableNodeEvents()
	root:addChild(self)



end

function HallClub:onEnter()
	cclog("HallClub:onEnter >>>>")


	

    eventMgr:registerEventListener("HallProtocol.onClubList",handler(self,self.recvCommonList), self)


    hallSendMgr:sendClubList()

	-- self:recvCommonList()
end

function HallClub:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end




function HallClub:recvCommonList(res)


    self.list_club:removeAllChildren()

    if not next(res) then
        self.emtyImg:setVisible(true)
    end

    for i, v in ipairs(res) do
        local layout = ccui.Layout:create()
        
        -- local item = display.newCSNode(__platformHomeDir .. "ui/layout/ClubItem.csb")
        -- item:addTo(layout)

        local item = HallClubItem.new()
        item:addTo(layout)

        local bg = item:findChildByName("bg")
        local size = bg:getContentSize()
        cclog("xxx >", size.width, size.height)
        layout:setContentSize(cc.size(size.width, size.height))
        self.list_club:pushBackCustomItem(layout)

        local txt_name = item:findChildByName("txt_name")
        txt_name:setString("会长: " ..v.clubQunzhu)
        local txt_clubName = item:findChildByName("txt_clubName")
        txt_clubName:setString(v.clubName)
        local txt_clubId = item:findChildByName("txt_clubId")
        txt_clubId:setString("ID:" ..v.clubId)
        local icon = item:findChildByName("icon")
        local path = clubMgr:getIconPathById(v.clubIconId)
        icon:loadTexture(path,1)

  

        layout:setTouchEnabled(true)
        layout:setSwallowTouches(false)
        layout:addClickEventListener(function() 
                    self:onClickCommon(i, v.clubId)
            end)
    end

end






function HallClub:onClickCommon(index, clubId)
    cclog("HallClub:onClickCommon >>>", index)

    local view = viewMgr:show("ClubView.ClubGame_view")
    view:init(clubId)
    hallSendMgr:sendClubData(clubId)
end





return HallClub




