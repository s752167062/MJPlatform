

#include "agoraGameMgr.h"
#include "cocos2d.h"
#include "MyIGamingRtcEngineEventHandler.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#endif

USING_NS_CC;
using namespace agora::rtc;

//SDK 管理对象
agoraGameMgr* agoraGameMgr::m_instance = nullptr;

agoraGameMgr* agoraGameMgr::getInstance()
{
	if (m_instance != nullptr)
		return m_instance;
	m_instance = new agoraGameMgr();
	m_instance->init();
	return m_instance;
}

agoraGameMgr::agoraGameMgr() 
{

}

agoraGameMgr::~agoraGameMgr()
{
	if (m_instance) 
	{
		free(m_instance);
		m_instance = nullptr;
	}
}

void agoraGameMgr::bind(lua_State *ls)
{
	this->m_ls = ls;
	lua_register(ls, "cpp_joinChannel"  , joinChannel   );
    lua_register(ls, "cpp_leaveChannel" , leaveChannel  );
    
    lua_register(ls, "cpp_enableAudio" , enableAudio  );    //打开音频        
    lua_register(ls, "cpp_disableAudio" , disableAudio  );  //关闭音频
    lua_register(ls, "cpp_muteLocalAudioStream" , muteLocalAudioStream  );             //将自己静音 True: 设置本地静音，即麦克风静音    False: 取消本地静音          
    lua_register(ls, "cpp_muteAllRemoteAudioStreams" , muteAllRemoteAudioStreams  );   //静音所有远端音频 True: 停止播放所有收到的音频流     False: 允许播放所有收到的音频流  
    lua_register(ls, "cpp_muteRemoteAudioStream" , muteRemoteAudioStream  );           //静音指定用户音频 True: 停止播放指定用户的音频流 
    
    lua_register(ls, "cpp_enableAudioVolumeIndication" , enableAudioVolumeIndication  );//启用说话者音量提示
    lua_register(ls, "cpp_adjustRecordingSignalVolume" , adjustRecordingSignalVolume  );//调节录音信号音量
    lua_register(ls, "cpp_adjustPlaybackSignalVolume"  , adjustPlaybackSignalVolume  ); //调节播放信号音量
    
    lua_register(ls, "cpp_poll"  , sdkpoll  ); //触发 SDK 事件
    lua_register(ls, "cpp_setSdkHandler"  , setSdkHandler  ); //设置基础的配置
    lua_register(ls, "cpp_setDefaultAudioRouteToSpeakerphone"  , setDefaultAudioRouteToSpeakerphone  ); //设置基础的配置
    lua_register(ls, "cpp_setEnableSpeakerphone"  , setEnableSpeakerphone  ); //设置基础的配置

    //备用接口
    lua_register(ls, "cpp_startAudioMixing"  , startAudioMixing  );
    lua_register(ls, "cpp_stopAudioMixing"  , stopAudioMixing  );
    lua_register(ls, "cpp_setChannelProfile"  , setChannelProfile  );
    lua_register(ls, "cpp_setClientRole"  , setClientRole  );
    lua_register(ls, "cpp_renewChannelKey"  , renewChannelKey  );
    lua_register(ls, "cpp_joinChannelWithKey"  , joinChannelWithKey  );
    lua_register(ls, "cpp_pauseAudioMixing"  , pauseAudioMixing  );
    lua_register(ls, "cpp_resumeAudioMixing"  , resumeAudioMixing  );
    lua_register(ls, "cpp_adjustAudioMixingVolume"  , adjustAudioMixingVolume  );
    lua_register(ls, "cpp_getAudioMixingDuration"  , getAudioMixingDuration  );
    lua_register(ls, "cpp_getAudioMixingCurrentPosition"  , getAudioMixingCurrentPosition  );
//    lua_register(ls, "cpp_getVersion"  , getVersion  );
//    lua_register(ls, "cpp_setLogFile"  , setLogFile  );
//    lua_register(ls, "cpp_setLogFilter"  , setLogFilter  );
//
    lua_register(ls, "cpp_getEffectsVolume"  , getEffectsVolume  );
    lua_register(ls, "cpp_setEffectsVolume"  , setEffectsVolume  );
    lua_register(ls, "cpp_playEffect"  , playEffect  );
    lua_register(ls, "cpp_stopEffect"  , stopEffect  );
    lua_register(ls, "cpp_stopAllEffects"  , stopAllEffects  );
    lua_register(ls, "cpp_preloadEffect"  , preloadEffect  );
    lua_register(ls, "cpp_unloadEffect"  , unloadEffect  );
    lua_register(ls, "cpp_pauseEffect"  , pauseEffect  );
    lua_register(ls, "cpp_pauseAllEffects"  , pauseAllEffects  );
    lua_register(ls, "cpp_resumeEffect"  , resumeEffect  );
    lua_register(ls, "cpp_resumeAllEffects"  , resumeAllEffects  );
    lua_register(ls, "cpp_setVoiceOnlyMode"  , setVoiceOnlyMode  );
//    lua_register(ls, "cpp_SetLocalVoicePitch"  , SetLocalVoicePitch  );
//    lua_register(ls, "cpp_setRemoteVoicePosition"  , setRemoteVoicePosition  );

    lua_register(ls, "cpp_reSetAudioToDeafult"  , reSetAudioToDeafult  );
}

void agoraGameMgr::init() 
{
    AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setEventHandler(MyIGamingRtcEngineEventHandler::getInstance());
}

void agoraGameMgr::lua_onCallback(int status , string info)
{
    if(this->callback_handler > 0){
        lua_settop(this->m_ls, 0);
        lua_pushinteger(this->m_ls, status);
        lua_pushstring(this->m_ls, info.c_str());
        cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(this->callback_handler, 2);
        return ;
    }
    CCLOG("没有LUA回调函数");
}

int agoraGameMgr::setSdkHandler(lua_State *ls)
{   //handler 初始设置基础的配置
    int volumeRecord = lua_tointeger(ls ,1);
    int volumePlay   = lua_tointeger(ls ,2);

    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 3, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN setSdkHandler", &toerror);
        lua_settop(ls, 0);
        lua_pushinteger(ls, -3333);
        return 1;
    }else{
        hanlder = (toluafix_ref_function(ls, 3, 0));
    }
    agoraGameMgr::getInstance()->setHandler(hanlder);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    AVAudioSession *audios = [AVAudioSession sharedInstance];
    NSLog(@"audios.category : %@",audios.category );
    NSLog(@"audios.mode : %@",audios.mode );
    
#endif
    //
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->adjustRecordingSignalVolume(volumeRecord);
    status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->adjustPlaybackSignalVolume(volumePlay);
    status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->enableAudioVolumeIndication(1000,3);
    status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setDefaultAudioRouteToSpeakerphone(true);//外放
    status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setEnableSpeakerphone(true);
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

void agoraGameMgr::setHandler(int handler){
    this->callback_handler = handler;
}
int agoraGameMgr::getHandler(){
    return this->callback_handler;
}

int agoraGameMgr::sdkpoll(lua_State* ls){
    AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->poll();
    return 0;
}

int agoraGameMgr::setDefaultAudioRouteToSpeakerphone(lua_State *ls){
    bool st = lua_toboolean(ls ,1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setDefaultAudioRouteToSpeakerphone(st);//外放
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

int agoraGameMgr::setEnableSpeakerphone(lua_State *ls){
    bool st = lua_toboolean(ls ,1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setEnableSpeakerphone(st);//外放
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

int agoraGameMgr::joinChannel(lua_State *ls){
    //加入房间
    string roomid  = lua_tostring(ls ,1);
    int uuid       = lua_tointeger(ls ,2);
    string extinfo = lua_tostring(ls ,3);
    
    int status = -1;
    if(!roomid.empty()){
        auto rtcEngine = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID);
        rtcEngine->setChannelProfile(CHANNEL_PROFILE_GAME_FREE_MODE); //自由发言模式
        status = rtcEngine->joinChannel(roomid.c_str(), extinfo.c_str(), uuid);
    }

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

int agoraGameMgr::leaveChannel(lua_State *ls){
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    AVAudioSession *audios = [AVAudioSession sharedInstance];
    NSLog(@"audios.category leave: %@",audios.category );
    NSLog(@"audios.mode leave: %@",audios.mode );
    
#endif
    
    //退出房间
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->leaveChannel();
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

int agoraGameMgr::reSetAudioToDeafult(lua_State *ls){
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    try {
        AVAudioSession *audios = [AVAudioSession sharedInstance];
        [audios setCategory:@"AVAudioSessionCategorySoloAmbient" error:nil];
        [audios setMode:@"AVAudioSessionModeDefault" error:nil];
        NSLog(@"audios.category reset: %@",audios.category );
        NSLog(@"audios.mode reset: %@",audios.mode );
    } catch (NSException *e) {
        NSLog(@">>>>> audios.category mode err");
    }
    
#endif
    return 0;
}

int agoraGameMgr::enableAudio(lua_State *ls)
{
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->enableAudio();
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

int agoraGameMgr::disableAudio(lua_State *ls)
{
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->disableAudio();
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

int agoraGameMgr::muteLocalAudioStream(lua_State *ls)
{
    bool muted = lua_toboolean(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->muteLocalAudioStream(muted);
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

int agoraGameMgr::muteAllRemoteAudioStreams(lua_State *ls)
{
    bool muted = lua_toboolean(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->muteAllRemoteAudioStreams(muted);
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

int agoraGameMgr::muteRemoteAudioStream(lua_State *ls)
{
    int uuid = lua_tointeger(ls, 1);
    bool muted = lua_toboolean(ls, 2);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->muteRemoteAudioStream(uuid,muted);
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

//启用说话者音量提示
int agoraGameMgr::enableAudioVolumeIndication(lua_State *ls)
{
    int interval = lua_tointeger(ls, 1); //指定音量提示的时间间隔
    int smooth = lua_toboolean(ls, 2); //平滑系数。默认可以设置为 3
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->enableAudioVolumeIndication(interval ,smooth);
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}


//调节录音信号音量
int agoraGameMgr::adjustRecordingSignalVolume(lua_State *ls)
{
    int volume = lua_tointeger(ls, 1); //调节录音信号音量
    //0: 静音
    //100: 原始音量
    //400: 最大可为原始音量的 4 倍
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->adjustRecordingSignalVolume(volume);
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

//调节播放信号音量
int agoraGameMgr::adjustPlaybackSignalVolume(lua_State *ls)
{
    int volume = lua_tointeger(ls, 1); //调节录音信号音量
    //0: 静音
    //100: 原始音量
    //400: 最大可为原始音量的 4 倍
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->adjustPlaybackSignalVolume(volume);
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}


int agoraGameMgr::getEffectsVolume(lua_State* ls){//获取音效音量
    double volume = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->getEffectsVolume();
    lua_settop(ls, 0);
    lua_pushinteger(ls, volume);
    return 1;
}
int agoraGameMgr::setEffectsVolume(lua_State* ls){//设置音效音量
    double volume = lua_tonumber(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->setEffectsVolume(volume);

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::playEffect(lua_State* ls){//播放音效
    int soundId = lua_tointeger(ls, 1);
    std::string filePath = lua_tostring(ls, 2);
    bool loop = lua_toboolean(ls, 3);
    double pitch = lua_tonumber(ls, 4);
    double pan   = lua_tonumber(ls, 5);
    double gain  = lua_tonumber(ls, 6);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->playEffect(soundId,filePath.c_str(),loop,pitch,pan,gain);
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::stopEffect(lua_State* ls){//停止播放指定音效
    int soundId = lua_tointeger(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->stopEffect(soundId);

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::stopAllEffects(lua_State* ls){//停止播放所有的音效
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->stopAllEffects();

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::preloadEffect(lua_State* ls){//预加载音效
    int soundId = lua_tointeger(ls, 1);
    std::string filePath = lua_tostring(ls, 2);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->preloadEffect(soundId,filePath.c_str());

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::unloadEffect(lua_State* ls){//释放音效
    int soundId = lua_tointeger(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->unloadEffect(soundId);

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::pauseEffect(lua_State* ls){//暂停音效播放
    int soundId = lua_tointeger(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->pauseEffect(soundId);

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::pauseAllEffects(lua_State* ls){//停止所有音效播放
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->pauseAllEffects();

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::resumeEffect(lua_State* ls){//恢复播放指定音效
    int soundId = lua_tointeger(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->resumeEffect(soundId);

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::resumeAllEffects(lua_State* ls){//恢复播放所有音效
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->resumeAllEffects();

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::setVoiceOnlyMode(lua_State* ls){//设置仅限语音模式
    bool enable = lua_toboolean(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->setVoiceOnlyMode(enable);

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::setRemoteVoicePosition(lua_State* ls){//设置本地语音音调
    int uid = lua_tointeger(ls, 1);
    double pan = lua_tonumber(ls, 2);
    double gain = lua_tonumber(ls, 3);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->setRemoteVoicePosition(uid,pan,gain);

    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}

//int agoraGameMgr::SetLocalVoicePitch(lua_State* ls){//设置本地语音音调
//    double pitch =lua_tonumber(ls, 1);
//    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioEffectManager()->SetLocalVoicePitch(pitch);
//
//    lua_settop(ls, 0);
//    lua_pushinteger(ls, status);
//    return 1;
//}

int agoraGameMgr::setChannelProfile(lua_State* ls){
    int profile = lua_tointeger(ls, 1);
    int status;
    if( profile == 2){
        status= AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setChannelProfile(CHANNEL_PROFILE_GAME_FREE_MODE);
    }else{
        status= AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setChannelProfile(CHANNEL_PROFILE_GAME_COMMAND_MODE);
    }
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::setClientRole(lua_State* ls){
    int profile = lua_tointeger(ls, 1);
    std::string key = lua_tostring(ls, 2);
    
    int status ;
    if(profile == 1){
        status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setClientRole(CLIENT_ROLE_BROADCASTER, key.c_str());
    }else{
        status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->setClientRole(CLIENT_ROLE_AUDIENCE, key.c_str());
    }
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::renewChannelKey(lua_State* ls){
    std::string key = lua_tostring(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->renewChannelKey(key.c_str());
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::joinChannelWithKey(lua_State* ls){
    std::string key = lua_tostring(ls, 1);
    std::string channel = lua_tostring(ls, 2);
    std::string info = lua_tostring(ls, 3);
    int uid = lua_tointeger(ls, 4);
    
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->joinChannel(key.c_str(), channel.c_str(), info.c_str(), uid);
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}


int agoraGameMgr::startAudioMixing(lua_State* ls){
    string filePath = lua_tostring(ls, 1);//本地音频文件名和文件路径名:
    bool loopback = lua_toboolean(ls, 2); //True: 只有本地可以听到混音    False: 本地和对方都可以听到混音或替换后的音频流
    bool replace = lua_toboolean(ls , 3); //True: 音频文件内容将会替换本地录音的音频流    False: 音频文件内容将会和麦克风采集的音频流进行混音
    int cycle   = lua_tointeger(ls, 4);   //-1：无限循环
    int playTime= lua_tointeger(ls, 5);
    
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->startAudioMixing(filePath.c_str(),loopback ,replace,cycle,playTime);
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}//开启伴奏播放
int agoraGameMgr::stopAudioMixing(lua_State* ls){
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->stopAudioMixing();
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}//结束伴奏播放

int agoraGameMgr::pauseAudioMixing(lua_State* ls){
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->pauseAudioMixing();
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::resumeAudioMixing(lua_State* ls){
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->resumeAudioMixing();
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::adjustAudioMixingVolume(lua_State* ls){
    int volume = lua_tointeger(ls, 1);
    int status = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->adjustAudioMixingVolume(volume);
    
    lua_settop(ls, 0);
    lua_pushinteger(ls, status);
    return 1;
}
int agoraGameMgr::getAudioMixingDuration(lua_State* ls){
    int dur = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioMixingDuration();
    lua_settop(ls, 0);
    lua_pushinteger(ls, dur);
    return 1;
}
int agoraGameMgr::getAudioMixingCurrentPosition(lua_State* ls){
    int cp = AgoraRtcEngineForGaming_getInstance(AGORA_APP_ID)->getAudioMixingCurrentPosition();
    lua_settop(ls, 0);
    lua_pushinteger(ls, cp);
    return 1;
}

