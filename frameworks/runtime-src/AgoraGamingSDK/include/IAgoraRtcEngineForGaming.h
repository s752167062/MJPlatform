//
//  Agora Rtc Engine SDK
//  Copyright (c) 2015 Agora IO. All rights reserved.
//
//  This C++ API provides a uniform way to access Agora
//  SDK both on Android and iOS

#ifndef AGORA_GAMING_RTC_ENGINE_H
#define AGORA_GAMING_RTC_ENGINE_H

#include <stddef.h>
#include <stdio.h>
#include <stdarg.h>

#include <string>
#include <vector>

#include "AgoraGamingRtcHelper.h"

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#define AGORA_CALL __cdecl
#if defined(AGORARTC_EXPORT)
#define AGORA_API extern "C" __declspec(dllexport)
#else
#define AGORA_API extern "C" __declspec(dllimport)
#endif
#elif defined(__APPLE__)
#define AGORA_API __attribute__((visibility("default"))) extern "C"
#define AGORA_CALL
#elif defined(__ANDROID__) || defined(__linux__) || defined(__linux)
#define AGORA_API extern "C" __attribute__((visibility("default")))
#define AGORA_CALL
#else
#define AGORA_API extern "C"
#define AGORA_CALL
#endif

namespace agora {
namespace rtc {
    /**
    * the event callback interface
    */
    class IGamingRtcEngineEventHandler
    {
    public:
        virtual ~IGamingRtcEngineEventHandler() {}

        /**
         * when join channel success, the function will be called
         *
         * @param [in] channel
         *        the channel name you have joined
         * @param [in] uid
         *        the UID of you in this channel
         * @param [in] elapsed
         *        the time elapsed in ms from the joinChannel been called to joining completed
         */
        virtual void onJoinChannelSuccess(const char* channel, unsigned int uid, int elapsed) {
            (void)channel;
            (void)uid;
            (void)elapsed;
        }

        /**
         * when join channel success, the function will be called
         *
         * @param [in] channel
         *        the channel name you have joined
         * @param [in] uid
         *        the UID of you in this channel
         * @param [in] elapsed
         *        the time elapsed in ms elapsed
         */
        virtual void onRejoinChannelSuccess(const char* channel, unsigned int uid, int elapsed) {
            (void)channel;
            (void)uid;
            (void)elapsed;
        }

        /**
         * when channel key is enabled, and specified channel key is invalid or expired, this function will be called.
         * APP should generate a new channel key and call renewChannelKey() to refresh the key.
         * NOTE: to be compatible with previous version, ERR_CHANNEL_KEY_EXPIRED and ERR_INVALID_CHANNEL_KEY are also reported via onError() callback.
         * You should move renew of channel key logic into this callback.
         */
        virtual void onRequestChannelKey() {
        }

        /**
         * when warning message coming, the function will be called
         *
         * @param [in] warn
         *        warning code
         * @param [in] msg
         *        the warning message
         */
        virtual void onWarning(int warn, const char* msg) {
            (void)warn;
            (void)msg;
        }

        /**
         * when error message come, the function will be called
         *
         * @param [in] err
         *        error code
         * @param [in] msg
         *        the error message
         */
        virtual void onError(int err, const char* msg) {
            (void)err;
            (void)msg;
        }

        /**
         * when audio quality message come, the function will be called
         *
         * @param [in] uid
         *        the uid of the peer
         * @param [in] quality
         *        the quality of the user 0~5 the higher the better
         * @param [in] delay
         *        the average time of the audio packages delayed
         * @param [in] lost
         *        the rate of the audio packages lost
         */
        virtual void onAudioQuality(unsigned int uid, int quality, unsigned short delay, unsigned short lost) {
            (void)uid;
            (void)quality;
            (void)delay;
            (void)lost;
        }

        /**
         * when the audio volume information come, the function will be called
         *
         * @param [in] speakers
         *        the array of the speakers' audio volume information
         * @param [in] speakerNumber
         *        the count of speakers in this array
         * @param [in] totalVolume
         *        the total volume of all users
         */
        virtual void onAudioVolumeIndication(const AudioVolumeInfo* speakers, unsigned int speakerNumber, int totalVolume) {
            (void)speakers;
            (void)speakerNumber;
            (void)totalVolume;
        }

        /**
         * when the audio volume information come, the function will be called
         * @param [in] stats
         *        the statistics of the call
         */
        virtual void onLeaveChannel(const RtcStats& stats) {
            (void)stats;
        }

        /**
         * when the information of the RTC engine stats come, the function will be called
         *
         * @param [in] stats
         *        the RTC engine stats
         */
        virtual void onRtcStats(const RtcStats& stats) {
            (void)stats;
        }

        /**
         * When audio mixing file playback finished, this function will be called
         */
        virtual void onAudioMixingFinished() {
        }

        /**
         * report the network quality
         *
         * @param [in] uid
         *        the UID of the remote user
         * @param [in] txQuality
         *        the score of the send network quality 0~5 the higher the better
         * @param [in] rxQuality
         *        the score of the recv network quality 0~5 the higher the better
         */
        virtual void onNetworkQuality(unsigned int uid, int txQuality, int rxQuality) {
            (void)uid;
            (void)txQuality;
            (void)rxQuality;
        }

        /**
         * when any other user joined in the same channel, the function will be called
         *
         * @param [in] uid
         *        the UID of the remote user
         * @param [in] elapsed
         *        the time elapsed from remote used called joinChannel to joining completed in ms
         */
        virtual void onUserJoined(unsigned int uid, int elapsed) {
            (void)uid;
            (void)elapsed;
        }

        /**
         * when user offline(exit channel or offline by accident), the function will be called
         *
         * @param [in] uid
         *        the UID of the remote user
         */
        virtual void onUserOffline(unsigned int uid, USER_OFFLINE_REASON_TYPE reason) {
            (void)uid;
            (void)reason;
        }

        /**
         * when remote user muted the audio stream, the function will be called
         *
         * @param [in] uid
         *        the UID of the remote user
         * @param [in] muted
         *        true: the remote user muted the audio stream, false: the remote user unmuted the audio stream
         */
        virtual void onUserMuteAudio(unsigned int uid, bool muted) {
            (void)uid;
            (void)muted;
        }

        /**
         * audio route changing detected by sdk, this function will be called
         *
         * @param [in] routing
         *        the audio routing
         */
        virtual void onAudioRouteChanged(AUDIO_ROUTE_TYPE routing) {
            (void)routing;
        }

        /**
         * when api call executed completely, the function will be called
         *
         * @param [in] api
         *        the api name
         * @param [in] error
         *        error code while 0 means OK
         */
        virtual void onApiCallExecuted(const char* api, int error) {
            (void)api;
            (void)error;
        }
        virtual void onClientRoleChanged(CLIENT_ROLE_TYPE oldRole,CLIENT_ROLE_TYPE newRole){
            
        };
        /**
         * when the network can not worked well, the function will be called
         */
        virtual void onConnectionLost() {}

        /**
         * when local user disconnected by accident, the function will be called(then SDK will try to reconnect itself)
         */
        virtual void onConnectionInterrupted() {}
    };

    class IRtcEngineForGaming;
    class IAudioEffectManager
    {
    public:
        IAudioEffectManager(IRtcEngineForGaming *rtcEngine);
        
        /**
         * get audio effect volume in the range of [0.0..100.0]
         *
         * @return return effect volume
         */
        virtual double getEffectsVolume();

        /**
         * set audio effect volume
         *
         * @param [in] volume
         *        in the range of [0..100]
         * @return return 0 if success or an error code
         */
        virtual int setEffectsVolume(double volume);

        /**
         * start playing local audio effect specified by file path and other parameters
         *
         * @param [in] soundId
         *        specify the unique sound id
         * @param [in] filePath
         *        specify the path and file name of the effect audio file to be played
         * @param [in] loop
         *        whether to loop the effect playing or not, default value is false
         * @param [in] pitch
         *        frequency, in the range of [0.5..2.0], default value is 1.0
         * @param [in] pan
         *        stereo effect, in the range of [-1..1] where -1 enables only left channel, default value is 0.0
         * @param [in] gain
         *        volume, in the range of [0..100], default value is 100
         * @return return 0 if success or an error code
         */
        virtual int playEffect (int soundId, const char* filePath,
                   bool loop = false,
                   double pitch = 1.0,
                   double pan = 0.0,
                   double gain = 100.0);

        /**
         * stop playing specified audio effect
         *
         * @param [in] soundId
         *        specify the unique sound id
         * @return return 0 if success or an error code
         */
        virtual int stopEffect(int soundId);

        /**
         * stop all playing audio effects
         *
         * @return return 0 if success or an error code
         */
        virtual int stopAllEffects();

        /**
         * preload a compressed audio effect file specified by file path for later playing
         *
         * @param [in] soundId
         *        specify the unique sound id
         * @param [in] filePath
         *        specify the path and file name of the effect audio file to be preloaded
         * @return return 0 if success or an error code
         */
        virtual int preloadEffect(int soundId, const char* filePath);

        /**
         * unload specified audio effect file from SDK
         *
         * @return return 0 if success or an error code
         */
        virtual int unloadEffect(int soundId);

        /**
         * pause playing specified audio effect
         *
         * @param [in] soundId
         *        specify the unique sound id
         * @return return 0 if success or an error code
         */
        virtual int pauseEffect(int soundId);

        /**
         * pausing all playing audio effects
         *
         * @return return 0 if success or an error code
         */
        virtual int pauseAllEffects();

        /**
         * resume playing specified audio effect
         *
         * @param [in] soundId
         *        specify the unique sound id
         * @return return 0 if success or an error code
         */
        virtual int resumeEffect(int soundId);

        /**
         * resume all playing audio effects
         *
         * @return return 0 if success or an error code
         */
        virtual int resumeAllEffects();

        /**
         * set voice only mode(e.g. keyboard strokes sound will be eliminated)
         *
         * @param [in] enable
         *        true for enable, false for disable
         * @return return 0 if success or an error code
         */
        virtual int setVoiceOnlyMode(bool enable);

        /**
         * place specified speaker's voice with pan and gain
         *
         * @param [in] uid
         *        speaker's uid
         * @param [in] pan
         *        stereo effect, in the range of [-1..1] where -1 enables only left channel, default value is 0.0
         * @param [in] gain
         *        volume, in the range of [0..100], default value is 100
         * @return return 0 if success or an error code
         */
        virtual int setRemoteVoicePosition(unsigned int uid, double pan, double gain);

        /**
         * change the pitch of local speaker's voice
         *
         * @param [in] pitch
         *        frequency, in the range of [0.5..2.0], default value is 1.0
         * @return return 0 if success or an error code
         */
        virtual int setLocalVoicePitch(double pitch);
    private:
        IRtcEngineForGaming *mEngine;
    };

    class IRtcEngineForGaming
    {
    private:
        IRtcEngineForGaming(const char *appId);
        virtual ~IRtcEngineForGaming();

        IGamingRtcEngineEventHandler *mEventHandler;
        
        IAudioEffectManager mAudioManager;

    public:
        static IRtcEngineForGaming *getEngine(const char *appId);
        static void destroy();
        static IRtcEngineForGaming *QueryEngine();

        /**
         * get the version information of the SDK
         *
         * @return return the version string(in char format)
         */
        static const char* getVersion();

        /**
        * get the error description of the SDK (not supported any more)
        * @param [in] code
        *        the error code
        * @return return the error description string in char format
        */
        static const char* getErrorDescription(int code);

        /**
         * set customized callback for SDK, you can set once and only after SDK intialized
         *
         * @return return void
         */
        virtual void setEventHandler(IGamingRtcEngineEventHandler* handler);

        /**
         * Set the channel profile: such as communication, live broadcasting, game free mode, game command mode
         *
         * @param profile the channel profile
         * @return return 0 if success or an error code
         */
        virtual int setChannelProfile(CHANNEL_PROFILE_TYPE profile);

        /**
         * Set the role of user: such as broadcaster, audience
         *
         * @param role the role of client
         * @param permissionKey the permission key to apply the role
         * @return return 0 if success or an error code
         */
        virtual int setClientRole(CLIENT_ROLE_TYPE role, const char* permissionKey);

        /**
         * set the log information filter level
         *
         * @param [in] filter
         *        the filter level
         * @return return 0 if success or an error code
         */
        virtual int setLogFilter(unsigned int filter);

        /**
         * set path to save the log file
         *
         * @param [in] filePath
         *        the .log file path you want to saved
         * @return return 0 if success or an error code
         */
        virtual int setLogFile(const char* filePath);

        /**
         * get IAudioEffectManager object
         *
         * @return return IAudioEffectManager object associated with current rtc engine
         */
        virtual IAudioEffectManager* getAudioEffectManager();

        /**
         * set parameters of the SDK
         *
         * @param [in] parameters
         *        the parameters(in json format)
         * @return return 0 if success or an error code
         */
        virtual int setParameters(const char* parameters);
        
        int setParameter (const char *key, int value);
        int setParameter (const char *key, double value);
        int setParameter (const char *key, bool value);
        int getParameterInt(const char *parameter, const char *args);
        
        /**
         * get parameters of the SDK
         *
         * @param [in] parameters
         *        the parameters(in json format)
         * @param [in] args
         * @return ascii string which caller should free() it later
         */
        virtual int getParameter(char *buf, int bufSize, const char *parameter, const char *args);

        /**
         * enable audio function, which is enabled by deault.
         *
         * @return return 0 if success or an error code
         */
        virtual int enableAudio();

        /**
         * disable audio function
         *
         * @return return 0 if success or an error code
         */
        virtual int disableAudio();

        /**
         * mute/unmute the local audio stream capturing
         *
         * @param [in] mute
         *       true: mute
         *       false: unmute
         * @return return 0 if success or an error code
         */
        virtual int muteLocalAudioStream(bool mute);


        /**
         * mute/unmute all the remote audio stream receiving
         *
         * @param [in] mute
         *       true: mute
         *       false: unmute
         * @return return 0 if success or an error code
         */
        virtual int muteAllRemoteAudioStreams(bool mute);

        /**
         * mute/unmute specified remote audio stream receiving
         *
         * @param [in] uid
         *        the uid of the remote user you want to mute/unmute
         * @param [in] mute
         *       true: mute
         *       false: unmute
         * @return return 0 if success or an error code
         */
        virtual int muteRemoteAudioStream(unsigned int uid, bool mute);

        /**
         * enable / disable speakerphone of device
         *
         * @param speakerphone true: switches to speakerphone. false: switches to headset.
         * @return return 0 if success or an error code
         */
        virtual int setEnableSpeakerphone(bool speakerphone);

        /**
         * set default audio route to speakerphone
         *
         * @param speakerphone true: default to speakerphone. false: default to earpiece for voice chat, speakerphone for video chat
         * @return return 0 if success or an error code
         */
        virtual int setDefaultAudioRouteToSpeakerphone(bool speakerphone);

        /**
         * enable or disable the audio volume indication
         *
         * @param [in] interval
         *        the period of the callback cycle, in ms
         *        interval <= 0: disable
         *        interval >  0: enable
         * @param [in] smooth
         *        the smooth parameter
         * @return return 0 if success or an error code
         */
        virtual int enableAudioVolumeIndication(int interval, int smooth); // in ms: <= 0: disable, > 0: enable, interval in ms

        /**
         * adjust recording signal volume
         *
         * @param [in] volume range from 0 to 400
         * @return return 0 if success or an error code
         */
        virtual int adjustRecordingSignalVolume(int volume); // [0, 400]: e.g. 50~0.5x 100~1x 400~4x

        /**
         * adjust playback signal volume
         *
         * @param [in] volume range from 0 to 400
         * @return return 0 if success or an error code
         */
        virtual int adjustPlaybackSignalVolume(int volume); // [0, 400]

        /**
         * mix microphone and local audio file into the audio stream
         *
         * @param [in] filePath
         *        specify the path and file name of the audio file to be played
         * @param [in] loopback
         *        specify if local and remote participant can hear the audio file.
         *        false (default): both local and remote party can hear the the audio file
         *        true: only the local party can hear the audio file
         * @param [in] replace
         *        false (default): mix the local microphone captured voice with the audio file
         *        true: replace the microphone captured voice with the audio file
         * @param [in] cycle
         *        specify the number of cycles to play
         *        -1, infinite loop playback
         * @param [in] playTime (not support)
         *        specify the start time(ms) of the audio file to play
         *        0, from the start
         * @return return 0 if success or an error code
         */
        virtual int startAudioMixing(const char* filePath, bool loopback, bool replace, int cycle, int playTime = 0);

        /**
         * stop mixing the local audio stream
         *
         * @return return 0 if success or an error code
         */
        virtual int stopAudioMixing();

        /**
         * pause mixing the local audio stream
         *
         * @return return 0 if success or an error code
         */
        virtual int pauseAudioMixing();


        /**
         * resume mixing the local audio stream
         *
         * @return return 0 if success or an error code
         */
        virtual int resumeAudioMixing();

        /**
         * adjust mixing audio file volume
         *
         * @param [in] volume range from 0 to 100
         * @return return 0 if success or an error code
         */
        virtual int adjustAudioMixingVolume(int volume);

        /**
         * get the duration of the specified mixing audio file
         *
         * @return return duration(ms)
         */
        virtual int getAudioMixingDuration();

        /**
         * get the current playing position of the specified mixing audio file
         *
         * @return return the current playing(ms)
         */
        virtual int getAudioMixingCurrentPosition();

        /**
         * start recording audio streaming to file specified by the file path
         *
         * @param filePath file path to save recorded audio streaming
         * @param quality encoding quality for the audio file
         * @return return 0 if success or an error code
         */
        virtual int startAudioRecording(const char* filePath, int quality);

        /**
         * stop audio streaming recording
         *
         * @return return 0 if success or an error code
         */
        virtual int stopAudioRecording();

        /**
         * join the channel, if the channel have not been created, it will been created automatically
         *
         * @param [in] channelName
         *        the channel name
         * @param [in] info
         *        the additional information, it can be null here
         * @param [in] uid
         *        the uid of you, if 0 the system will automatically allocate one for you
         * @return return 0 if success or an error code
         */
        virtual int joinChannel(const char* channelName, const char* info, unsigned int uid);

        virtual int joinChannel(const char* channelKey, const char* channelName, const char* info, unsigned int uid);

        virtual int renewChannelKey(const char* channelKey);

        /**
         * leave the current channel
         *
         * @return return 0 if success or an error code
         */
        virtual int leaveChannel();

        virtual void pause();

        virtual void resume();

        /**
         * trigger the SDK event working according to vertical synchronization such as onUpdate(Cocos2d)
         *
         * @return return void
         */
        virtual void poll();

        int getMessageCount ();
    private:
        static std::vector<std::string> splitMsg(const std::string &msg, char delim);
    };

} // namespace rtc
} // namespace agora

/**
* create the Gaming RTC engine object and return the pointer
*/
AGORA_API agora::rtc::IRtcEngineForGaming* AGORA_CALL AgoraRtcEngineForGaming_getInstance(const char *appId);

#endif
