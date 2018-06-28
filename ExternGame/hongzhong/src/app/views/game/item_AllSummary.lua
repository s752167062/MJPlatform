local item_AllSummary = class("item_AllSummary",function() 
    return cc.Node:create()
end)

function item_AllSummary:ctor(data,flag,index,isMatch)
    self.root = display.newCSNode("game/item_AllSummary2.csb")
    self.root:addTo(self)
    
    self.root:getChildByName("img_holder"):setVisible(GlobalData.roomCreateID == data.playerID and  isMatch ~= true)
    
    self.root:getChildByName("bg_1"):setVisible(data.bigwin)
    self.root:getChildByName("bg_2"):setVisible(not data.bigwin)
    
    self.root:getChildByName("ctn_info"):getChildByName("txt_name"):setString(data.name)
    self.root:getChildByName("ctn_info"):getChildByName("txt_id"):setString(string.format("ID:%06d",data.playerID))
    
    self.root:getChildByName("txt_hu"):setString(data.hpcnt)
    self.root:getChildByName("txt_gg"):setString(data.mgcnt)
    self.root:getChildByName("txt_ag"):setString(data.agcnt)
    self.root:getChildByName("txt_zm"):setString(data.zmcnt)
    
    if data.score > 0 then
        self.root:getChildByName("txt_score_win"):setString(string.format("+%d",data.score))
        self.root:getChildByName("txt_score_lose"):setVisible(false)
    else
        self.root:getChildByName("txt_score_lose"):setString(string.format("%d",data.score))
        self.root:getChildByName("txt_score_win"):setVisible(false)
    end
    
    self:setWinVisible(data.bigwin)
    self:setIcon(data)
end

function item_AllSummary:setIcon(data)
    local filename = data.playerID .."icon.png"
    local path = ex_fileMgr:getWritablePath().."/".. filename
    
    local icon = self.root:getChildByName("ctn_info"):getChildByName("icon_bg")
    local headsp = cc.Sprite:create(path)
    if headsp == nil then
    	cc.Director:getInstance():getTextureCache():reloadTexture(path)
    	headsp = cc.Sprite:create(path)
    	if headsp == nil then
    		return 
    	end
    end
    
    -- headsp:setAnchorPoint(cc.p(0,0))
    -- local baseicon = icon:getChildByName("baseicon")
    -- local Basesize = baseicon:getContentSize()
    -- local Tsize = headsp:getContentSize()
    -- headsp:setScale(Basesize.width * baseicon:getScale() / Tsize.width ,Basesize.height * baseicon:getScale() / Tsize.height)
    GlobalFun:modifyAddNewIcon(icon, headsp, 10, 10, "baseicon")
    icon:addChild(headsp) 
end

function item_AllSummary:setWinVisible(b)
    --self.root:getChildByName("game_win"):setVisible(b)
end

return item_AllSummary