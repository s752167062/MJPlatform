local uiActivityClubList = class("uiActivityClubList", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityClubList.RESOURCE_FILENAME = "activity2/uiActivityClubList.csb"
uiActivityClubList.RESOURCE_BINDING = {
    ["uilistview"]     = {    ["varname"] = "uilistview"           },
    ["ctn_nodata"]     = {    ["varname"] = "ctn_nodata"           },
    ["ctn_nodata_over"]= {    ["varname"] = "ctn_nodata_over"      },
    ["btn_close"]      = {    ["varname"] = "btn_close"              ,  ["events"] = { {event = "click" ,  method ="onBack"    } }       },
    ["btn_closeAll"]     = {    ["varname"] = "btn_closeAll"         ,  ["events"] = { {event = "click" ,  method ="onCloseAll"} }       },
}

function uiActivityClubList:onCreate()
    cclog("CREATE")
end

function uiActivityClubList:onEnter()
    cclog("ENTER")

    CCXNotifyCenter:listen(self,function(self,obj,data) self:updateActivityClubList(data) end ,"onActivityClubList")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:removeFromParent() end ,"ActivitysCloseAll")
    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
        ActivityMgr:getActivityClubList()
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        ActivityMgr:getActivityClubListClub()
    end
end

function uiActivityClubList:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end

function uiActivityClubList:updateActivityClubList(data)
    if data then 
        local _data  = data._data
        if _data and #_data >0 then 
            self:initData(_data)
        else
            if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_OPENED then
                self.ctn_nodata:setVisible(true) -- 
            else
                self.ctn_nodata_over:setVisible(true)
            end    
        end    
    end    
end
--667 63
function uiActivityClubList:initData(data)    
    self.uilistview:removeAllItems() -- 移除原有的数据节点
    for index=1,#data do
        local itemdata = data[index]
        
        local layer = ccui.Layout:create()
        layer:setContentSize(cc.size(667,63))

        local item = self:createItem(itemdata)
        item:setName("CSNode")
        item:setTag(index)
        item:setPosition(cc.p(0,0))
        
        --add button
        local newbtn1 = ccui.Button:create("image2/activity2/one/img_titletime.png" , "image2/activity2/one/img_titletime.png")
        newbtn1:addClickEventListener(function() item:onDetail() end)
        newbtn1:setPosition(cc.p(329,31))
        newbtn1:setContentSize(cc.size(654,55))
        newbtn1:setOpacity(0)
        layer:addChild(newbtn1)

        layer:addChild(item)
        self.uilistview:pushBackCustomItem(layer)
    end
end

function uiActivityClubList:createItem(itemdata)
    local item = ex_fileMgr:loadLua("activity.UIActivityClubItem").new()
    item:initData(itemdata)
    return item
end

------ 按钮 -------

function uiActivityClubList:onBack()
    cclog("-------onBack")
    self:removeFromParent()
end

function uiActivityClubList:onCloseAll()
    CCXNotifyCenter:notify("ActivitysCloseAll")
end
return uiActivityClubList