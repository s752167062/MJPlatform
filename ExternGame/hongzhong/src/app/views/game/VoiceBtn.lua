local VoiceBtn = class("VoiceBtn", require("app.common.NodeBase"))


function VoiceBtn:ctor()
    VoiceBtn.super.ctor(self, "layout/chat/VoiceBtn.csb")
    
    -- self.isTooShort = true 
    self.canSend = false 
    self.minterval_uploadVoiceIsEnd = 0
    self.canSpeakNextVoice = true
    self.uploadVoice_time = 0
    self.uploadVoideIsEnd = 0
    self.minterval = 0
    --语音按钮
    self.btn_mcrophone = self:findChildByName("btn_mcrophone")
    self.btn_mcrophone:onTouch(function ( event )
        self:onMcrophone(event) 
    end)

    eventMgr:registerEventListener("uploadVoiceCompled",handler(self,self.uploadVoiceCompled),self)
    eventMgr:registerEventListener("RecodeSoundComp",handler(self,self.RecodeSoundComp),self)
    timerMgr:register(self)

    self.ismp3 = gameConfMgr:getInfo("soundRecodLameMp3")
end

function VoiceBtn:setVisible(b)
    -- body
    self.btn_mcrophone:setVisible(b)
end

function VoiceBtn:onMcrophone(event) 
    dump(" /// mcrophone event  " .. event.name )
    if event.name == "began" then
        if self.canSpeakNextVoice then
            self:startRecord()
        else 
            msgMgr:showTips("2次录音间隔过短")
        end
    elseif event.name == "moved" then

    elseif event.name == "ended" then
        if self.canSpeakNextVoice then
            self:stopRecord(true) -- not self.isEnd
        end
    elseif event.name == "cancelled" then
        self:stopRecord(false)
    end
end

function VoiceBtn:update(t)
    self.minterval  = self.minterval + t -- 录制时间

    -- -- body
    --用于上传声音完了后的回调
    if self.uploadVoideIsEnd == 1 then --正在上传声音
        self.uploadVoice_time = self.uploadVoice_time + t
        if self.uploadVoice_time > 0.1 then
            local num = cpp_uploadVoice_getEndFlag() --获取上传声音的结束标记
            if num ~= nil and num == 1 then --为1表示上传声音结束，等待Lua获取声音名字
                local name = cpp_uploadVoice_getName()
                dump("sendEmoticon0:start sendEmoticon" .. name)
                if name ~= nil then -- not self.isEnd and
                    eventMgr:dispatchEvent("uploadVoiceCompled",name)
                end
                cpp_uploadVoice_resetEndFlag() --重置结束标记
                self.uploadVoideIsEnd = 0
            end
            self.uploadVoice_time = 0
        end
        --若上传声音出错，重新打开开关
        self.minterval_uploadVoiceIsEnd = self.minterval_uploadVoiceIsEnd + t
        if self.minterval_uploadVoiceIsEnd > 15 then
            self.uploadVoideIsEnd = 0
            self.minterval_uploadVoiceIsEnd = 0
        end
    else
        self.minterval_uploadVoiceIsEnd = 0
    end
end

function VoiceBtn:onEnter()
end

function VoiceBtn:onExit()
    eventMgr:removeEventListenerForTarget(self)
    timerMgr:unRegister(self)
    timerMgr:clearTask("RecodeSoundComp_end")
    -- --退出房间停止播放录音
    -- platformMgr:stop_audio()
    -- cpp_uploadVoice_resetEndFlag() --重置结束标记
end

function VoiceBtn:startRecord()
    release_print(" //////   startRecord ----  ")
    timerMgr:clearTask("RecodeSoundComp_end")
    self.isStartRecord = true

    --暂停音效
    audioMgr:stopMusic()
    audioMgr:stopAllEffects()
    
    --文件名
    if self.ismp3 == true then 
        self.videoName = os.time().. "a" ..gameConfMgr:getInfo("userId") ..".mp3"
    else
        self.videoName = os.time().. "a" ..gameConfMgr:getInfo("userId") ..".amr"
    end    
    --开始录制 
    platformMgr:startRecoder_audio(self.videoName, cc.FileUtils:getInstance():getWritablePath()  , nil ,self.ismp3)--开始录音 function ()  eventMgr:dispatchEvent("RecodeSoundComp",nil)   end

    --超时后操作
    local function time_out_callfunc(t)
        print("time_out_callfunctime_out_callfunc")

        self:stopRecord(true)
    end
    self.minterval  = 0
    -- self.isTooShort = true
    timerMgr:clearTask("recodeEnd")
    timerMgr:registerTask("recodeEnd" , timerMgr.TYPE_CALL_ONE , time_out_callfunc ,  gameConfMgr:getInfo("soundRecodTime"))--开启超时定时器
    
    --add 动画
    -- local action = cc.CSLoader:createTimeline("layout/chat/SoundRecord.csb")
    -- action:play("a0",true)

    -- self.ui_soundRecord:runAction(action)   
    -- local sp = cc.Sprite:create("ui/image/test/quan1.png")
    -- sp:setPosition(cc.p(display.cx,display.cy))
    -- viewMgr:getScene():addChild(sp, 2000)

    self.ui_soundRecord = display.newCSNode("layout/chat/SoundRecord.csb") 
    viewMgr:getScene():addChild(self.ui_soundRecord,2000)

    --圆形进度条
    local pProgressTimer = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("image/chat/quan2.png"))
    pProgressTimer:setPosition(cc.p(display.cx,display.cy))
    pProgressTimer:setReverseProgress(false)
    self.ui_soundRecord:addChild(pProgressTimer, 2001)

    pProgressTimer:setPercentage(0)
    timerMgr:clearTask("pProgressUpdate")

    local function pProgressUpdateFun()
        local hudu = pProgressTimer:getPercentage() 
        hudu = hudu + 1.01
        pProgressTimer:setPercentage(hudu)
    end

    timerMgr:registerTask("pProgressUpdate", timerMgr.TYPE_CALL_RE, pProgressUpdateFun, 0.1)
end

function VoiceBtn:stopRecord(bool)
    release_print(" //////    stopRecord ---- ")
    timerMgr:clearTask("pProgressUpdate")

    timerMgr:clearTask("recodeEnd")
    if self.ui_soundRecord then
        self.ui_soundRecord:removeFromParent()
        self.ui_soundRecord = nil
    end
    if self.isStartRecord ~= true then
        return
    end
    self.isStartRecord = false

    platformMgr:endRecoder_audio(nil , self.ismp3)--结束录音
    self.canSend = false
    if bool then
        if self.minterval >= gameConfMgr:getInfo("soundRecodNextTime") then
            self.canSend = true 
            timerMgr:registerTask("RecodeSoundComp_end",timerMgr.TYPE_CALL_RE, function() 
                                                                                    if cc.FileUtils:getInstance():isFileExist(cc.FileUtils:getInstance():getWritablePath() ..self.videoName) then 
                                                                                        dump(" -- FileExist ..... mp3")
                                                                                        timerMgr:clearTask("RecodeSoundComp_end") 
                                                                                        eventMgr:dispatchEvent("RecodeSoundComp",nil) 
                                                                                    else
                                                                                        dump(" -- waiting ..... mp3")
                                                                                    end    
                                                                                end , 1)
        else
            msgMgr:showTips("录音时间过短")
        end
    else
        msgMgr:showTips("录音已取消")
    end  

    -- --重启 SimpleAudioEngine 
    -- audioMgr:reInstanceAudioObj()
    -- local game_code = RuleMgr:get_cur_rule_data("SERVER_MODEL")
    -- if game_code == "pdk" or game_code == "ddz" then
    --     local music_file_name = game_code.."_room.mp3"
    --     audioMgr:playMusic(music_file_name,true)
    -- else
    --     local music_file_name = "mj_room.mp3"
    --     audioMgr:playMusic(music_file_name,true)
    -- end
    comFunMgr:replayAudio()

    release_print(" //////    stopRecord2 ---- ")
end

function VoiceBtn:RecodeSoundComp()
    dump("录音完全结束 检查等待发送 。。。。")
    if self.canSend and self.uploadVoideIsEnd == 0 then
        local newname = ""
        if self.ismp3 == true then 
            newname = string.sub( self.videoName , 1 , string.find( self.videoName , "." , 1 , true) - 1) .."_"..math.ceil(self.minterval) .. ".mp3"
        else
            newname = string.sub( self.videoName , 1 , string.find( self.videoName , "." , 1 , true) - 1) .."_"..math.ceil(self.minterval) .. ".amr"
        end
        dump(" oldname "..self.videoName)
        dump(" newname "..newname)
        local path = cc.FileUtils:getInstance():getWritablePath() 
        local status , msgerr = os.rename(path .. self.videoName , path .. newname)
        if not status then 
            dump(" ------ mp3 rename err " .. msgerr)
        end  

        self.videoName = newname 
        
        --设置2次录音间隔
        self.canSpeakNextVoice = false
        timerMgr:registerTask("recodeNext",timerMgr.TYPE_CALL_ONE, function ()
            self.canSpeakNextVoice = true
        end,2)

        --设置上传声音的开关(若上传声音出错，在update中重新打开开关)
        self.uploadVoideIsEnd = 1
        
        --test测试播放 
        -- platformMgr:play_audio(self.videoName , path , nil)
        
        --上传语音文件
        dump("上传语音:" .. self.videoName)
        release_print("--- upload  ---",os.date("%Y-%m-%d%H:%M:%S",os.time()))
        cpp_uploadVoice("http://download.hongzhongmajiang.com/upload2.php",self.videoName,path)
    end
end

function VoiceBtn:uploadVoiceCompled(filename)
    --dump("文件上传完成 。。 通知玩家 ")
    --发送协议 type 0 emoji  ,  1 emojivoice   , 2 voice
    if filename ~= nil then
        dump("文件上传完成 。。通知玩家  ok: filename=" .. filename)
        roomHandler:getProtocol():sendEmoticon(2, filename)
    else
        dump("文件上传完成 。。通知玩家  error: filename is nil!!!!!!!!!!!!!!!!")
    end
end

return VoiceBtn