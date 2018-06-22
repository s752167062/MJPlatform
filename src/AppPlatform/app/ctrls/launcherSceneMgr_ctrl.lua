--更新界面管理器

local LauncherSceneMgr = class("LauncherSceneMgr")

function LauncherSceneMgr:ctor(params)
	self.manage = ""
end

function LauncherSceneMgr:setManage(mgr)
	self.manage = mgr
end

function LauncherSceneMgr:getManage()
	return self.manage
end

return LauncherSceneMgr






