//
//  AudioRecoderLua.hpp
//  GameChess
//
//  Created by SJ on 2017/6/13.
//
//

#ifndef AudioRecoderLua_hpp
#define AudioRecoderLua_hpp

#include <stdio.h>
#include "CCLuaEngine.h"

class AudioRecoderLua{
    public :
    lua_State* ls;
    static AudioRecoderLua* getInstance();
    
    virtual void bind(lua_State* ls);
    
    static int StartReocde(lua_State* ls);
    static int EndReocde(lua_State* ls);
    static int PlayVideo(lua_State* ls);
    static int StopPlayVideo(lua_State* ls);
    
    static int setAVAudioSessionCategory(lua_State* ls);
    
};
#endif /* AudioRecoderLua_hpp */
