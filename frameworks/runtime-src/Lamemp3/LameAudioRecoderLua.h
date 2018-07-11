//
//  LameAudioRecoderLua.hpp
//  GameChess
//
//  Created by SJ on 2017/6/13.
//
//

#ifndef LameAudioRecoderLua_hpp
#define LameAudioRecoderLua_hpp

#include <stdio.h>
#include "CCLuaEngine.h"

class LameAudioRecoderLua{
    public :
    lua_State* ls;
    static LameAudioRecoderLua* getInstance();
    
    virtual void bind(lua_State* ls);
    
    static int LameStartReocde(lua_State* ls);
    static int LameEndReocde(lua_State* ls);
    static int LamePlayVideo(lua_State* ls);
    static int LameStopPlayVideo(lua_State* ls);
    
    static int LamesetAVAudioSessionCategory(lua_State* ls);
    
};
#endif /* LameAudioRecoderLua_hpp */
