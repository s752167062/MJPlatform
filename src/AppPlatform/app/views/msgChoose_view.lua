--@信息提示(选择框)
--@Author   sunfan
--@date     2017/06/13
local MsgChoose = class("MsgChoose",cc.load("mvc").ViewBase)

MsgChoose.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/MessageChoose.csb"

function MsgChoose:onCreate()
    self.btn_close = self:findChildByName("msg_close")
    self.btn_close:onClick(function ( event )
        if self.close_callBack then
            self.close_callBack()
        end
        self:onClose()
    end)
    self:getUIChild("msg_left"):onClick(function ( event )
        if self.l_callBack then
        	self.l_callBack()
        end
        self:onClose()
    end)
    self:getUIChild("msg_right"):onClick(function ( event )
        if self.r_callBack then
        	self.r_callBack()
        end
        self:onClose()
    end)

    self._right_btn_txt = self:findChildByName("msg_text_right")
    self._left_btn_txt = self:findChildByName("msg_text_left")
    self._bg = self:getUIChild("msg_bg")
    self._label = self:findChildByName("txt_content")

    -- self._label = cc.Label:createWithSystemFont("test","font/LexusJianHei.ttf", 20)
    -- self._label:setAnchorPoint(cc.p(0,0))
    -- self._label:setDimensions(450,400)
    -- self._label:setPosition(30,-160)
    -- self._label:setTextColor(cc.c3b(0,0,64))
    -- self._bg:addChild(self._label)
end

function MsgChoose:onClose()
    viewMgr:closeWithObject("msgChoose_view",self)
end

function MsgChoose:init(msg,l_callBack,r_callBack, l_btnTxt, r_btnTxt, close_callBack, showClose)
	self.l_callBack = l_callBack
	self.r_callBack = r_callBack
    self.close_callBack = close_callBack

    if showClose ~= nil then
        self.btn_close:setVisible(showClose)
        dump(showClose,"@@@lpx")
    end

    self._left_btn_txt:setString(l_btnTxt or msgMgr:getMsg("SURE"))
    self._right_btn_txt:setString(r_btnTxt or msgMgr:getMsg("CANCEL"))
	self:_setMsg(msg)
end

function MsgChoose:get_left_btn_txt()
    return self._left_btn_txt
end

function MsgChoose:get_right_btn_txt()
    return self._right_btn_txt
end

function MsgChoose:_setMsg(msg)
	self._label:setString(msg)
end

return MsgChoose
