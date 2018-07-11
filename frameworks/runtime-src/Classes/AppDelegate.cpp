#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"

#include "GameGlobalFun/GameGlobalFunMgr.h"
#include "GameNetMgr/GameNetGlobalFun.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "../AgoraGamingSDK/agoraGameMgr.h"
#endif
#if (CC_TARGET_PLATFORM != CC_PLATFORM_LINUX)
#include "ide-support/CodeIDESupport.h"
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
#include "runtime/Runtime.h"
#include "ide-support/RuntimeLuaImpl.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "WeChatSDKLua.h"
#include "DDSDKLua.h"
//#include "YXSDKLua.h"
#include "AudioRecoderLua.h"
#include "GAME_TOOLSLua.h"
#include "NET_WORKER_Lua.h"
#include "LameAudioRecoderLua.h"
//#include "NowPaySDKLua.h"
#endif


using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif

}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

// If you want to use packages manager to install more packages,
// don't modify or remove this function
static int register_all_packages()
{
    return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();

	GameGlobalFunMgr::getInstance()->bind(L);
	GameNetGlobalFun::getInstance()->bind(L);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    agoraGameMgr::getInstance()->bind(L);
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    //平台脚本
    WeChatSDKLua::getInstance()->bind(L);
    DDSDKLua::getInstance()->bind(L);
//    YXSDKLua::getInstance()->bind(L);
    AudioRecoderLua::getInstance()->bind(L);
    GAME_TOOLSLua::getInstance()->bind(L);
    NET_WORKER_Lua::getInstance()->bind(L);
    LameAudioRecoderLua::getInstance()->bind(L);
//    NowPaySDKLua::getInstance()->bind(L);
#endif
    
    lua_module_register(L);

    register_all_packages();

    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    auto runtimeEngine = RuntimeEngine::getInstance();
    runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
    runtimeEngine->start();
#else
    if (engine->executeScriptFile("src/main.lua"))
    {
        return false;
    }
#endif

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(L, "applicationDidEnterBackground");
    lua_call(L, 0, 0);
    
    Director::getInstance()->stopAnimation();
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(L, "applicationWillEnterForeground");
    lua_call(L, 0, 0);

    Director::getInstance()->startAnimation();
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
