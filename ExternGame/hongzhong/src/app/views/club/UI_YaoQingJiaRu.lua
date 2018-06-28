

local UI_YaoQingJiaRu = class("UI_YaoQingJiaRu", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_YaoQingJiaRu:ctor(data)
    self.app = data.app
    self.param = data.param
    self.root = display.newCSNode("club/UI_YaoQingJiaRu.csb")
    self.root:addTo(self)

    UI_YaoQingJiaRu.super.ctor(self)
    _w = self._childW
    
    self.curUserData = nil
    
    self:initUI()
    self:setMainUI()
end

function UI_YaoQingJiaRu:onEnter()
    -- body
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onSearchMember(data) end, "S2C_onSearchPlayer")

end

function UI_YaoQingJiaRu:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function UI_YaoQingJiaRu:update(t)
    
end

function UI_YaoQingJiaRu:initUI()
    -- body
    self.title          = _w["title"]
    self.my_icon        = _w["my_icon"]
    self.txt_name       = _w["txt_name"]
    self.txt_id         = _w["txt_id"]
    self.textFiled_findID = _w["textFiled_findID"]
    self.panel_info     = _w["panel_info"]
    self.btn_left       = _w["btn_left"]

end

--主设置
function UI_YaoQingJiaRu:setMainUI()
    -- if self.param.useType ~= nil then
    --     if self.param.useType == 1 then   --任命管理员
    --         self.title:setTexture("image2/club/title/title_renmingguanliyuan.png")
    --         self.btn_left:loadTextureNormal("image2/club/btn/txtbtn/btn_renming2.png")
    --         self.btn_left:loadTexturePressed("image2/club/btn/txtbtn/btn_renming2.png")
    --         self.btn_left:loadTextureDisabled("image2/club/btn/txtbtn/btn_renming2.png")
    --     -- elseif self.param.useType == 2 then   --邀请成员
    --     --     self.title:setTexture("image2/club/title/title_yaoqingjiaru.png")-- title_yaoqingchengyuan
    --     --     self.btn_left:loadTextureNormal("image2/club/btn/txtbtn/btn_yaoqing.png")
    --     --     self.btn_left:loadTexturePressed("image2/club/btn/txtbtn/btn_yaoqing.png")
    --     --     self.btn_left:loadTextureDisabled("image2/club/btn/txtbtn/btn_yaoqing.png")
    --     end
    -- end
    self.panel_info:setVisible(false)
    --self:onSearchMember()
end

function UI_YaoQingJiaRu:onClick(_sender)
	local name = _sender:getName()
    if name == "btn_close" then
        self:closeUI()
    elseif name == "btn_sure" then
        self:searchMember()
    elseif name == "btn_left" then
        cclog("邀请成员")
        if self.curUserData ~= nil then
            ex_clubHandler:toInviteMemberToClub(self.curUserData.userID)
        else
            GlobalFun:showToast("请先搜索出需要邀请的玩家", 2)  
        end
            
        --  if self.param.useType == 1 then   --任命管理员
        --     cclog("任命管理员")
        --     if self.curUserData ~= nil then
        --         local function cb( ... )
        --             -- body
        --             ex_clubHandler:toAppointManager(self.curUserData.userID)
        --         end
        --         ClubGlobalFun:showError(string.format("确定任命【%s】玩家为管理员吗？", self.curUserData.userName), cb, nil, 2)
        --     else
        --         GlobalFun:showToast("请先搜索出需要任命的成员", 2)  
        --     end
        -- elseif self.param.useType == 2 then   --邀请成员
        --     cclog("邀请成员")
        --     if self.curUserData ~= nil then
        --         ex_clubHandler:toInviteMemberToClub(self.curUserData.userID)
        --     else
        --         GlobalFun:showToast("请先搜索出需要邀请的玩家", 2)  
        --     end
        -- end
        --self:closeUI()
    elseif name == "btn_right" then
        self:closeUI()
    end  
end

--搜索
function UI_YaoQingJiaRu:searchMember()
    local content = self.textFiled_findID:getString()
    cclog("搜索玩家 search:"..content)
    ex_clubHandler:toSearchPlayer(content, false)

    -- if self.param.useType == 1 then

    --     ex_clubHandler:toSearchPlayer(content, true)
    -- elseif self.param.useType == 2 then
    --     ex_clubHandler:toSearchPlayer(content, false)
    -- end

end    

function UI_YaoQingJiaRu:onSearchMember(data)
    cclog("UI_YaoQingJiaRu:onSearchClub") 
    if data.status == 1 then
        ClubGlobalFun:showError("查询不到结果", nil, nil, 2)
        self.panel_info:setVisible(false)
        return
    end

    if not self.icon_common then
        local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
        local size = self.my_icon:getContentSize()
        icon:setPosition(size.width/2, size.height/2)
        self.icon_common = icon
        self.my_icon:addChild(icon)
    end


    self.panel_info:setVisible(true)

    self.curUserData = data

    self.txt_name:setString(data.userName)
    self.txt_id:setString("ID: " ..data.userID)

    --self.my_icon
    self.icon_common:removeHeadImg()
    self.icon_common:setIcon(data.userID, data.icon)
end

return UI_YaoQingJiaRu
