--@音效管理类
--@Author 	sunfan
--@date 	2017/04/27
local AudioMgr = class("AudioMgr")
function AudioMgr:ctor(params)
    -- cc.SimpleAudioEngine:getInstance() = cc.SimpleAudioEngine:getInstance()
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(gameConfMgr:getInfo("voiceEffect"))
    cc.SimpleAudioEngine:getInstance():setMusicVolume(gameConfMgr:getInfo("voiceValue"))
end

function AudioMgr:play(name)
	-- if cc.SimpleAudioEngine:getInstance() then
	-- 	cc.SimpleAudioEngine:getInstance():playMusic("audio/"..name)
	-- end
end

function AudioMgr:playEffect(name, loop)
	-- if true then
	-- 	return
	-- end
	-- body
	name = __platformHomeDir .. "audio/" .. name

	loop = loop or false
	if cc.SimpleAudioEngine:getInstance() then
		cclog(string.format("play music name = %s,loop = %s", name,loop))
		cc.SimpleAudioEngine:getInstance():playEffect(name,loop)
	end
end

function AudioMgr:playMusic(name,loop)
	-- if true then
	-- 	return
	-- end
	name = __platformHomeDir .. "audio/" .. name
	-- body
	self:stopMusic()
	if cc.SimpleAudioEngine:getInstance() then
		cclog(string.format("play music name = %s,loop = %s", name,loop))
		cc.SimpleAudioEngine:getInstance():playMusic(name,loop)
	end
end

function AudioMgr:setEffectsVolume(value)
	if cc.SimpleAudioEngine:getInstance() then
	    cc.SimpleAudioEngine:getInstance():setEffectsVolume(value / 100.0)
	    gameConfMgr:setInfo("voiceEffect",value / 100.0)
	    gameConfMgr:writeOne("voiceEffect")
	end
end

function AudioMgr:setMusicVolume(value)
	if cc.SimpleAudioEngine:getInstance() then
	    cc.SimpleAudioEngine:getInstance():setMusicVolume(value / 100.0)
	    gameConfMgr:setInfo("voiceValue",value / 100.0)
	    gameConfMgr:writeOne("voiceValue")
	end
end

function AudioMgr:stopMusic()
	if cc.SimpleAudioEngine:getInstance() then
		cc.SimpleAudioEngine:getInstance():stopMusic()
	end
end

function AudioMgr:reInstanceAudioObj()
	platformMgr:setAVAudioSessionCategoryAndMode(0,0)
	cc.SimpleAudioEngine:destroyInstance()
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(gameConfMgr:getInfo("voiceEffect"))
    cc.SimpleAudioEngine:getInstance():setMusicVolume(gameConfMgr:getInfo("voiceValue"))
    -- cc.SimpleAudioEngine:getInstance() = cc.SimpleAudioEngine:getInstance()
end

function AudioMgr:stopAllEffects()
 	if cc.SimpleAudioEngine:getInstance() then
		cc.SimpleAudioEngine:getInstance():stopAllEffects()
	end
end

return AudioMgr