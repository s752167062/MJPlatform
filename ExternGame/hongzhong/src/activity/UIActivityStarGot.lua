local uiActivityStarGot = class("uiActivityStarGot", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityStarGot.RESOURCE_FILENAME = "activity2/uiActivityStarGot.csb"
uiActivityStarGot.RESOURCE_BINDING = {
    ["btn_checkTask"]    = {    ["varname"] = "btn_checkTask"          ,  ["events"] = { {event = "click" ,  method ="onCheckTask"    } }       },
    ["btn_close"]        = {    ["varname"] = "btn_close"              ,  ["events"] = { {event = "click" ,  method ="onBack"         } }       },
    ["txt_countdown"]    = {    ["varname"] = "txt_countdown"            },
    ["txt_msg"]          = {    ["varname"] = "txt_msg"                  },
    ["txt_starmsg"]      = {    ["varname"] = "txt_starmsg"              },
    ["txt_msgallgot"]    = {    ["varname"] = "txt_msgallgot"              },

    ["image_big"]       = {    ["varname"] = "image_big"                    },
    ["image_small"]     = {    ["varname"] = "image_small"                  },
    ["titlegotstar_6"]  = {    ["varname"] = "titlegotstar_6"               },
    ["iconstar_2"]      = {    ["varname"] = "iconstar_2"                   },
    ["Text_wangcheng"]  = {    ["varname"] = "Text_wangcheng"                   },

}

function uiActivityStarGot:onCreate()
    cclog("CREATE")
end

function uiActivityStarGot:onEnter()
    cclog("ENTER")
    
    self.Interval = 6
    self.click = false
    self.lock  = false
    --时间倒计时
    local function handler(t)
        self:update(t)
    end
    self:scheduleUpdateWithPriorityLua(handler,0) 
    CCXNotifyCenter:listen(self,function(self,obj,data) self:setLock(data) end ,"ActivitysStarGotLock")   

    if ActivityMgr.gameMode == "zn" then 
        self.Text_wangcheng:setString("你在扎鸟麻将完成了")
    elseif ActivityMgr.gameMode == "hz" then 
        self.Text_wangcheng:setString("你在红中麻将完成了")
    elseif ActivityMgr.gameMode == "wmj" then 
        self.Text_wangcheng:setString("你在红中王完成了")
    end    
end

function uiActivityStarGot:onExit()
    cclog("EXIT")
    self:unregisterScriptHandler()--取消自身监听
    CCXNotifyCenter:unListenByObj(self)
end

function uiActivityStarGot:setLock(bool)
    self.lock = bool
    self:setVisible(not bool)
end

function uiActivityStarGot:setData(data)
    self.data = data 
    if data then 
        if #data < 2 then
            self:reSizeForSmall()
        end
            
        local msg = ""
        local totalscore = 0
        local index = (math.max(4- #data, 0))/2
        for k,value in pairs(data) do
            local item = ActivityMgr.RewardType[value]
            if item then
                totalscore = totalscore + item.winscore

                --添加任务描述
                local lb = cc.Label:createWithSystemFont(item.msg, "Arial", 22)
                lb:setAnchorPoint(cc.p(0,0.5))
                lb:setPosition(-200, -28 * index)
                self.txt_msg:addChild(lb)

                --添加任务描述
                local lb2 = cc.Label:createWithSystemFont("福袋X"..item.winscore, "Arial", 22)
                lb2:setAnchorPoint(cc.p(0,0.5))
                lb2:setPosition(140, -28 * index)
                self.txt_msg:addChild(lb2)

                index = index + 1
            end    
        end

        self.txt_starmsg:setString("福袋X ".. totalscore)
        self.txt_msgallgot:setString(string.format("成功获得了%d个福袋", totalscore))
    end    
end

--任务少的时候的UI位置修改
function uiActivityStarGot:reSizeForSmall()
    self.image_big:setVisible(false)
    self.image_small:setVisible(true)
    self.titlegotstar_6:setPosition(cc.p(0, 180))
    self.iconstar_2:setPosition(cc.p(-1, 75))
    self.txt_starmsg:setPosition(cc.p(0,18))
    self.Text_wangcheng:setPosition(cc.p(0,-17))
    self.txt_msgallgot:setPosition(cc.p(0,-128))
    self.btn_checkTask:setPosition(cc.p(0,-211))
end

function uiActivityStarGot:update(t)
    if self.Interval < 0 then 
        self:onCheckTask()
        return 
    end   

    if (not self.click) and (not self.lock)then 
        self.Interval = self.Interval - t
        self.txt_countdown:setString(string.format("%d", self.Interval))
    end
end

------ 按钮 -------
function uiActivityStarGot:onCheckTask()
    cclog("-------onReward")
    self.click = true
    --动画业务操作
    self:removeFromParent()
end

function uiActivityStarGot:onBack()
    cclog("-------onBack")
    self:removeFromParent()
end


return uiActivityStarGot