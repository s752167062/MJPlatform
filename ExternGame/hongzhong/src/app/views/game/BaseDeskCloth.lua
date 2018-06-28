local BaseDeskCloth = class("BaseDeskCloth",function() 
    return cc.Node:create()
end)

function BaseDeskCloth:ctor(csbfile,baseNode)
    self.root = display.newCSNode(csbfile)
    self.root:addTo(self)
    local bg = self.root:getChildByName("deskbg")
    local bg_size = bg:getContentSize()
    local sx = bg_size.width/display.width
    local sy = bg_size.height/display.height

    bg:setScale(1.0/sx,1.0/sy)
    --[[
    if bg_size.width < display.width or bg_size.height < display.height then
        
        if sx > sy then
            sx = sy
        end
    end
    ]]
    baseNode:addChild(self)
    self.bg = bg
    local function changeMode(mode)
        if mode == AOVMgr._2D then
            self.bg:loadTexture("image/desk_bg1.jpg")
        elseif mode == AOVMgr._2_5D then
            self.bg:loadTexture("image/desk_bg2.jpg")
        end
    end
    changeMode(AOVMgr:getGameMode())
    CCXNotifyCenter:listen(self, function(self,obj,data) changeMode(data.newMode) end, "ModeHasChange")
    
end

return BaseDeskCloth