

local UI_ClubExit = class("UI_ClubExit", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubExit:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubExit.csb")
    self.root:addTo(self)

    UI_ClubExit.super.ctor(self)
    _w = self._childW
    
    self:initUI()
    self:setMainUI()
end

function UI_ClubExit:onExit()
    --CCXNotifyCenter:unListenByObj(self)
end

function UI_ClubExit:onEnter()
    --CCXNotifyCenter:listen(self,function(obj,key,data) self:onCreateClub(data) end, "onCreateClub")
end

function UI_ClubExit:onUIClose()
    self:removeFromParent()
end

function UI_ClubExit:initUI()
    self.btn_exit = _w["btn_exit"]
    self.mask = _w["mask"]
    self.mask:setTouchEnabled(true)
    self.mask:addClickEventListener(function() self:onClick(self.mask) end)
end

--主设置
function UI_ClubExit:setMainUI()
   if ClubManager:canDismissClub() and ClubManager:isQunZhu() then
        self.btn_exit:setTitleText("解散俱乐部")
   else
        self.btn_exit:setTitleText("退出俱乐部")
   end
end

function UI_ClubExit:onClick(_sender)
	local name = _sender:getName()
    if name == "btn_close" or name == "mask" then
        self:onUIClose()
    elseif name == "btn_exit" then
        

        local function cb ()
            if ClubManager:canDismissClub() then
                ex_clubHandler:C2S_DismissClub()
            else
                ex_clubHandler:C2S_ExitClub()
            end
            self:onUIClose()
        end
        --GlobalFun:showError(string.format("你确定要【%s】吗？", self.btn_exit:getTitleText()),cb,nil,2)
        ClubGlobalFun:showError(string.format("你确定要【%s】吗？", self.btn_exit:getTitleText()),cb,nil,2)

    elseif name == "btn_cancel" then
        self:onUIClose()
    end  
end

return UI_ClubExit
