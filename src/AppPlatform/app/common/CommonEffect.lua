local CommonEffect = class( "CommonEffect", require("app.common.EffectBase"))

function CommonEffect:ctor(params)
    dump(params, "CommonEffect params")
    CommonEffect.super.ctor(self, params)

    self._acname 	= params.acname or "a1"
    self._loop		= params.loop or true
    self._callback	= params.call
    self._interval 	= 0
    self._time 		= params.time or 0
    self._delay 	= params.delay or 0
    self:setVisible(false)
end

function CommonEffect:update(t)

	if self:getState() == EFFECT_STATE.NONE then

	elseif self:getState() == EFFECT_STATE.START then
		self._interval = self._interval + t
		if self._interval >= self._delay then
			self._interval = 0
			self:play()
		end
	elseif self:getState() == EFFECT_STATE.RUN then
--		self._interval = self._interval + t
--		if self._interval >= self._time then
--			self._interval = 0
--			self:setState(EFFECT_STATE.FINISH)
--		end
	elseif self:getState() == EFFECT_STATE.FINISH then
		if self._callback then
			self._callback()
		end
		self:setState(EFFECT_STATE.CLEAR)

	elseif self:getState() == EFFECT_STATE.CLEAR then

	end
end

function CommonEffect:play()
	-- body
	local action = cc.CSLoader:createTimeline(self._csb)
    action:play(self._acname,self._loop)
    self:runAction(action)
    self:setState(EFFECT_STATE.RUN)
    self:setVisible(true)
end

return CommonEffect