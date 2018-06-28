

local UI_StartDesk = class("UI_StartDesk", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_StartDesk:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_StartDesk.csb")
    self.root:addTo(self)

    UI_StartDesk.super.ctor(self)
    _w = self._childW
    
    self.deskNumb = data.deskNumb
    self:initUI()
end

function UI_StartDesk:onExit()
    CCXNotifyCenter:unListenByObj(self)
end

function UI_StartDesk:onEnter()

end

function UI_StartDesk:onUIClose()
    self:removeFromParent()
end



function UI_StartDesk:initUI()
    self.ju = {
        CheckBox_2_1 = {obj = _w["CheckBox_2_1"], info = 8},
        CheckBox_2_2 = {obj = _w["CheckBox_2_2"], info = 16}
    }

    self:setSelect("CheckBox_2_1")

    self.txt_rule = _w["txt_rule"]

    local data = ClubManager:getInfo("game_setting")
    if data and data.playRuleTb and next(data.playRuleTb) then
        local info = data.playRuleTb[1]
        local str = GameRule:clubGameRuleText2(info)

        self.txt_rule:setString("玩法:" .. str)
    else
        self.txt_rule:setString("请通知管理员或会长设置玩法规则")
    end
end

function UI_StartDesk:setSelect(name)

    for k,v in pairs(self.ju) do
        if k == name then
            v.obj:setSelected(true)
            v.obj:setTouchEnabled(false)

        else
            v.obj:setSelected(false)
            v.obj:setTouchEnabled(true)
        end
    end

end


function UI_StartDesk:onClick(_sender)
    local name = _sender:getName()
    if name == "btn_quxiao" then
        self:onUIClose()
    elseif name == "CheckBox_2_1" then
        self:setSelect(name)
    elseif name == "CheckBox_2_2" then
        self:setSelect(name)
    elseif name == "btn_chuangjian" then
        self:start()
    end
end

function UI_StartDesk:start()
    local ju = 8
    for k,v in pairs(self.ju) do
        if v.obj:isSelected() then
            ju = v.info
        end
    end

   



    cclog("UI_StartDesk:start >>>", ju, self.deskNumb)
    local tab = ClubManager:getInfo("game_setting")
    if tab and next(tab.playRuleTb) then

        ex_clubHandler:gotoRequestCreateRoom(1, self.deskNumb -1, ju) 
    else
        ClubGlobalFun:showError("会长或管理员未设置玩法规则", nil, nil, 2)

    end

    self:onUIClose()
end

return UI_StartDesk














