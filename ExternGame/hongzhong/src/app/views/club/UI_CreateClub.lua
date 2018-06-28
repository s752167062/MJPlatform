

local UI_CreateClub = class("UI_CreateClub", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_CreateClub:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_CreateClub.csb")
    self.root:addTo(self)

    UI_CreateClub.super.ctor(self)
    _w = self._childW
    
    self._iconId = 1001

    self:initUI()
    self:setMainUI()
end

function UI_CreateClub:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function UI_CreateClub:onEnter()
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onCreateClub(data) end, "onCreateClub")
end

function UI_CreateClub:onUIClose()
    self:removeFromParent()
end

function UI_CreateClub:initUI()
    -- body
    self.img_icon = _w["img_icon"]
    self.img_icon:setTouchEnabled(true)
    --self.img_icon:addClickEventListener(function() self:onClick(self.img_icon) end)


    self.textField_name = _w["textField_name"]
    self.textField_name:setEnabled(true)
    self.txt_city = _w["txt_city"]
    self.txt_area = _w["txt_area"]
    self.txt_town = _w["txt_town"]
end

--主设置
function UI_CreateClub:setMainUI()
   
end

function UI_CreateClub:onClick(_sender)
	local name = _sender:getName()
    if name == "btn_close" then
        self:onUIClose()
    elseif name == "btn_changeIcon" or name == "img_icon" then
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_SelectClubIcon")
        local function callBack(id)
            --返回设置头像
            self.curIcon = id
            self.img_icon:loadTexture(ClubManager:getClubIconPathById(id),1)
            return true
        end
        scene:addChild(ui.new({app = nil, callBack = callBack}))
    elseif name == "btn_sure" then
        --确定创建俱乐部
        self:createClub()
        --self:onUIClose()
    elseif name == "btn_cancel" then
        self:onUIClose()
    elseif name == "btn_changeName" then
        self.textField_name:setEnabled(true)
    end  
end

--申请创建俱乐部
function UI_CreateClub:createClub()
    local name = self.textField_name:getString()
    local iconID = self.curIcon or "1"
    ex_hallHandler:toCreateClub({clubName = name, clubIcon = iconID})
end

function UI_CreateClub:onCreateClub(data)
    -- body
    cclog("UI_CreateClub:onCreateClub")
    self:closeUI()
end

return UI_CreateClub
