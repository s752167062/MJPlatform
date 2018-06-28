local CUIConnectMSG = class("CUIConnectMSG",function() return cc.Node:create() end)

function CUIConnectMSG:ctor()
    self.root = display.newCSNode("common/CUIConnectMSG.csb")
    self.root:addTo(self)
end


function CUIConnectMSG:setInfoString(str)
    cclog("**** set string ****" ..str)
    local txtinfo = self.root:getChildByName("ctn_win"):getChildByName("txt_info")
    txtinfo:setString(str)
    local size = txtinfo:getVirtualRendererSize()

    local ui_notice_bg = self.root:getChildByName("ctn_win"):getChildByName("ui_notice_bg")
    ui_notice_bg:setScale9Enabled(true)
    local tmp = ui_notice_bg:getContentSize()
    ui_notice_bg:setContentSize(size.width +30, tmp.height)
end

function CUIConnectMSG:getInfoString()
    local txtinfo = self.root:getChildByName("ctn_win"):getChildByName("txt_info")
    return txtinfo:getString()
end

return CUIConnectMSG
