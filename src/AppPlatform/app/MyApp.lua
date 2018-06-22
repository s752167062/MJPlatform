
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    -- math.randomseed(os.time())
    math.randomseed(tostring(os.time()):reverse():sub(1,6))
end

return MyApp
