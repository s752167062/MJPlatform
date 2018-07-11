GameChess-desktop

直接联调,需要把Library Search Paths修改为
LIBRARY_SEARCH_PATHS = "$(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)"

使用静态库链接,需要修改为
LIBRARY_SEARCH_PATHS = "$(SRCROOT)/../../../libs/cocos2dx/mac/Debug"
LIBRARY_SEARCH_PATHS = "$(SRCROOT)/../../../libs/cocos2dx/mac/Release"

##########################################################################

GameChess-mobile
直接联调,需要把Library Search Paths修改为
LIBRARY_SEARCH_PATHS = "$(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)"

使用静态库链接,需要修改为
Debug
$(SRCROOT)/../WeChatSDK 
$(SRCROOT)/../VoiceConvert/lib 
$(SRCROOT)/../../cocos2d-x/external/curl/prebuilt/ios 
$(SRCROOT)/../Lamemp3/lib 
"$(SRCROOT)/../../../libs/cocos2dx/ios/Debug-iphoneos"

Release
$(SRCROOT)/../WeChatSDK 
$(SRCROOT)/../VoiceConvert/lib 
$(SRCROOT)/../../cocos2d-x/external/curl/prebuilt/ios 
"$(SRCROOT)/../../../libs/cocos2dx/ios/Release-iphoneos" 
$(SRCROOT)/../Lamemp3/lib
