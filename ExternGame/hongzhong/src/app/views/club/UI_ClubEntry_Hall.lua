
ex_fileMgr:loadLua(("app/views/club/ClubGlobalFun"))
local UI_ClubEntry_Hall = class("UI_ClubEntry_Hall", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubEntry_Hall:ctor()

    self.root = display.newCSNode("club/UI_ClubEntry_Hall.csb")
    self.root:addTo(self)

    UI_ClubEntry_Hall.super.ctor(self)
    _w = self._childW
  
    self:initUI()
    self:setMainUI()
end

function UI_ClubEntry_Hall:initUI()
    -- self.btn_head = _w["btn_head"]
    -- self.playerIcon = _w["playerIcon"]
    -- self.playerName = _w["playerName"]
    -- self.playerID = _w["playerID"]
    self.clubList = _w["clubList"]
    self.emptyBg = _w["emptyBg"]
    self.clubList:setScrollBarOpacity(0)
    -- self.hasCreateNum = _w["hasCreateNum"]
    -- self.hasJoinNum = _w["hasJoinNum"]

    CCXNotifyCenter:listen(self,function(obj,key,data) self:updateList(data) end, "onClubList")
    CCXNotifyCenter:listen(self,function() ex_hallHandler:toClubList() end, "onCreateClub")
    CCXNotifyCenter:listen(self,function() ex_hallHandler:toClubList() end, "onRequestJoinResult")

    if GlobalData.curScene == SceneType_Club then  -- 俱乐部里面不能创建、加入俱乐部
        -- _w["Text_2_2_1_0"]:setVisible(false)
        -- _w["Text_2_2_1"]:setVisible(false)
        _w["btn_createClub"]:setVisible(false)
        _w["btn_joinClub"]:setVisible(false)
    end

end

function UI_ClubEntry_Hall:onEnter()
    -- body
    
end

function UI_ClubEntry_Hall:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function UI_ClubEntry_Hall:onClick(_sender)
    local name = _sender:getName()

    if name == "btn_close" then
        self:closeUI()
    elseif name == "btn_createClub" or name == "emptyBg" then
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_CreateClub")
        scene:addChild(ui.new({app = nil}))
        --self:closeUI()
    elseif name == "btn_joinClub" then
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_JoinClub")
        scene:addChild(ui.new({app = nil}))
        --self:closeUI()
    elseif name == "btn_shuaxin" then
        if not self.shuaxin_lock then
            self.shuaxin_lock = true
            local schedulerID = false
            local scheduler = cc.Director:getInstance():getScheduler()
            local function cb(dt)
                cclog("self.shuaxin_lock  false")
                scheduler:unscheduleScriptEntry(schedulerID)
                self.shuaxin_lock = false
            end
            schedulerID = scheduler:scheduleScriptFunc(cb, 5,false) 
            ex_hallHandler:toClubList()
            GlobalFun:showToast("刷新成功" , 3)
            CCXNotifyCenter:notify("ActivitysReCheckActivity") -- 用于活动的刷新（活动结束后可以删除）
        else
            GlobalFun:showToast("刷新过于频繁，请稍后再刷新" , 3)
        end

    -- elseif name == "btn_clubPrivilege" then
    --     local scene = cc.Director:getInstance():getRunningScene()
    --     local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubPrivilege")
    --     scene:addChild(ui.new({app = nil}))
    end    
end

--主设置
function UI_ClubEntry_Hall:setMainUI()
    -- self.playerName:setString(PlayerInfo.nickname)
    -- GlobalFun:uiTextCut(self.playerName)
    -- self.playerID:setString(PlayerInfo.playerUserID)
    -- self:setIcon()
    -- self.hasCreateNum:setString("0/5")
    -- self.hasJoinNum:setString("0/10")
end

-- function UI_ClubEntry_Hall:setIcon()    
--     if PlayerInfo.imghead ~= "" then
--         local path = ex_fileMgr:getWritablePath()..PlayerInfo.imghead
--         cclog("path "..path)
--         local headsp =  cc.Sprite:create(path)
--         if headsp == nil then
--             cc.Director:getInstance():getTextureCache():reloadTexture(path);
--             headsp =  cc.Sprite:create(path)
--             if headsp == nil then
--                 CCXNotifyCenter:listen(self,function() self:setIcon() end, "ShowIcon2")
--                 return
--             end
--         end
--         headsp:setAnchorPoint(cc.p(0,0))
--         local Basesize = self.btn_head:getContentSize()
--         local Tsize = headsp:getContentSize()
--         headsp:setScale(Basesize.width / Tsize.width ,Basesize.height / Tsize.height)
--         self.btn_head:addChild(headsp)  
--     else
--         CCXNotifyCenter:listen(self,function() self:setIcon() end, "ShowIcon2")
--     end
-- end

--设置列表
function UI_ClubEntry_Hall:updateList(data)
    cclog("UI_ClubEntry_Hall:updateList")

    self.clubList:removeAllChildren()

    self._data = data
    local clubTb = self._data.clubTb
    cclog("clubTb size:"..#(clubTb))

    self.emptyBg:setVisible(#(clubTb) <= 0)

    local meTb = {}
    local otherTb = {}
    for i, v in ipairs(clubTb) do
        --v.index = i
        if v.createrId == PlayerInfo.playerUserID then
            v.index = #meTb + 1
            table.insert(meTb, v)
        else
            v.index = #otherTb + 1
            table.insert(otherTb, v)
        end
    end

    local function sort(a, b)
        return a.index > b.index
    end
    table.sort(meTb, sort)
    table.sort(otherTb, sort)

    clubTb = {}
    for i, v in ipairs(meTb) do table.insert(clubTb, v) end
    for i, v in ipairs(otherTb) do table.insert(clubTb, v) end

    self._data.clubTb = clubTb
--    for i = 1, 7 do   
    local isMyClub = 0
    local isOtherClub = 0
    for i, v in ipairs(clubTb) do

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(330, 65))

        local item = display.newCSNode("club/Item_clubliebiao2.csb")
        local _itemW = self:loadChildrenWidget(item)
        --[[
            clubName, clubId, clubHead, createrName, createrId, posi(0：会员 1：管理员 2：会长), memberNum, memberMax
        --]]

        if v.createrId == PlayerInfo.playerUserID then
            isMyClub = isMyClub + 1 
        else
            isOtherClub = isOtherClub + 1
        end
        _itemW["flag"]:setVisible(v.createrId == PlayerInfo.playerUserID)
        _itemW["flag2"]:setVisible(v.createrId ~= PlayerInfo.playerUserID)

        local path = ClubManager:getClubIconPathById(v.clubHead)
        cclog("path:"..path)
        _itemW["icon"]:loadTexture(path, 1)


        _itemW["clubName"]:setString(string.format("%s", v.clubName)..string.format("  (ID:%s)", v.clubId))
        --_itemW["txt_clubId"]:setString(string.format("(ID:%s)", v.clubId))
        _itemW["txt_clubId"]:setString("")

        _itemW["clubOwnerName"]:setString(string.format("会长:%s", v.createrName))

        _itemW["panel_sq_xiaoxi"]:setVisible(v.createrId == PlayerInfo.playerUserID and tonumber(v.reqInfosSize) > 0)
        _itemW["txt_sq_xiaoxiNum"]:setString(tonumber(v.reqInfosSize) > 9 and "" or v.reqInfosSize)

        layout:setTag(i)
        layout:setTouchEnabled(true)
        layout:setSwallowTouches(false)
        layout:addClickEventListener(
            function(sender) 
                local info = self._data.clubTb[sender:getTag()]
                cclog("onClick clubID:"..info.clubId)
                if self._data.socketType == "hall" then

                    ex_hallHandler:gotoClub(info.clubId)
                    GlobalFun:showNetWorkConnect("正在直连俱乐部...")
                    --- 链接俱乐部超时处理
                    if not self.gotoClubSchedulerID then
                        local scheduler = cc.Director:getInstance():getScheduler()
                        local function cb(dt)
                            cclog("gotoClub scheduler")
                            if self.gotoClubSchedulerID then
                                GlobalFun:closeNetWorkConnect()
                                scheduler:unscheduleScriptEntry(self.gotoClubSchedulerID)
                                self.gotoClubSchedulerID = false
                            end
                        end
                        self.gotoClubSchedulerID = scheduler:scheduleScriptFunc(cb, 20,false) 
                    end
                    --- 链接俱乐部超时处理
                    CCXNotifyCenter:listen(self,function() 
                            if self.gotoClubSchedulerID then
                                local scheduler = cc.Director:getInstance():getScheduler()
                                scheduler:unscheduleScriptEntry(self.gotoClubSchedulerID)
                                self.gotoClubSchedulerID = false
                            end
                    end,"HALL:onGotoClub")
                elseif self._data.socketType == "club" then
                    ex_clubHandler:gotoClub(info.clubId)
                    self:closeUI()
                end

            end)

        --item:setPosition(cc.p(pos_x,pos_y))
        item:addTo(layout)

        self.clubList:pushBackCustomItem(layout)
    end

    -- self.hasCreateNum:setString(isMyClub.."/5")
    -- self.hasJoinNum:setString(isOtherClub.."/10")

end

return UI_ClubEntry_Hall
