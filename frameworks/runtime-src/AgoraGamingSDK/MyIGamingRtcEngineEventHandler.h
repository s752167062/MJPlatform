
#ifndef AGORA_GAME_HANDLER_H
#define AGORA_GAME_HANDLER_H

#include <stdio.h>
#include "CCLuaEngine.h"
#include <string.h>

#include "include/AgoraGamingRtcHelper.h"
#include "include/IAgoraRtcEngineForGaming.h"

#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"

using namespace agora::rtc;
using namespace std;

class MyIGamingRtcEngineEventHandler : public agora::rtc::IGamingRtcEngineEventHandler{
public:
	static MyIGamingRtcEngineEventHandler* getInstance();

	MyIGamingRtcEngineEventHandler();
	~MyIGamingRtcEngineEventHandler();
    
    void onJoinChannelSuccess (const char* channel, uid_t uid, int elapsed) override;
    void onRejoinChannelSuccess(const char* channel, uid_t uid, int elapsed) override;
    
    void onWarning(int warn, const char* msg) override;
    void onError(int err, const char* msg) override;
    
    void onAudioQuality(uid_t uid, int quality, unsigned short delay, unsigned short lost) override;
    void onAudioVolumeIndication (const AudioVolumeInfo* speakers, unsigned int speakerNumber, int totalVolume) override;
    
    void onLeaveChannel(const RtcStats& stat) override;
    void onNetworkQuality(uid_t uid, int txQuality, int rxQuality) override;
    
    void onUserJoined(uid_t uid, int elapsed) override;
    void onUserOffline(uid_t uid, USER_OFFLINE_REASON_TYPE reason) override;
    
    void onUserMuteAudio(uid_t uid, bool muted) override;
    void onAudioRouteChanged(AUDIO_ROUTE_TYPE routing) override;
    void onConnectionLost() override;
    
private:
	lua_State* m_ls;
	static MyIGamingRtcEngineEventHandler* m_instance;
};

#endif
