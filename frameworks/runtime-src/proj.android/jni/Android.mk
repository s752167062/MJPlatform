LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := agora-rtc
LOCAL_SRC_FILES := ../../AgoraGamingSDK/libs/Android/$(TARGET_ARCH_ABI)/libagora-rtc-sdk-jni.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := agora-rtc-wrapper
LOCAL_SRC_FILES := ../../AgoraGamingSDK/libs/Android/$(TARGET_ARCH_ABI)/libagoraSdkCWrapper.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../Classes/AppDelegate.cpp \
../../Classes/ide-support/SimpleConfigParser.cpp \
../../Classes/ide-support/RuntimeLuaImpl.cpp \
../../Classes/ide-support/lua_debugger.c \
../../Classes/GameGlobalFun/GameGlobalFunMgr.cpp \
../../Classes/GameNetMgr/DataBuff.cpp \
../../Classes/GameNetMgr/GameNetGlobalFun.cpp \
../../Classes/GameNetMgr/GameSocket.cpp \
../../Classes/GameNetMgr/ToolBASE64.cpp \
../../Classes/Util/HttpDownloader.cpp \
../../Classes/Util/HttpUploadVoice.cpp \
../../AgoraGamingSDK/agoraGameMgr.cpp \
../../AgoraGamingSDK/MyIGamingRtcEngineEventHandler.cpp \
hellolua/main.cpp


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes \
					$(LOCAL_PATH)/../../../AgoraGamingSDK/include

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
LOCAL_STATIC_LIBRARIES += cocos2d_simulator_static

LOCAL_SHARED_LIBRARIES := agora-rtc agora-rtc-wrapper
# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

# $(call import-module,scripting/lua-bindings/proj.android)
# $(call import-module,tools/simulator/libsimulator/proj.android)
# $(call import-module,./curl/prebuilt/android) 

# #prebuilt mk
$(call import-module,scripting/lua-bindings/proj.android/prebuilt-mk)
$(call import-module,tools/simulator/libsimulator/proj.android/prebuilt-mk)
$(call import-module,./curl/prebuilt/android)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
