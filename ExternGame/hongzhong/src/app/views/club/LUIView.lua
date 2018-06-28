

local LUIView = class("LUIView", function() 
   return cc.Node:create()
end)

function LUIView:ctor()
    cpp_log("wtf LUIView:ctor")
    self:enableNodeEvents()

	self._childW = self:loadChildrenWidget(self.root, nil, true)
	self._btnLockFlag = false
end	

function LUIView:create()
	return LUIView.new()
end

--获取子控件table
function LUIView:loadChildrenWidget(_node, _childrenTable, _flag)
	local function func(node, childrenTable)
		if node ~= nil and node:getChildrenCount() <= 0 then return end
		local cTable = node:getChildren()
--		cpp_log("cTable size:"..(#cTable))
		for i, v in ipairs(cTable) do
			childrenTable[v:getName()] = v
			func(v, childrenTable)

			if _flag == true then
				if v:getDescription() == "Button" then
					v:addClickEventListener(function() 
						if self:isLockedBtn() == true then
							self:onClick(v) 
						end
					end)
					v:addTouchEventListener(function(sender, type) self:onTouch(sender, type) end)
				elseif v:getDescription() == "ImageView" then
					v:addClickEventListener(function() 
						if self:isLockedBtn() == true then
							self:onClick(v) 
						end
					end)
					v:addTouchEventListener(function(sender, type) self:onTouch(sender, type) end)
				elseif v:getDescription() == "Layout" then
					v:addTouchEventListener(function(sender, type) self:onTouch(sender, type) end)	
				elseif v:getDescription() == "ListView" then
					v:addTouchEventListener(function(sender, type) self:onTouch(sender, type) end)
					--v:addEventListener(function(sender, type) self:onListViewEvent(sender, type) end)
				elseif v:getDescription() == "CheckBox" then
					v:addClickEventListener(function(sender, type) self:onClick(sender, type) end)
					v:addTouchEventListener(function(sender, type) self:onTouch(sender, type) end)
				end	
			end	
		end
	end
	if _childrenTable == nil then _childrenTable = {} end
		func(_node, _childrenTable)
	return _childrenTable
end

function LUIView:getTbSize(_tb)
	local num = 0
	if _tb ~= nil then
		for i, v in pairs(_tb) do
			num = num + 1
		end
	end
	return num
end	

function LUIView:copyTable(_t1, _t2)
	local function func(t1, t2)
		for key, var in pairs(t1) do
			if type(var) == "table" then
				t2[key] = {}
				func(var, t2[key])
			else	
				t2[key] = var
			end
		end
	end
	if _t2 == nil then _t2 = {} end
	func(_t1, _t2)
	return _t2
end

--计算字符个数
function LUIView:utf8len(input)  
    local len  = string.len(input)  
    local left = len  
    local cnt  = 0  
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}  
    while left ~= 0 do  
        local tmp = string.byte(input, -left)  
        local i   = #arr  
        while arr[i] do  
            if tmp >= arr[i] then  
                left = left - i  
                break  
            end  
            i = i - 1  
        end  
        cnt = cnt + 1  
    end  
    return cnt  
end

function LUIView:closeUI()
	self:removeFromParent()
end	

--锁按钮
function LUIView:isLockedBtn()
	if self._btnLockFlag == false then
		self._btnLockFlag = true
		local callFunc = function()
			self._btnLockFlag = false
			cclog("test btn DelayTime")
		end
		local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(callFunc))
		self:runAction(action)
		return true
	end 
	return false
end

function LUIView:onTouch(_sender, _type)
	
end

function LUIView:onClick(_sender, _type)
	
end

return LUIView

