

local UI_JoinClub = class("UI_JoinClub", cc.load("mvc").ViewBase)

UI_JoinClub.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/ClubView/UI_JoinClub.csb"




function UI_JoinClub:onEnter()
    self:initUI()
    self.node_club:setVisible(false)

    -- body
    eventMgr:registerEventListener("HallProtocol.onSearchClub",handler(self,self.onSearchClub),self)
    eventMgr:registerEventListener("onJoinClub",handler(self,self.onJoinClub),self)
end

function UI_JoinClub:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end

function UI_JoinClub:initUI()
    -- body
    self.node_club        = self:findChildByName("node_club")
    self.img_icon         = self:findChildByName("img_icon")
    self.textFiled_findID = self:findChildByName("textFiled_findID")
    self.txt_name         = self:findChildByName("txt_name")
    -- self.txt_id           = self:findChildByName("txt_id")
    self.txt_people       = self:findChildByName("txt_people")
    self.txt_qunzhu       = self:findChildByName("txt_qunzhu")
    self.txt_guanliyuan   = self:findChildByName("txt_guanliyuan")
    self.scroll_jieshao   = self:findChildByName("scroll_jieshao")
    self.txt_jieshao      = self:findChildByName("txt_jieshao")
    self.btn_applyfor     = self:findChildByName("btn_applyfor")




    self.btn_close = self:findChildByName("btn_close")
    self.btn_close:onClick(function () self:closeUI() end)

    self.btn_sure = self:findChildByName("btn_sure")
    self.btn_sure:onClick(function () self:searchClub() end)

    self.btn_create = self:findChildByName("btn_create")
    self.btn_create:onClick(function () self:createClub() end)

    self.btn_applyfor = self:findChildByName("btn_applyfor")
    self.btn_applyfor:onClick(function () self:applyfor() end)


    -- local data = {}
    -- data.id = "2"
    -- data.clubName = "啦啦啦"
    -- data.clubId = "1234567"
    -- data.memberNum = 999
    -- data.memberNumMax = 999
    -- data.createrName = "笑嘻嘻"
    -- data.managerName = "大包子"
    -- data.describe = "ADSL就番外"

    -- self:onSearchClub(data)
end

function UI_JoinClub:onUIClose()
    self:closeUI()
end

function UI_JoinClub:closeUI()
    viewMgr:close("ClubView.UI_JoinClub")
end





function UI_JoinClub:createClub()
    viewMgr:show("ClubView.UI_CreateClub")
    self:closeUI()
end

--搜索
function UI_JoinClub:searchClub()
    local content = self.textFiled_findID:getString()
    cclog("search:"..content)
    self.node_club:setVisible(false)
    -- if self.sourceType == "club" then
    --     clubHandler:gotoSearchClub(content)
    -- else
    --     hallHandler:gotoSearchClub(content)
    -- end
    if content and content ~="" and tonumber(content) then
        hallSendMgr:sendSearchClub(tonumber(content))
    else
        msgMgr:showToast("您输入俱乐部id格式不是数字,请输入数字", 3) 
    end
end    

function UI_JoinClub:onSearchClub(data)
    self.node_club:setVisible(true)


   local path = clubMgr:getIconPathById(data.head)
   self.img_icon:loadTexture(path, 1)


    self.txt_name:setString(string.format("%s(%s)", data.name, data.gid))
    self.txt_people:setString(string.format("%s/%s", tostring(data.memberNum or 0), tostring(data.memberNumMax)) )
    -- self.txt_id:setStringByWidth(data.clubId or "",87)
    self.txt_qunzhu:setStringByWidth(data.masterName or "",200)
    local glyname = "暂无"
    if data.assistantName and data.assistantName ~= "" then
        glyname = data.assistantName
    end
    self.txt_guanliyuan:setStringByWidth(glyname, 200)
    self.txt_jieshao:setString(data.intro or "")

    self.txt_jieshao:setTextAreaSize(cc.size(375, 0))
    self.txt_jieshao:ignoreContentAdaptWithSize(false)
    local size = self.txt_jieshao:getVirtualRendererSize()
    cclog(">>>>", size.width, size.height)
    self.txt_jieshao:setTextAreaSize(size)

    local js_size = self.scroll_jieshao:getContentSize()
    local w = js_size.width <size.width and size.width or js_size.width
    local h = js_size.height <size.height and size.height or js_size.height
    self.txt_jieshao:setPosition(2, h)
    self.scroll_jieshao:setInnerContainerSize(cc.size(w, h))

    -- local innerSize = self.scroll_jieshao:getInnerContainer():getContentSize()
    -- self.scroll_jieshao:setInnerContainerSize(cc.size(innerSize.width,totalHeight))

    self.clubID = data.gid

    self.scroll_jieshao:jumpToTop()
end

--申请
function UI_JoinClub:applyfor()
    if (not self.clubID) or self.clubID == "" then
        return
    end
    -- if self.sourceType == "club" then
    --     clubHandler:gotoJoinClub(self.clubID)
    -- else
    --     hallHandler:gotoJoinClub(self.clubID)
    -- end

    hallSendMgr:sendJoinClub(self.clubID)
end

function UI_JoinClub:onJoinClub(res)
    -- body
    self:closeUI()
end

return UI_JoinClub
