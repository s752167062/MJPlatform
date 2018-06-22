--@信息提示
--@Author   sunfan
--@date     2017/07/27
local MsgConfirm = class("MsgConfirm",cc.load("mvc").ViewBase)

MsgConfirm.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/MessageConfirm.csb"

function MsgConfirm:onCreate()
    self:findChildByName("msg_confirm_OK"):addClickEventListener(function ( event )
        if self._callBack then

            self._callBack()
        end
        self:onClose()
    end)
    self._bg = self:findChildByName("msg_confirm_bg")
    self._label = self:findChildByName("txt_content")
    -- self._label = cc.Label:createWithSystemFont("test","font/LexusJianHei.ttf", 20)
    -- self._label:setAnchorPoint(cc.p(0,0))
    -- self._label:setDimensions(450,400)
    -- self._label:setPosition(30,-160)
    -- self._label:setTextColor(cc.c3b(0,0,64))
    -- self._bg:addChild(self._label)
end

function MsgConfirm:onClose()
    viewMgr:closeWithObject("msgConfirm_view",self)
end

function MsgConfirm:init(msg,callBack)
	self._callBack = callBack
	self:_setMsg(msg)
end

function MsgConfirm:_setMsg(msg)
	self._label:setString(msg)
end

return MsgConfirm
