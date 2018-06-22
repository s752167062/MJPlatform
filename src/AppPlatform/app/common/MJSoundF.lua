--
-- Author: longma
-- Date: 2017-07-21
-- 用于存放麻将类玩法的音(吃 碰 杠 胡等) 请各位添加新的音效 或者修改旧的音效路径的时候到此文件中来


local MJSoundF = class("MJSoundF")
local sound_path = "audio/"
--[[
	0:女
	1:男
]]

	-- "2chi",
	-- "1chi",--吃
	-- "2peng",
	-- "1peng",--碰
	-- "2gang", 
	-- "1gang", --杠
	-- "2hu", -- 胡
	-- "1hu",
	-- "out", --出牌
	-- "huwind",
	-- "za", --飞飞 爆炸
	-- "screenShot",
	-- "loss", --结算（输）
	-- "win", --结算（赢）

--[[
	通过索引播放音效
]]
function MJSoundF:playSound(soundIndex,isLoop)
	MJSoundF:playEffect(sound_path..soundIndex..".mp3",isLoop)
end
--[[
	通过索引播放背景音乐
]]
function MJSoundF:playBackgroundMusic(musicIndex,isLoop)
	MJSoundF:stopMusic()
	MJSoundF:playMusic(sound_path..musicIndex..".mp3",isLoop)
end
--[[
	通过完整路径播放音效
]]
function MJSoundF:playEffect(path,isLoop)
	printInfo(string.format("playEffect = %s,loop = %s", path,loop))
	cc.SimpleAudioEngine:getInstance():playEffect(path, isLoop)
end
--[[
	通过完整路径播放音乐
]]
function MJSoundF:playMusic(path,isLoop)
	printInfo(string.format("playMusic = %s,loop = %s", path,loop))
	cc.SimpleAudioEngine:getInstance():playMusic(path, isLoop)
end
--[[
	播放麻将音效	
]]
function MJSoundF:playMahjongSound(path,isLoop)
	MJSoundF:playEffect(path,isLoop)
end
 --[[
	停止背景音乐
 ]]
function MJSoundF:stopMusic()
	cc.SimpleAudioEngine:getInstance():stopMusic()
end

function MJSoundF:destroyInstance()
	cc.SimpleAudioEngine:destroyInstance()
	--audio = cc.SimpleAudioEngine:getInstance()
end

function MJSoundF.stopAllSounds()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
end

return MJSoundF