
#ifndef AGORA_GAME_MGR_H
#define AGORA_GAME_MGR_H

#include <stdio.h>
#include "CCLuaEngine.h"
#include <string.h>

#include "include/AgoraGamingRtcHelper.h"
#include "include/IAgoraRtcEngineForGaming.h"

#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"

#define AGORA_APP_ID "b731acede9bb47aa9c391603127e7e10"
using namespace std;

class agoraGameMgr {
public:
	static agoraGameMgr* getInstance();

	agoraGameMgr();
	~agoraGameMgr();

	void bind(lua_State* ls);

    static int setSdkHandler(lua_State* ls);//初始化基础的配置
	static int joinChannel(lua_State* ls);  //加入频道
    static int leaveChannel(lua_State* ls); //离开频道
    
    static int enableAudio(lua_State* ls);  //打开音频
    static int disableAudio(lua_State* ls); //关闭音频
    static int muteLocalAudioStream(lua_State* ls); //将自己静音 True: 设置本地静音，即麦克风静音    False: 取消本地静音
    static int muteAllRemoteAudioStreams(lua_State* ls); //静音所有远端音频 True: 停止播放所有收到的音频流     False: 允许播放所有收到的音频流
    static int muteRemoteAudioStream(lua_State* ls); //静音指定用户音频  True: 停止播放指定用户的音频流
    
    static int enableAudioVolumeIndication(lua_State* ls); //启用说话者音量提示
    static int adjustRecordingSignalVolume(lua_State* ls); //调节录音信号音量
    static int adjustPlaybackSignalVolume(lua_State* ls); //调节播放信号音量
    
    static int sdkpoll(lua_State* ls);//触发 SDK 事件 该方法根据垂直同步 (vertical synchronization) 例如 onUpdate 触发 SDK 事件(Cocos2d)。
    static int setDefaultAudioRouteToSpeakerphone(lua_State* ls);
    static int setEnableSpeakerphone(lua_State* ls);
    
    //备用接口
    static int setChannelProfile(lua_State* ls);//设置频道属性
    static int setClientRole(lua_State* ls);//设置用户角色
    static int renewChannelKey(lua_State* ls);//更新 Channel Key
    static int joinChannelWithKey(lua_State* ls);  //带密钥加入频道

    static int startAudioMixing(lua_State* ls);//开启伴奏播放
    static int stopAudioMixing(lua_State* ls);//结束伴奏播放
    static int pauseAudioMixing(lua_State* ls);//暂停伴奏播放
    static int resumeAudioMixing(lua_State* ls);//恢复伴奏播放
    static int adjustAudioMixingVolume(lua_State* ls);//调节伴奏音量
    static int getAudioMixingDuration(lua_State* ls);//获取伴奏时长
    static int getAudioMixingCurrentPosition(lua_State* ls);//获取伴奏播放进度
    
    static int getVersion(lua_State* ls);//查询 SDK 版本号音
    static int setLogFile(lua_State* ls);//设置日志文件
    static int setLogFilter(lua_State* ls);//设置日志过滤器
    
//    static int getAudioEffectManager(lua_State* ls);//获取音效管理器
    static int getEffectsVolume(lua_State* ls);//获取音效音量
    static int setEffectsVolume(lua_State* ls);//设置音效音量
    static int playEffect(lua_State* ls);//播放音效
    static int stopEffect(lua_State* ls);//停止播放指定音效
    static int stopAllEffects(lua_State* ls);//停止播放所有的音效
    static int preloadEffect(lua_State* ls);//预加载音效
    static int unloadEffect(lua_State* ls);//释放音效
    static int pauseEffect(lua_State* ls);//暂停音效播放
    static int pauseAllEffects(lua_State* ls);//停止所有音效播放
    static int resumeEffect(lua_State* ls);//恢复播放指定音效
    static int resumeAllEffects(lua_State* ls);//恢复播放所有音效
    static int setVoiceOnlyMode(lua_State* ls);//设置仅限语音模式
//    static int SetLocalVoicePitch(lua_State* ls);//设置本地语音音调
    static int setRemoteVoicePosition(lua_State* ls);//设置远端用户的语音位置
    static int reSetAudioToDeafult(lua_State *ls);//
    
    
    //回调LUA
    void lua_onCallback(int status , string info);

    void setHandler(int handler);
    int getHandler();
private:
	void init();

private:
	lua_State* m_ls;
    int callback_handler;
	static agoraGameMgr* m_instance;
};

#endif
