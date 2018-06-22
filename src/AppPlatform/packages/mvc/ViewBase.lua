
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name
    
    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end
    
    if self.onCreate then self:onCreate() end
end

function ViewBase:setModel(model)
    self._model = model
end

function ViewBase:getModel()
    return self._model
end

function ViewBase:setCtrl(ctrl)
    self._ctrl = ctrl
end

function ViewBase:getCtrl()
    return self._ctrl
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:findChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            elseif event.event == "click" then
                node:addClickEventListener(handler(self,self[event.method]))       
            end
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

--[[
    递归获取指定名字的子对象，根几点为UI文件场景的节点对象
    @param name 要获取的子对象名字
    @result 如果找到，则返回第一个为指定名字的子对象
]]
function ViewBase:getUIChild(name)
    if self.resourceNode_ then
        return self:seekChild(self.resourceNode_, name)
    else
        print("Error!!!",name,"is not found!")
    end
end

--[[
    递归获取指定名字的子对象
    @param parent，要查询的容器根节点
    @param name 要获取的子对象名字
    @result 如果找到，则返回第一个为指定名字的子对象
]]
function ViewBase:seekChild(parent, name)
    if not parent then
        return
    end

    if parent:getName() == name then
        return parent
    end

    local children = parent:getChildren()
    for _, child in pairs(children) do
        local node = self:seekChild(child, name)
        if node then
            return node
        end
    end
end

function ViewBase:findChildByName(name)
    -- body
    if self.resourceNode_ == nil then
        print("Error!!! resourceNode is nil!")
        return nil
    end
    local child = self.resourceNode_:findChildByName(name)
    if child == nil then
        print("Error!!! "..name.." is not found!")
    end
    return child 
end

return ViewBase
