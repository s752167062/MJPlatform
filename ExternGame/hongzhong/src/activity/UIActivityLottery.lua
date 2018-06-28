local uiActivityLottery = class("uiActivityLottery", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityLottery.RESOURCE_FILENAME = "activity2/uiActivityLottery.csb"
uiActivityLottery.RESOURCE_BINDING = {
    ["root"]                = {    ["varname"] = "root"           },
    ["txt_fudainum"]        = {    ["varname"] = "txt_fudainum"          },
    ["image_fudai"]         = {    ["varname"] = "image_fudai"           },
    ["btn_lottery1"]        = {    ["varname"] = "btn_lottery1"                 ,  ["events"] = { {event = "click" ,  method ="onLottery1"    } }       },
    ["btn_lottery10"]       = {    ["varname"] = "btn_lottery10"                ,  ["events"] = { {event = "click" ,  method ="onLottery10"    } }       },
    ["btn_myres"]           = {    ["varname"] = "btn_myres"                    ,  ["events"] = { {event = "click" ,  method ="onMyres"    } }       },
    ["btn_close"]           = {    ["varname"] = "btn_close"                    ,  ["events"] = { {event = "click" ,  method ="onClose"    } }       },
    ["btn_closeAll"]        = {    ["varname"] = "btn_closeAll"                 ,  ["events"] = { {event = "click" ,  method ="onCloseAll"} }       },

}

function uiActivityLottery:onCreate()
    cclog("CREATE")
    self.callfunc = nil
    self.islottery = false
end

function uiActivityLottery:onEnter()
    cclog("ENTER")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:setFudaiNum(data)   end ,"GetActivityClubFudai")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:lotteryResult(data) end ,"GetActivityLottery")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:removeFromParent()  end ,"ActivitysCloseAll")
    -- CCXNotifyCenter:listen(self,function(self,obj,data) self:setFudaiNum(data)   end ,"reSetFuadiNum")

    self:checkMyFudai()
end

function uiActivityLottery:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end

function uiActivityLottery:checkMyFudai()
    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
        ActivityMgr:getActivityClubFudai(self.clubID or 0) --获取福袋数 #2222
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        ActivityMgr:getActivityClubFudaiClub(self.clubID or 0) --获取福袋数
    end
end

function uiActivityLottery:setClubData(data)
    if data then 
        self.clubID = data.clubID
    end       
end

function uiActivityLottery:setFudaiNum(fudainum)
    self.fudainum = fudainum
    self.txt_fudainum:setString(fudainum or 0)
end

function uiActivityLottery:lotteryResult(res)
    self:checkMyFudai()
    if res then 
        cclog("--- #2222 抽奖道具结果")
        print_r(res)
        self.resultres = res
    end    
end

function uiActivityLottery:showLingquAnimation()
    self.islottery = true
    self.image_fudai:setVisible(false)
    local function callfunc( ... )
        if self.resultres then 
            self.islottery = false -- 
            self.image_fudai:setVisible(true)
            local fudai_big_ani = self.root:getChildByName("fudai_big_ani")
            if fudai_big_ani then 
                fudai_big_ani:removeFromParent()
            end  

            if #self.resultres > 0 then 
                local result = ex_fileMgr:loadLua("activity.UIActivityLotteryResult").new()
                result:initRes(self.resultres)
                result:setLocalZOrder(ActivityMgr.ZOrder_UI)
                result:addTo(self:getParent())
            end    
        end    
    end

    local animate = ActivityMgr:getAnimateWithkey(nil , "image2/activity3/eff_fudai_%d.png" , 1 , 4 , 0.15)
    local spriteFrame = display.newSpriteFrame("image2/activity3/fudai_big.png")  
    local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
    sprite:runAction(cc.RepeatForever:create(cc.Sequence:create({ animate ,animate, cc.CallFunc:create(callfunc) })))
    sprite:setPosition(self.image_fudai:getPosition())
    sprite:setName("fudai_big_ani")            
    self.root:addChild(sprite)
end

------ 按钮 -------
function uiActivityLottery:onLottery1()
    if self.islottery == true then 
        cclog("重复的点击")
        return 
    end    
    self.resultres = nil
    if self.fudainum and self.fudainum >= 1 then 
        if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
            ActivityMgr:activityLottery(self.clubID ,1) --抽奖 #2222
        elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
            ActivityMgr:activityLotteryClub(self.clubID ,1) --抽奖
        end
        self:showLingquAnimation()
    else
        ActivityMgr:showToast("福袋数量不足")
    end    
end

function uiActivityLottery:onLottery10()
    if self.islottery == true  then 
        cclog("重复的点击")
        return 
    end  
    self.resultres = nil
    if self.fudainum and self.fudainum >= 10 then 
        if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
            ActivityMgr:activityLottery(self.clubID ,10) --抽奖 #2222
        elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
            ActivityMgr:activityLotteryClub(self.clubID ,10) --抽奖
        end
        self:showLingquAnimation()
    else
        ActivityMgr:showToast("福袋数量不足10个")
    end 
end

function uiActivityLottery:onClose()
	cclog("-------onClose")
    --返回前刷新下数据
    CCXNotifyCenter:notify("reCheckClubDetail")
	self:removeFromParent()
end

function uiActivityLottery:onCloseAll()
    CCXNotifyCenter:notify("ActivitysCloseAll")
end

function uiActivityLottery:onMyres()
    local myres = ex_fileMgr:loadLua("activity.UIActivityMyRes").new()
    myres:setLocalZOrder(ActivityMgr.ZOrder_UI)
    myres:setClubData({clubID = self.clubID})
    myres:addTo(self:getParent())
end

return uiActivityLottery