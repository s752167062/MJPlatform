local uiActivityMyRes = class("uiActivityMyRes", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityMyRes.RESOURCE_FILENAME = "activity2/uiActivityMyRes.csb"
uiActivityMyRes.RESOURCE_BINDING = {
    ["root"]            = {    ["varname"] = "root"              },
    ["txt_hongbao"]     = {    ["varname"] = "txt_hongbao"              },
    ["txt_fudan"]       = {    ["varname"] = "txt_fudan"                },
    ["txt_fangka"]      = {    ["varname"] = "txt_fangka"               },
    ["txt_xin"]         = {    ["varname"] = "txt_xin"                  },
    ["txt_cun"]         = {    ["varname"] = "txt_cun"                  },
    ["txt_zhu"]         = {    ["varname"] = "txt_zhu"                  },
    ["txt_fu"]          = {    ["varname"] = "txt_fu"                   },


    ["btn_lingquhongbao"]   = {    ["varname"] = "btn_lingquhongbao"            ,  ["events"] = { {event = "click" ,  method ="onLingquHongBao"     } }       },
    ["btn_hongbao"]         = {    ["varname"] = "btn_hongbao"                  ,  ["events"] = { {event = "click" ,  method ="onHongBao"           } }       },
    ["btn_fangka"]          = {    ["varname"] = "btn_fangka"                   ,  ["events"] = { {event = "click" ,  method ="onFangKa"            } }       },
    ["btn_close"]           = {    ["varname"] = "btn_close"                    ,  ["events"] = { {event = "click" ,  method ="onClose"             } }       },
    ["btn_closeAll"]        = {    ["varname"] = "btn_closeAll"                 ,  ["events"] = { {event = "click" ,  method ="onCloseAll"          } }       },
}

function uiActivityMyRes:onCreate()
    cclog("CREATE")
    self.callfunc = nil
    self.islingqu = false
end

function uiActivityMyRes:onEnter()
    cclog("ENTER")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:setMyRes(data)     end ,"GetActivityMyRes")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:reSetResFangka(data)   end, "ActivityChangeCards")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:reSetResZhuFu(data)    end, "ActivityChangeHongbao")
    CCXNotifyCenter:listen(self,function(self,obj,data) self:removeFromParent() end ,"ActivitysCloseAll")

    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
        ActivityMgr:getActivityMyRes(self.clubID or 0) --获取道具列表 #2222
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        ActivityMgr:getActivityMyResClub(self.clubID or 0) --获取道具列表
    end

    --领取状态check
    if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_REWARD then
        self.btn_lingquhongbao:setVisible(true)
        self.btn_fangka:setVisible(true)
        self.btn_hongbao:setVisible(false)
    end    
end

function uiActivityMyRes:onExit()
    cclog("EXIT")
    CCXNotifyCenter:unListenByObj(self)
end

function uiActivityMyRes:setClubData(data)
    if data then 
        cclog("----#2222 res clubID",data.clubID)
        self.clubID = data.clubID
    end    
end

function uiActivityMyRes:setMyRes(res)
    if res then 
        cclog("-- #2222 我的道具") 
        -- print_r(res)
        for k,v in pairs(res) do
            local _type = v._type
            local _num  = v._num

            local lotterytype = ActivityMgr.LotteryType[_type]
            self[lotterytype.txt]:setString(_num)
        end
    end
end

function uiActivityMyRes:reSetResFangka(num)
    self.islingqu = false
    self.txt_fangka:setString(0)
end

function uiActivityMyRes:reSetResZhuFu(res)
    dump("#2222 重置文字道具")
    print_r(res)
    self.resultres = res
end

function uiActivityMyRes:showHeChengAnimation()
    local function callfunc( ... )
        if self.resultres then 
            self.islingqu  = false
            local eff_light_ani = self:getChildByName("eff_light_ani")
            if eff_light_ani then 
                eff_light_ani:removeFromParent()
            end  

            for i=1,4 do
                local boundani = self.root:getChildByName("bound_ani"..i)
                if boundani then 
                    boundani:removeFromParent()
                end
            end
            if #self.resultres > 0 then 
                local result = ex_fileMgr:loadLua("activity.UIActivityLotteryResult").new()
                result:showHeChenResult({ _type = 500 ,_num = 1 })
                result:setLocalZOrder(ActivityMgr.ZOrder_UI)
                result:addTo(self:getParent())
            end   

            --重新设置数量
            for k,v in pairs(self.resultres) do
                local _type = v._type
                local _num  = v._num

                local lotterytype = ActivityMgr.LotteryType[_type]
                self[lotterytype.txt]:setString(_num)
            end    
        end    
    end

    --big
    local animate = ActivityMgr:getAnimateWithkey(nil , "image2/activity3/eff_light_%d.png" , 1 , 5 , 0.2)
    local spriteFrame = display.newSpriteFrame("image2/activity3/eff_light_1.png")  
    local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
    sprite:setPosition(cc.p(568 , 320))

    --bound1
    local animate1 = ActivityMgr:getAnimateWithkey(nil , "image2/activity3/bound_%d.png" , 1 , 4 , 0.2)    
    local spriteFrame1 = display.newSpriteFrame("image2/activity3/bound_1.png")  
    local bound1 = cc.Sprite:createWithSpriteFrame(spriteFrame1) 
    bound1:setPosition(cc.p(-269 , -7))
    bound1:setName("bound_ani1")

    local animate2 = ActivityMgr:getAnimateWithkey(nil , "image2/activity3/bound_%d.png" , 1 , 4 , 0.2)
    local spriteFrame2 = display.newSpriteFrame("image2/activity3/bound_1.png")  
    local bound2 = cc.Sprite:createWithSpriteFrame(spriteFrame2) 
    bound2:setPosition(cc.p(-96 , -7))
    bound2:setName("bound_ani2")

    local animate3 = ActivityMgr:getAnimateWithkey(nil , "image2/activity3/bound_%d.png" , 1 , 4 , 0.2)
    local spriteFrame3 = display.newSpriteFrame("image2/activity3/bound_1.png")  
    local bound3 = cc.Sprite:createWithSpriteFrame(spriteFrame3) 
    bound3:setPosition(cc.p(77 , -7))
    bound3:setName("bound_ani3")

    local animate4 = ActivityMgr:getAnimateWithkey(nil , "image2/activity3/bound_%d.png" , 1 , 4 , 0.2)
    local spriteFrame4 = display.newSpriteFrame("image2/activity3/bound_1.png")  
    local bound4 = cc.Sprite:createWithSpriteFrame(spriteFrame4) 
    bound4:setPosition(cc.p(251 , -7))
    bound4:setName("bound_ani4")

    sprite:runAction(cc.RepeatForever:create(cc.Sequence:create({ animate , cc.CallFunc:create(callfunc) })))
    sprite:setName("eff_light_ani")            
    self:addChild(sprite)

    bound1:runAction(cc.RepeatForever:create(animate1))
    bound2:runAction(cc.RepeatForever:create(animate2))
    bound3:runAction(cc.RepeatForever:create(animate3))
    bound4:runAction(cc.RepeatForever:create(animate4))
    self.root:addChild(bound1)
    self.root:addChild(bound2)
    self.root:addChild(bound3)
    self.root:addChild(bound4)
end

------ 按钮 -------
function uiActivityMyRes:onHongBao()
    cclog("-------onHongBao")
    if self.islingqu == true then
        cclog("重复点击")
        return
    end    
    local num_xin = tonumber(self.txt_xin:getString() or 0) or 0 
    local num_cun = tonumber(self.txt_cun:getString() or 0) or 0
    local num_zhu = tonumber(self.txt_zhu:getString() or 0) or 0 
    local num_fu = tonumber(self.txt_fu:getString() or 0) or 0
    if num_xin == 0 or num_cun == 0 or num_zhu ==0 or num_fu ==0 then 
        ActivityMgr:showToast("请先集齐 '新' '春' '筑' '福' 四个字样")
        return
    end    
    self.resultres = nil
    self:showHeChengAnimation()

    self.islingqu = true
    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
        ActivityMgr:activityChangeHongbao(self.clubID or 0) --兑换红包 #2222
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        ActivityMgr:activityChangeHongbaoClub(self.clubID or 0) --兑换红包
    end
end

function uiActivityMyRes:onFangKa()
    cclog("-------onFangKa")
    if self.islingqu == true then
        cclog("重复点击")
        return
    end 

    self.islingqu = true
    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
        ActivityMgr:activityChangeCards(self.clubID or 0) --兑换房卡 #2222
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        ActivityMgr:activityChangeCardsClub(self.clubID or 0) --兑换房卡
    end
end

function uiActivityMyRes:onLingquHongBao()
    cclog("-------onLingquHongBao")
    local num = tonumber(self.txt_hongbao:getString() or 0) or 0
    if num > 0 then 
        local activitycash = ex_fileMgr:loadLua("activity.UIActivityRewardCash_xczf").new()
        activitycash:setLocalZOrder(ActivityMgr.ZOrder_UI)
        activitycash:setItemData(num * 888)
        activitycash:addTo(self:getParent());
    else
        ActivityMgr:showToast("没有可领取的红包")
    end    
end

function uiActivityMyRes:onClose()
	cclog("-------onClose")
	self:removeFromParent()
end

function uiActivityMyRes:onCloseAll()
    CCXNotifyCenter:notify("ActivitysCloseAll")
end

return uiActivityMyRes