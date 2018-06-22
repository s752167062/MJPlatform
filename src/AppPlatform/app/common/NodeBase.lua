
local NodeBase = class("NodeBase", cc.Node)

function NodeBase:ctor(csbFile)
    self:enableNodeEvents()
    
    -- check CSB resource file
    if csbFile then
        self:createResoueceNode(csbFile)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if csbFile and binding then
        self:createResoueceBinding(binding)
    end
    
    if self.onCreate then self:onCreate() end
end

function NodeBase:getResourceNode()
    return self.root
end

function NodeBase:createResoueceNode(resourceFilename)
    if self.root then
        self.root:removeSelf()
        self.root = nil
    end
    --这里看看要不要用 display.newCSNode 这个方法代替
    self.root = cc.CSLoader:createNode(resourceFilename)
    assert(self.root, string.format("NodeBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.root)
end

function NodeBase:createResoueceBinding(binding)
    assert(self.root, "NodeBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.root:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

function NodeBase:findChildByName(name)
    -- body
    if self.root then
        return self.root:findChildByName(name)
    end
    print("NodeBase:findChildByName: "..name.." not found!")
    return nil
end

return NodeBase
