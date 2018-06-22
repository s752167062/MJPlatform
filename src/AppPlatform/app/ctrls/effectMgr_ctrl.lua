--@特效管理类
--@Author 	sunfan
--@date 	2017/05/20
local EffectMgr = class("EffectMgr")

EFFECT_TYPE = {
    NODE = 0,--节点特效
    VIEW = 1,--场景特效   
}

EFFECT_STATE = {
    NODE = 0,
    START = 1,
    RUN = 2,
    FINISH = 3,
    CLEAR = 4,
}

function EffectMgr:ctor(params)
	self._effects = {}
	self._addEffects = {}
	timerMgr:register(self)
end

function EffectMgr:update(dt)
	self:_addEffect()
	local tempEffects = {}
	for k,v in pairs(self._effects) do
		if v then
			local temp = {}
			for loop = 1,#v do
				if v[loop] then
					if v[loop].getState and v[loop]:getState() == EFFECT_STATE.CLEAR then
						v[loop]:removeFromParent()
					else
						if v[loop].update then
							v[loop]:update(dt)
						end
						temp[#temp + 1] = v[loop]						
					end
				end
			end
			tempEffects[k] = temp
		end		
	end
	self._effects = tempEffects
end

function EffectMgr:_addEffect()
	if #self._addEffects <= 0 then
		return
	end
	for loop = 1,#self._addEffects do
		if self._addEffects[loop] then
			local target = self._addEffects[loop]:getTarget()
			if not self._effects[target] then
				self._effects[target] = {}
			end
			self._effects[target][#self._effects[target] + 1] = self._addEffects[loop]
		end
	end
	self._addEffects = {}
end

--@		effect 	特效对象
--@		target	目标
--@		node 	是否指定了挂接节点,nil:未指定将加入场景
function EffectMgr:playEffect(effect, node)
	if node then
		self._addEffects[#self._addEffects + 1] = effect
		node:addChild(effect)
		effect:setState(EFFECT_STATE.START)
	else
		if viewMgr:addEffect(effect) then
			self._addEffects[#self._addEffects + 1] = effect
			effect:setState(EFFECT_STATE.START)
		end
	end
end

--@ 删除指定特效
function EffectMgr:removeEffect(effect)
	if effect then
		effect:setState(EFFECT_STATE.CLEAR)
	end
end

--@删除同一目标特效(下一帧释放，注意时机)
function EffectMgr:removeEffectWithTarget( target )
	-- body
	if self._effects[target] then
		print("removeEffectWithTarget num = "..#self._effects[target])
		for loop = 1,#self._effects[target] do
			if self._effects[target][loop] then
				print("//////////===========>>>remove Effect",loop)
				self._effects[target][loop]:stopAllActions()
				self._effects[target][loop]:setState(EFFECT_STATE.CLEAR)
			end
		end
	end
end

--@删除同一目标特效(立即释放，注意时机)
function EffectMgr:removeEffectWithTargetImmediately(target)
	if self._addEffects and #self._addEffects > 0 then
		local temp = {}
		for loop = 1,#self._addEffects do
			if self._addEffects[loop] then
				if self._addEffects[loop]:getTarget() == target then
					print("//////////===========>>>remove Effect add",loop)
					self._addEffects[loop]:stopAllActions()
					self._addEffects[loop]:setState(EFFECT_STATE.CLEAR)
					self._addEffects[loop]:removeFromParent()
					self._addEffects[loop] = nil
				else
					temp[#temp + 1] = self._addEffects[loop]
				end
			end
		end
		self._addEffects = temp
	end
	if self._effects[target] then
		print("removeEffectWithTargetImmediately num = "..#self._effects[target])
		for loop = 1,#self._effects[target] do
			if self._effects[target][loop] then
				print("//////////===========>>>remove Effect",loop)
				self._effects[target][loop]:stopAllActions()
				self._effects[target][loop]:setState(EFFECT_STATE.CLEAR)
				self._effects[target][loop]:removeFromParent()
				self._effects[target][loop] = nil
			end
		end
	end
end


--@删除所有无回调特效
function EffectMgr:removeAllNoCallBackEffect()
	for k,v in pairs(self._effects) do
		if v then
			if self._effects[k] and  self._effects[k][1] then
				local effect = self._effects[k][1]
				if not effect._callback then
					print("//////////===========>>>remove Effect",k)
					self:removeEffectWithTarget(k)
				end
			end
		end
	end
end

function EffectMgr:removeAllEffect()
	print("removeAllEffect num = "..#self._effects)
	for k,v in pairs(self._effects) do
		if v then
			if self._effects[k] and  self._effects[k][1] then
				local effect = self._effects[k][1]
				if  effect._callback then
					effect._callback = nil
				end
				self:removeEffectWithTarget(k)
			end
		end
	end
end

return EffectMgr