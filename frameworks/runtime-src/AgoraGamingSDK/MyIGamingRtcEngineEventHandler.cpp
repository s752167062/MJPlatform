

#include "MyIGamingRtcEngineEventHandler.h"
#include "cocos2d.h"
#include "agoraGameMgr.h"

USING_NS_CC;
//using namespace agora::rtc;

//SDK 回调管理对象
MyIGamingRtcEngineEventHandler* MyIGamingRtcEngineEventHandler::m_instance = nullptr;

MyIGamingRtcEngineEventHandler* MyIGamingRtcEngineEventHandler::getInstance()
{
	if (m_instance != nullptr)
		return m_instance;
	m_instance = new MyIGamingRtcEngineEventHandler();

	return m_instance;
}

MyIGamingRtcEngineEventHandler::MyIGamingRtcEngineEventHandler() 
{

}

MyIGamingRtcEngineEventHandler::~MyIGamingRtcEngineEventHandler()
{
	if (m_instance) 
	{
		free(m_instance);
		m_instance = nullptr;
	}
}

//加入频道回调 该方法表示用户已成功加入指定频道。
void MyIGamingRtcEngineEventHandler::onJoinChannelSuccess(const char* channel, uid_t uid, int elapsed){
    CCLOG("[ AgoraSDK ]:onJoinChannelSuccess %s, %d, %d", channel, uid, elapsed);
    std::stringstream rawMsg;
    rawMsg << "joinChannel:" << channel << ":" << uid << ":" << elapsed;
    agoraGameMgr::getInstance()->lua_onCallback(7001 , rawMsg.str());
}

//重新加入频道 有时候由于网络原因，客户端可能会和服务器失去连接，SDK会进行自动重连，自动重连成功后触发此回调方法
void MyIGamingRtcEngineEventHandler::onRejoinChannelSuccess(const char* channel, uid_t uid, int elapsed){
    CCLOG("[ AgoraSDK ]:onRejoinChannelSuccess %s, %d, %d", channel, uid, elapsed);
    std::stringstream rawMsg;
    rawMsg << "reJoinChannel:" << channel << ":" << uid << ":" << elapsed;
    agoraGameMgr::getInstance()->lua_onCallback(7002 , rawMsg.str());
}

//其他用户加入当前频道回调
void MyIGamingRtcEngineEventHandler::onUserJoined(uid_t uid, int elapsed){
    CCLOG("[ AgoraSDK ]:onUserJoined %d, %d", uid, elapsed);
    std::stringstream rawMsg;
    rawMsg << "userJoined:" << "default" << ":" << uid << ":" << elapsed;
    agoraGameMgr::getInstance()->lua_onCallback(7003 , rawMsg.str());
}

//提示有用户离开了频道（或掉线）。 SDK 判断用户离开频道（或掉线）的依据是超时: 在一定时间内（15秒）没有收到对方的任何数据包，判定为对方掉线。在网络较差的情况下，可能会有误报建议可靠的掉线检测应该由信令来做。
void MyIGamingRtcEngineEventHandler::onUserOffline(uid_t uid, USER_OFFLINE_REASON_TYPE reason) {
    CCLOG("[ AgoraSDK ]:onUserOffline %d, %d", uid, reason);
    std::stringstream rawMsg;
    if(reason == USER_OFFLINE_QUIT){
        rawMsg << "userOffline:" << uid << ":" << reason;
        agoraGameMgr::getInstance()->lua_onCallback(7013 , rawMsg.str());
    }else{
        //规划为 USER_OFFLINE_DROPPED
        rawMsg << "userOffline:" << uid << ":" << reason;
        agoraGameMgr::getInstance()->lua_onCallback(7014 , rawMsg.str());
    }
    
}

//用户静音回调 True 该用户已静音   / False 该用户已取消静音
void MyIGamingRtcEngineEventHandler::onUserMuteAudio(uid_t uid, bool muted){
    CCLOG("[ AgoraSDK ]:onUserMuteAudio %d, %d", uid);
    std::stringstream rawMsg;
    rawMsg << "userMuteAudio:" << uid ;
    agoraGameMgr::getInstance()->lua_onCallback(7012 , rawMsg.str());
}
//应用程序离开频道成功
void MyIGamingRtcEngineEventHandler::onLeaveChannel(const RtcStats& stats){
    CCLOG("[AgoraSDK ]:onLeaveChannel %d, %d, %d", stats.duration, stats.txBytes, stats.rxBytes);
    std::stringstream rawMsg;
    rawMsg << "leaveChannel:" << stats.duration << ":" << stats.txBytes << ":" << stats.rxBytes;
    agoraGameMgr::getInstance()->lua_onCallback(7011 , rawMsg.str());
}

//通知 App 语音路由状态已发生变化。 该回调返回当前的语音路由已切换至听筒，外放 (扬声器)，耳机或蓝牙。
void MyIGamingRtcEngineEventHandler::onAudioRouteChanged(AUDIO_ROUTE_TYPE routing){
    CCLOG("[AgoraSDK ]:onAudioRouteChanged %d", routing);
}

////Channel Key 过期回调
//void MyIGamingRtcEngineEventHandler::onRequestChannelKey(){
//    CCLOG("[AgoraSDK ]:onRequestChannelKey");
//}

//SDK 和服务器失去了网络连接
void MyIGamingRtcEngineEventHandler::onConnectionLost(){
    CCLOG("[AgoraSDK ]:onConnectionLost ");
    agoraGameMgr::getInstance()->lua_onCallback(-1 , "sdkConnectLost");
}

//该回调每 2 秒触发，向APP报告频道内用户当前的上行、下行网络质量。
void MyIGamingRtcEngineEventHandler::onNetworkQuality(uid_t uid, int txQuality, int rxQuality){
    
}

//提示谁在说话及其音量。默认禁用。可以通过 enableAudioVolumeIndication 方法设置。
void MyIGamingRtcEngineEventHandler::onAudioVolumeIndication (const AudioVolumeInfo* speakers, unsigned int speakerNumber, int totalVolume){
    CCLOG("[AgoraSDK ]:onAudioVolumeIndication %d", speakerNumber);
    std::stringstream rawMsg;
    rawMsg << "onAudioVolumeIndication:" << speakerNumber << ":";
    for (int i = 0; i < speakerNumber; ++i){
        AudioVolumeInfo sp = speakers[i] ;
        uid_t uid  = sp.uid;
        rawMsg<< uid << ";";
    }
    agoraGameMgr::getInstance()->lua_onCallback(8001 , rawMsg.str());
}

//例如和服务器失去连接时，SDK可能会上报ERR_OPEN_CHANNEL_TIMEOUT警告，同时自动尝试重连
void MyIGamingRtcEngineEventHandler::onWarning(int warn, const char* msg){
     CCLOG("[AgoraSDK ]:onWarning ");
    std::stringstream rawMsg;
    rawMsg << "onWarning:" << warn << ":" << msg ;
    agoraGameMgr::getInstance()->lua_onCallback(-3 , rawMsg.str());
}

//需要 APP 干预或提示用户。 例如启动通话失败时，SDK 会上报 ERR_START_CALL 错误。APP 可以提示用户启动通话失败，并调用 leaveChannel 退出频道
void MyIGamingRtcEngineEventHandler::onError(int err, const char* msg){
    CCLOG("[AgoraSDK ]:onError ");
    std::stringstream rawMsg;
    rawMsg << "onError:" << err << ":" << msg ;
    agoraGameMgr::getInstance()->lua_onCallback(-2 , rawMsg.str());
}

//在通话中，该回调方法每两秒触发一次，报告当前通话的（嘴到耳）音频质量。默认启用。
void MyIGamingRtcEngineEventHandler::onAudioQuality(uid_t uid, int quality, unsigned short delay, unsigned short lost){
    
}
