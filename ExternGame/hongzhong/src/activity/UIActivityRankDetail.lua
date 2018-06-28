local uiActivityRankDetail = class("uiActivityRankDetail", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityRankDetail.RESOURCE_FILENAME = "activity2/uiActivityRankDetail.csb"
uiActivityRankDetail.RESOURCE_BINDING = {
    ["clubicon"]            = {    ["varname"] = "clubicon"             },
    ["txt_clubname"]        = {    ["varname"] = "txt_clubname"         },
    ["txt_clubid"]          = {    ["varname"] = "txt_clubid"           },
    ["txt_mynum"]           = {    ["varname"] = "txt_mynum"         },
    ["uilistview"]          = {    ["varname"] = "uilistview"           },

    ["btn_close"]   = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onClose"    } }       },
    ["btn_closeAll"]  = {    ["varname"] = "btn_closeAll"        ,  ["events"] = { {event = "click" ,  method ="onCloseAll"} }       },
    
}

function uiActivityRankDetail:onCreate()
    cclog("CREATE")
    self.callfunc = nil
end

function uiActivityRankDetail:onEnter()
    cclog("ENTER")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:rankData(data) end ,"GetActivityRankDetail")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:removeFromParent() end ,"ActivitysCloseAll")

    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
        ActivityMgr:getActivityRankDetail(self.data.clubID or 0) --前10排名 #2222
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        ActivityMgr:getActivityRankDetailClub(self.data.clubID or 0) --前10排名
    end
end

function uiActivityRankDetail:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end

function uiActivityRankDetail:setClubData(data)
    if data then 
        self.data = data
        local ranking = data.ranking

        self.txt_mynum:setString(ranking or "0")
        self.txt_clubname:setString(data.clubName or "")
        self.txt_clubid:setString(data.clubID or "")

        local spriteFrame = display.newSpriteFrame(string.format("image2/activity2/icon%s.png",data.icon ))  
        local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
        sprite:setScale(0.7)
        sprite:addTo(self.clubicon)
        
        local rank = tonumber(ranking or 0) or 0
        if rank >0 and rank <4 then 
            local img_rank = self.txt_mynum:getChildByName("no"..rank)
            if img_rank then
                img_rank:setVisible(true)
            end 
        elseif rank == 0 then
            self.txt_mynum:setString("")
            local norank = self.txt_mynum:getChildByName("norank")
            if norank then 
                norank:setPosition(cc.p(20,-1))
                norank:setVisible(true)
            end
        end     


    end   
end

function uiActivityRankDetail:rankData(data)
    if data then
        cclog("-- #2222 前10排名") 
        -- print_r(data)
        self:reRanking(data) --重新排名
        local downloadList = {}
        for k,v in pairs(data) do
            local itemdata = data[k]

            local layer = ccui.Layout:create()
            layer:setContentSize(cc.size(707,63))

            local item = ex_fileMgr:loadLua("activity.itemRankDetail").new()
            item:setTag(k)
            item:setPositionX(8)
            item:initData(itemdata)

            layer:addChild(item)
            self.uilistview:pushBackCustomItem(layer)

            downloadList[#downloadList +1] = itemdata._icon 
        end
    end    
end
--重新处理下排名数据
function uiActivityRankDetail:reRanking(data)
    local rank = 1
    if data and #data > 1 then
        for i=2,#data do
            local item = data[i]
            if item then 
                local _score = item._score
                local _scorebefore = data[i-1]._score
                if _score < _scorebefore then 
                    rank = rank + 1
                    data[i]._rank = rank
                else
                    data[i]._rank = rank
                end    
            end    
        end
    end    
end

------ 按钮 -------
function uiActivityRankDetail:onClose()
	cclog("-------onClose")
	self:removeFromParent()
end

function uiActivityRankDetail:onCloseAll()
    CCXNotifyCenter:notify("ActivitysCloseAll")
end


return uiActivityRankDetail
