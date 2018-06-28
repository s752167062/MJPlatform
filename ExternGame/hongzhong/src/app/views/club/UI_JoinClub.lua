

local UI_JoinClub = class("UI_JoinClub", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_JoinClub:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_JoinClub.csb")
    self.root:addTo(self)

    UI_JoinClub.super.ctor(self)
    _w = self._childW
    
    
    self:initUI()
    self:setMainUI()
end

function UI_JoinClub:onEnter()
    -- body
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onSearchClub(data) end, "onSearchClub")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:onJoinClub(data) end, "onJoinClub")
end

function UI_JoinClub:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function UI_JoinClub:update(t)
    
end

function UI_JoinClub:initUI()
    -- body
    self.node_club        = _w["node_club"]
    self.img_icon         = _w["img_icon"]
    self.textFiled_findID = _w["textFiled_findID"]
    self.txt_name         = _w["txt_name"]
    self.txt_id           = _w["txt_id"]
    self.txt_people       = _w["txt_people"]
    self.txt_qunzhu       = _w["txt_qunzhu"]
    self.txt_guanliyuan   = _w["txt_guanliyuan"]
    self.scroll_jieshao   = _w["scroll_jieshao"]
    self.txt_jieshao      = _w["txt_jieshao"]
    self.btn_applyfor     = _w["btn_applyfor"]
end

--主设置
function UI_JoinClub:setMainUI()
    self.node_club:setVisible(false)
end

function UI_JoinClub:onClick(_sender)
	local name = _sender:getName()
    if name == "btn_close" then
        self:closeUI()
    elseif name == "btn_sure" then
        self:searchClub()
    elseif name == "btn_create" then
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_CreateClub")
        scene:addChild(ui.new({app = nil}))
        self:closeUI()
    elseif name == "btn_applyfor" then
        self:applyfor()
        --self:closeUI()
    end  
end

--搜索
function UI_JoinClub:searchClub()
    local content = self.textFiled_findID:getString()
    cclog("search:"..content)
    ex_hallHandler:toSearchClub(content)
end    

function UI_JoinClub:onSearchClub(data)
    cclog("UI_JoinClub:onSearchClub") 
    print_r(data)
    self.node_club:setVisible(true)

    local path = ClubManager:getClubIconPathById(data.clubHead)
    self.img_icon:loadTexture(path, 1)
    self.txt_name:setString(data.clubName or "")
    self.txt_people:setString(string.format("%s/%s", tostring(data.memberNum or 0), tostring(data.memberNumMax)) )
    self.txt_id:setString(data.clubId or "")
    self.txt_qunzhu:setString(data.createrName or "")

    self.txt_guanliyuan:setString(data.managerName or "")
    self.txt_guanliyuan:setString("(暂未开放)")

    self.txt_jieshao:setString(data.describe or "")
    self.clubID = data.clubId

    self.scroll_jieshao:jumpToTop()
end

--申请
function UI_JoinClub:applyfor()
    if (not self.clubID) or self.clubID == "" then
        GlobalFun:showToast("请输入俱乐部ID", 2)
        return
    end
    ex_hallHandler:toJoinClub(self.clubID)
end

function UI_JoinClub:onJoinClub(res)
    -- body
    cclog("UI_JoinClub:onJoinClub")
    self:closeUI()
end

return UI_JoinClub
