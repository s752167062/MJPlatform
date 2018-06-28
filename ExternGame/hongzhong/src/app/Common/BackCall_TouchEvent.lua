
local BackCall_TouchEvent = class("BackCall_TouchEvent",function() 
    return cc.Node:create()
end)

--通用列表panel精确点击函数
function BackCall_TouchEvent:ctor(sender, userCall, responseRange)
	self.touchCount = 0
  	self.userCall = userCall
  	if responseRange == nil then responseRange = 10 end
  	sender:addTouchEventListener(
	  	function(touch, event)
	        if event == TOUCH_EVENT_BEGAN then
	            self.touchCount = 0
	        elseif event == TOUCH_EVENT_MOVED then
	            self.touchCount = self.touchCount + 1
	        elseif event == TOUCH_EVENT_ENDED then
	            if self.touchCount < responseRange then
	                self.userCall(sender)
	            end
	        elseif event == TOUCH_EVENT_CANCELED then
	            self.touchCount = 0
	        end
	     end)

  	self:setName("BackCall_TouchEvent")
  	sender:addChild(self)
end

return BackCall_TouchEvent