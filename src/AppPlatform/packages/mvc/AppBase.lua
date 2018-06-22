
local AppBase = class("AppBase")

function AppBase:ctor(configs)
    self.configs_ = {
        viewsRoot  = "app.views",
        modelsRoot = "app.models",
        ctrlsRoot = "app.ctrls",
        defaultSceneName = "LogoScene",
    }

    for k, v in pairs(configs or {}) do
        self.configs_[k] = v
    end

    if type(self.configs_.viewsRoot) ~= "table" then
        self.configs_.viewsRoot = {self.configs_.viewsRoot}
    end
    if type(self.configs_.modelsRoot) ~= "table" then
        self.configs_.modelsRoot = {self.configs_.modelsRoot}
    end
    if type(self.configs_.ctrlsRoot) ~= "table" then
        self.configs_.ctrlsRoot = {self.configs_.ctrlsRoot}
    end

    if DEBUG > 1 then
        dump(self.configs_, "AppBase configs")
    end

    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end

    -- event
    self:onCreate()
end

function AppBase:run(initSceneName)
    initSceneName = initSceneName or self.configs_.defaultSceneName
    self:enterScene(initSceneName)
end

--@enterScene场景，参数是table
--sceneName
--viewsRoot
--transition
--time
--more
--dirType：0分开三个目录查找ctrl，model ；1同一目录下查找ctrl，model
function AppBase:enterScene(data)
    local sceneName = data.sceneName
    local viewsRoot = data.viewsRoot
    local dirType = data.dirType and data.dirType or 0
    local transition = data.transition
    local time = data.time
    local more = data.more

    local view = self:createView(sceneName,viewsRoot)
    if dirType == 1 then
        view:setModel(self:createModel(sceneName,viewsRoot))
        view:setCtrl(self:createCtrl(sceneName,viewsRoot))
    else
        view:setModel(self:createModel(sceneName))
        view:setCtrl(self:createCtrl(sceneName))
    end
    view:showWithScene(transition, time, more)
    viewMgr:setScene(view)
    return view
end

function AppBase:createView(name, viewsRoot)
    local views_root = self.configs_.viewsRoot
    if viewsRoot then
        views_root = {viewsRoot}
    end
    for _, root in ipairs(views_root) do
        local packageName = string.format("%s.%s", root, name)
        local status, view = xpcall(function()
                return require(packageName)
            end, function(msg)
            if not string.find(msg, string.format("'%s' not found:", packageName)) then
                print("load view error: ", msg)
            end
        end)
        local t = type(view)
        if status and (t == "table" or t == "userdata") then
            return view:create(self, name)
        end
    end

    error(string.format("AppBase:createView() - not found view \"%s\" in search paths \"%s\"",
        name, table.concat(views_root, ",")), 0)
end

function AppBase:createCtrl(name, ctrlsRoot)
    local ctrls_root = self.configs_.ctrlsRoot
    if ctrlsRoot then
        ctrls_root = {ctrlsRoot}
    end
    local ctrlName = string.sub(name, 1, string.find(name,"_")).."ctrl"
    for _, root in ipairs(ctrls_root) do
        local packageName = string.format("%s.%s", root, ctrlName)
        local status, ctrl = xpcall(function()
                return require(packageName)
            end, function(msg)
                print("###"..name.." createCtrl not find "..ctrlName.."###")
        end)
        local t = type(ctrl)
        if status and (t == "table" or t == "userdata") then
            return ctrl:new()
        end
    end
    return nil
end

function AppBase:createModel(name, modelsRoot)
    local models_root = self.configs_.modelsRoot
    if modelsRoot then
        models_root = {modelsRoot}
    end
    local modelName = string.sub(name, 1, string.find(name,"_")).."model"
    for _, root in ipairs(models_root) do
        local packageName = string.format("%s.%s", root, modelName)
        local status, model = xpcall(function()
                return require(packageName)
            end, function(msg)
                print("###"..name.." createModel not find "..modelName.."###")
        end)
        local t = type(model)
        if status and (t == "table" or t == "userdata") then
            return model:new()
        end
    end
    return nil
end

function AppBase:onCreate()
end

return AppBase
