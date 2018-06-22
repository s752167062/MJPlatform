--@语音管理类
--@Author 	liangpx
--@date 	2017/6/26
local VoiceMgr = class("VoiceMgr")
function VoiceMgr:ctor(params)
	self.speakVoiceCount = 0
    self.speakVoiceListener = {}
    self.speakVoiceNameList = {}
    self.speakVoice_time = 0
    self.speakVoiceIsEnd = 0
    self.isPlaying = false
    self.isGameEnd = false
    timerMgr:register(self) 
end

function VoiceMgr:clear()
	-- body
	self.speakVoiceCount = 0
    self.speakVoiceListener = {}
    self.speakVoiceNameList = {}
    self.speakVoice_time = 0
    self.speakVoiceIsEnd = 0
    self.isPlaying = false
    self.isGameEnd = false
end

function VoiceMgr:update(t)
    --用于语音按顺序播放
    if self.speakVoiceIsEnd == 1 then --正在说话
        self.speakVoice_time = self.speakVoice_time + t
        if self.speakVoice_time >= 0.1 then 
            if self.isGameEnd == true then --这局结束了
                for i = 1, #self.speakVoiceListener do
                    if self.speakVoiceListener[i] ~= nil then
                        if self.speakVoiceNameList[i] ~= nil then --删除声音文件
                            os.remove(self.speakVoiceNameList[i])
                        end
                        self.speakVoiceListener[i] = nil
                    end
                end
                self.speakVoiceIsEnd = 0
            else --这局未结束
                if self.isPlaying == false then --未正在播放语音
                    self:playSpeakVoice()
                end
            end
            self.speakVoice_time = 0
        end          
    end
end

function VoiceMgr:addSpeakVoiceToList(voiceName, callfunc)
    self.speakVoiceCount = self.speakVoiceCount + 1
    self.speakVoiceListener[self.speakVoiceCount] = callfunc
    self.speakVoiceNameList[self.speakVoiceCount] = voiceName
    dump("addSpeakVoiceToList1:voiceName=" .. voiceName)
    self.speakVoiceIsEnd = 1
end

-- function VoiceMgr:checkIsEndRound() --是否这局结束了
--     local ret = false
--     if self.isEnd == true then --房间已经解散/总结算界面显示
--         ret = true
--     else --房间未解散
--         if self.smallSummary ~= nil then --小结界面显示
--             ret = true
--         end
--     end
--     return ret
-- end

function VoiceMgr:setIsPlaying(b)
	-- body
	self.isPlaying = b
end

function VoiceMgr:setIsGameEnd(b)
	-- body
	self.isGameEnd = b 
end

-- function VoiceMgr:checkIsSpeaking() --检查当前是否有正在播放语音
--     local ret = false
--     --检查玩家头像区的语音图标
--     for i =1, 4 do
--         if self.player[i] ~= nil and self.player[i].pinfo ~= nil then
--             if self.player[i].pinfo:getChildByTag(SPEAK_TAG) ~= nil then --对应item_speak.lua
--                 ret = true
--             end
--         end
--     end
--     return ret
-- end

function VoiceMgr:playSpeakVoice() --播放语音
    for i =1, #self.speakVoiceListener do
        if self.speakVoiceListener[i] ~= nil then 
            self.speakVoiceListener[i]()
            self.speakVoiceListener[i] = nil
            break
        end
        if i == #self.speakVoiceListener then
            self.speakVoiceIsEnd = 0
        end
    end
end

return VoiceMgr