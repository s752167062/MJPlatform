local EffectBase = class("EffectBase", require("app.common.NodeBase"))

function EffectBase:ctor(params)
    EffectBase.super.ctor(self, params.csb)

    self._state  = EFFECT_STATE.NONE
    self._type   = params.type or EFFECT_TYPE.NODE 
    self._target = params.target
    self._csb    = params.csb
end

function EffectBase:getTarget()
    -- body
    return self._target
end

function EffectBase:setTarget(target)
    -- body
    self._target = target
end

function EffectBase:getState()
    -- body
    return self._state
end

function EffectBase:setState(state)
    -- body
    self._state = state
end
return EffectBase
