local CUIAffiche = class("CUIAffiche", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

PDKGame.RESOURCE_FILENAME = "CUIAffiche.csb"
PDKGame.RESOURCE_BINDING = {
    ["txt_content"]        = {    ["varname"] = "txt_content"         },
    ["btn_close"]        = {    ["varname"] = "btn_close"       ,  ["events"] = { {event = "click" ,  method ="onBack" } } }
    
}

function CUIAffiche:onCreate()

end

function CUIAffiche:setContent(txt)
    self.txt_content:setString(txt)
end

function CUIAffiche:onEnter()
    
end

function CUIAffiche:onBack()
    self:removeFromParent()
end

function CUIAffiche:onExit()

end

return CUIAffiche