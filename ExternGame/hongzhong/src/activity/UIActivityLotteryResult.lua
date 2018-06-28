local uiActivityLotteryResult = class("uiActivityLotteryResult", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityLotteryResult.RESOURCE_FILENAME = "activity2/uiActivityLotteryResult.csb"
uiActivityLotteryResult.RESOURCE_BINDING = {
    ["root"]          = {    ["varname"] = "root"              },
    ["title_got"]     = {    ["varname"] = "title_got"              },
    ["txt_tips"]      = {    ["varname"] = "txt_tips"               },
    ["txt_got"]       = {    ["varname"] = "txt_got"                },
    ["Image_8"]       = {    ["varname"] = "Image_8"                },
    ["btn_sure"]      = {    ["varname"] = "btn_sure"               ,  ["events"] = { {event = "click" ,  method ="onOK"    } }       },
}

uiActivityLotteryResult.Pox= {cc.p(-211,124) , cc.p(-106,124) , cc.p(-1,124) , cc.p(104,124) , cc.p(208,124) , cc.p(-211,-2) , cc.p(-106,-2) , cc.p(-1,-2) , cc.p(104,-2) , cc.p(208,-2) }

function uiActivityLotteryResult:onCreate()
    cclog("CREATE")
    self.callfunc = nil
end

function uiActivityLotteryResult:onEnter()
    cclog("ENTER")
end

function uiActivityLotteryResult:onExit()
    cclog("EXIT")
end

function uiActivityLotteryResult:initRes(data,func)
    if data then 
        local tyetotal = {}
        for k,v in pairs(data) do
            local itemdata = v
            if itemdata then 
                local _type = itemdata._type
                local _num = itemdata._num

                --icon
                local lotterytype = ActivityMgr.LotteryType[_type]
                local icon = lotterytype.icon
                local desc = lotterytype.desc
                local spriteFrame = display.newSpriteFrame(icon)  
                local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
                sprite:setScale(0.8)
                sprite:setPosition(cc.p(37,37))
                --item
                local itemRes = display.newCSNode("activity2/itemRes.csb")
                local txt_msg = self:getDescendantsByName(itemRes,"txt_msg")
                local res_bg  = self:getDescendantsByName(itemRes,"res_bg")
                if txt_msg then 
                    txt_msg:setString(string.format("%s X %d" , desc , _num))
                end
                if res_bg then 
                    res_bg:addChild(sprite)
                end

                --add
                if #data > 1 then 
                    itemRes:setPosition(uiActivityLotteryResult.Pox[k])
                end    
                self.root:addChild(itemRes)    
            
                --sum
                if tyetotal[_type] == nil then 
                    tyetotal[_type] = 0
                end    
                tyetotal[_type] = tyetotal[_type] + _num
            end    
        end
        
        local str = "   "
        for k,v in pairs(tyetotal) do
            local lotterytype = ActivityMgr.LotteryType[k]
            local desc = lotterytype.desc

            str = str .. string.format("%s X%d" , desc , v).. "   "
        end
        self.txt_got:setString(str)
        
        --#1
        if #data == 1 then 
            self:reSetSizeForOne()
        end    
    end    
    self.callfunc = func
end

function uiActivityLotteryResult:reSetSizeForOne()
    -- body
    self.Image_8:setContentSize(cc.size( 1022,280))
    self.title_got:setPositionY(171)
    self.btn_sure:setPositionY(-198)
    self.txt_tips:setString("")
    self.txt_got:setString("")
end

function uiActivityLotteryResult:showHeChenResult(itemdata)
    if itemdata then 
        self:reSetSizeForOne()
        self.title_got:setVisible(false)

        local _type = itemdata._type
        local _num  = itemdata._num

        --icon
        local lotterytype = ActivityMgr.LotteryType[_type]
        local icon = lotterytype.icon
        local desc = lotterytype.desc
        local spriteFrame = display.newSpriteFrame(icon)  
        local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
        sprite:setScale(0.8)
        sprite:setPosition(cc.p(37,37))
        --item
        local itemRes = display.newCSNode("activity2/itemRes.csb")
        local txt_msg = self:getDescendantsByName(itemRes,"txt_msg")
        local res_bg  = self:getDescendantsByName(itemRes,"res_bg")
        if txt_msg then 
            txt_msg:setString(string.format("%s X %d" , desc , _num))
        end
        if res_bg then 
            res_bg:addChild(sprite)
        end

        itemRes:setScale(1.2)
        self.root:addChild(itemRes)    
    end    
end

------ 按钮 -------
function uiActivityLotteryResult:onOK()
    cclog("-------onOK")
    if self.callfunc then 
    	self.callfunc()
    end	
    self:removeFromParent()
end


return uiActivityLotteryResult