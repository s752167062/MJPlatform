--
-- Author: longma
-- Date: 2017-07-20
-- 帧管理
local MJEffectF = class("MJEffectF",require("app.common.EffectBase"))

function MJEffectF:ctor(params,callBack)
    self.super.ctor(self,params)
    self:runAni(params.csb,params.acname,params.isloop,params.callfunc,params.args,callBack)
end

function MJEffectF:runAni(path,name , isloop , callfunc,args,callBack) 
    self.callfunc = callfunc
    
    local action = cc.CSLoader:createTimeline(path)
    action:play(name,isloop)
    action:setFrameEventCallFunc(function(frame ,event) 
        if frame:getEvent() == "over" then
            if self.callfunc then 
                callfunc() 
            end 
            if self:getResourceNode() then
                self:getResourceNode():stopAllActions()
                self:removeFromParent()
            end
        end

        if frame:getEvent() == "showpaixin" then
            if self:getResourceNode() and callBack then
	            callBack(args)
            end
        end
    end)

    self:getResourceNode():runAction(action)
end


return MJEffectF