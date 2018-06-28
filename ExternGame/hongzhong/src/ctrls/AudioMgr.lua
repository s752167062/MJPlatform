--@音效管理类
--@Author 	sunfan
--@date 	2017/04/27

local AudioMgr = class("AudioMgr")
function AudioMgr:ctor(params)

    cc.SimpleAudioEngine:getInstance():setEffectsVolume(platformExportMgr:doGameConfMgr_getInfo("voiceEffect"))
    cc.SimpleAudioEngine:getInstance():setMusicVolume(platformExportMgr:doGameConfMgr_getInfo("voiceValue"))

    
end

function AudioMgr:play(name)
	-- if cc.SimpleAudioEngine:getInstance() then
	-- 	cc.SimpleAudioEngine:getInstance():playMusic("audio/"..name)
	-- end
end

function AudioMgr:playEffect(name, loop)
	-- body
	loop = loop or false
	if cc.SimpleAudioEngine:getInstance() then
		printInfo(string.format("AudioMgr play effect name = %s,loop = %s", name,loop))
		cc.SimpleAudioEngine:getInstance():playEffect(name,loop)
	end
end

function AudioMgr:playMusic(name,loop)
	-- body
	self:stopMusic()
	if cc.SimpleAudioEngine:getInstance() then
		printInfo(string.format("AudioMgr play music name = %s,loop = %s", name,loop))
		cc.SimpleAudioEngine:getInstance():playMusic(name,loop)
	end
end

function AudioMgr:setEffectsVolume(value)--0-100
	if cc.SimpleAudioEngine:getInstance() then
	    cc.SimpleAudioEngine:getInstance():setEffectsVolume(value/100)
	    platformExportMgr:doGameConfMgr_setInfo("voiceEffect",value/ 100)
	    platformExportMgr:doGameConfMgr_writeOne("voiceEffect")
	end
end

function AudioMgr:setMusicVolume(value)--0-100
	if cc.SimpleAudioEngine:getInstance() then
	    cc.SimpleAudioEngine:getInstance():setMusicVolume(value/100)
	    platformExportMgr:doGameConfMgr_setInfo("voiceValue",value/ 100)
	    platformExportMgr:doGameConfMgr_writeOne("voiceValue")
	end
end

function AudioMgr:stopMusic()
	if cc.SimpleAudioEngine:getInstance() then
		cc.SimpleAudioEngine:getInstance():stopMusic()
	end
end

function AudioMgr:reInstanceAudioObj()
	platformExportMgr:setAVAudioSessionCategoryAndMode(0,0)
	-- AudioMgr:destroyInstance()
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(platformExportMgr:doGameConfMgr_getInfo("voiceEffect"))
    cc.SimpleAudioEngine:getInstance():setMusicVolume(platformExportMgr:doGameConfMgr_getInfo("voiceValue"))
 --    cc.SimpleAudioEngine:getInstance() = cc.SimpleAudioEngine:getInstance()
end

function AudioMgr:stopAllEffects()
 	if cc.SimpleAudioEngine:getInstance() then
		cc.SimpleAudioEngine:getInstance():stopAllEffects()
	end
end

function AudioMgr:getEffectsVolume()
	-- body

end

function AudioMgr:getMusicVolume()
	-- body
	
end

function AudioMgr:pauseMusic()
	-- body
	cc.SimpleAudioEngine:getInstance():pauseMusic()
end

function AudioMgr:pauseAllEffects()
	-- body
	cc.SimpleAudioEngine:getInstance():pauseAllEffects()
end

function AudioMgr:resumeMusic()
	-- body
	cc.SimpleAudioEngine:getInstance():resumeMusic()
end

function AudioMgr:resumeAllEffects()
	-- body
	cc.SimpleAudioEngine:getInstance():resumeAllEffects()
end

function AudioMgr:destroyInstance()
	-- body
	-- cc.SimpleAudioEngine:destroyInstance()
end

return AudioMgr