local RoomNumberUI = class("RoomNumberUI",cc.load("mvc").ViewBase)

RoomNumberUI.RESOURCE_FILENAME =  __platformHomeDir .."ui/layout/OtherView/RoomNumberUI.csb"

-- function RoomNumberUI:ctor(data)
    -- self.root = display.newCSNode("RoomNumberUI.csb")
    -- self.root:addTo(self)

    -- self:registerScriptHandler(function(state)
    --     if state == "enter" then
    --         self:onEnter()
    --     elseif state == "exit" then
    --         self:onExit()
    --     elseif state == "enterTransitionFinish" then
    --     --self:onEnterTransitionFinish_()
    --     elseif state == "exitTransitionStart" then
    --     --self:onExitTransitionStart_()
    --     elseif state == "cleanup" then
    --     --self:onCleanup_()
    --     end
    -- end)

-- end
function RoomNumberUI:onCreate()
    self.clickCount = 0 --数字键点击次数
    self.number = {} --当前房间号
    self.txt_num = {} --当前房间号的控件
end    

function RoomNumberUI:onEnter()
    local ctn_close = self:findChildByName("btn_close")
    ctn_close:addClickEventListener(function() self:onUIClose() end)
    
    self.txt_num[1] = self:findChildByName("number1")
    self.txt_num[1]:setVisible(false)
    self.txt_num[2] = self:findChildByName("number2")
    self.txt_num[2]:setVisible(false)
    self.txt_num[3] = self:findChildByName("number3")
    self.txt_num[3]:setVisible(false)
    self.txt_num[4] = self:findChildByName("number4")
    self.txt_num[4]:setVisible(false)
    self.txt_num[5] = self:findChildByName("number5")
    self.txt_num[5]:setVisible(false)
    self.txt_num[6] = self:findChildByName("number6")
    self.txt_num[6]:setVisible(false)

    self.ctn_btn0 = self:findChildByName("btn0")
    self.ctn_btn0:addClickEventListener(function() self:onNumber(0) end)
    
    self.ctn_btn1 = self:findChildByName("btn1")
    self.ctn_btn1:addClickEventListener(function() self:onNumber(1) end)
    
    self.ctn_btn2 = self:findChildByName("btn2")
    self.ctn_btn2:addClickEventListener(function() self:onNumber(2) end)
    
    self.ctn_btn3 = self:findChildByName("btn3")
    self.ctn_btn3:addClickEventListener(function() self:onNumber(3) end)
    
    self.ctn_btn4 = self:findChildByName("btn4")
    self.ctn_btn4:addClickEventListener(function() self:onNumber(4) end)
    
    self.ctn_btn5 = self:findChildByName("btn5")
    self.ctn_btn5:addClickEventListener(function() self:onNumber(5) end)
    
    self.ctn_btn6 = self:findChildByName("btn6")
    self.ctn_btn6:addClickEventListener(function() self:onNumber(6) end)
    
    self.ctn_btn7 = self:findChildByName("btn7")
    self.ctn_btn7:addClickEventListener(function() self:onNumber(7) end)
    
    self.ctn_btn8 = self:findChildByName("btn8")
    self.ctn_btn8:addClickEventListener(function() self:onNumber(8) end)
    
    self.ctn_btn9 = self:findChildByName("btn9")
    self.ctn_btn9:addClickEventListener(function() self:onNumber(9) end)
    
    self.ctn_backspace = self:findChildByName("btn_backspace")
    self.ctn_backspace:addClickEventListener(function() self:onBackspace() end)

    --重置按钮
    self.ctn_reset = self:findChildByName("btn10")
    self.ctn_reset:addClickEventListener(function() self:onReset() end)
end

function RoomNumberUI:onExit()
    self:unregisterScriptHandler()
    eventMgr:removeEventListenerForTarget(self)
end

function RoomNumberUI:onUIClose()
    self:removeFromParent()
end

function RoomNumberUI:onNumber(value)
    release_print("点击数字键" .. value)
    if self.clickCount >= 6 then
        return
    end 
    self.clickCount = self.clickCount + 1
    
    self:SetRoomNumber(self.clickCount,value)
end

function RoomNumberUI:onBackspace()
    release_print("点击退格键")
    if self.clickCount < 1 then
        return
    end 
    self.txt_num[self.clickCount]:setVisible(false)
    self.clickCount = self.clickCount - 1
end

function RoomNumberUI:SetRoomNumber(index,value)
    release_print("RoomNumberUI-SetRoomNumber:index=" .. index .. ",value=" .. value)
    if index < 1 or index > 6 then
        return
    end
    self.number[index] = value
    self.txt_num[index]:setString(value)
    self.txt_num[index]:setVisible(true)
    
    if index == 6 then--请求进入房间
        cclog(">>> 请求进入游戏房间 <<<")
        local num = 0
        for i=1,6 do
            num = num*10+self.number[i]
        end
        for i=1,6 do
            self:onBackspace()
        end
        
        -- hallSendMgr:quickEnterRoom(num,true)
        externGameMgr:reqGotoGame(1, num)
    end
end


function RoomNumberUI:onReset()
    for i=1,6 do
        self:onBackspace()
    end
end

return RoomNumberUI
