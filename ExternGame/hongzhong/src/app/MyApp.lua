
local MyApp = class("MyApp", ex_fileMgr:loadLua("packages.mvc.AppBase"))

function MyApp:onCreate()
    math.randomseed(os.time())
end

return MyApp
