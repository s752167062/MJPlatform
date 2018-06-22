local Item_Speak = class("Item_Speak", require("app.common.NodeBase"))
local SoundMsg_conf = require("app.views.chat.SoundMsg_conf")

local Emoji_conf = {}
Emoji_conf[1] = { endFames = 110    }
Emoji_conf[2] = { endFames = 90     }
Emoji_conf[3] = { endFames = 100    }
Emoji_conf[4] = { endFames = 75     }
Emoji_conf[5] = { endFames = 100    }
Emoji_conf[6] = { endFames = 100    }
Emoji_conf[7] = { endFames = 80     }
Emoji_conf[8] = { endFames = 90     }
Emoji_conf[9] = { endFames = 80     }
Emoji_conf[10] = { endFames = 100   }
Emoji_conf[11] = { endFames = 90    }
Emoji_conf[12] = { endFames = 100   }

-- local SoundMsg_conf = {}
-- SoundMsg_conf[1] = { msg ="真倒霉，一手的红中都被废"                , interval = 3 } 
-- SoundMsg_conf[2] = { msg ="悲了个催，谁能告诉我红中长啥样"    , interval = 5 } 
-- SoundMsg_conf[3] = { msg ="今天真是走运，想啥来啥"                , interval = 3 } 
-- SoundMsg_conf[4] = { msg ="注意了注意了，我要胡牌了"               , interval = 3 } 
-- SoundMsg_conf[5] = { msg ="你中的码也太多了！"              , interval = 3 } 
-- SoundMsg_conf[6] = { msg ="你的牌打得也太好了！"                   , interval = 3 } 
-- SoundMsg_conf[7] = { msg ="一手烂牌臭到底"          , interval = 4 } 
-- SoundMsg_conf[8] = { msg ="不好意思！刚接了电话"             , interval = 3 } 
-- SoundMsg_conf[9] = { msg ="网络有点差，请各位耐心等一等"       , interval = 4 } 
-- SoundMsg_conf[10] = { msg ="快点出啊！我都要睡着了"       , interval = 4 } 


-- --2017/11/13跑的快
-- local SoundMsg_conf_pdk = {}
-- SoundMsg_conf_pdk[1] = { msg ="快一点出啦！", interval = 3 } 
-- SoundMsg_conf_pdk[2] = { msg ="别想太久！" , interval = 5 } 
-- SoundMsg_conf_pdk[3] = { msg ="不好意思,网络太差了！" , interval = 3 } 
-- SoundMsg_conf_pdk[4] = { msg ="不要吵了,有什么好吵的,专心玩游戏吧！" , interval = 3 } 
-- SoundMsg_conf_pdk[5] = { msg ="我炸你的桃花朵朵开！" , interval = 3 } 
-- SoundMsg_conf_pdk[6] = { msg ="炸得好！" , interval = 3 } 
-- SoundMsg_conf_pdk[7] = { msg ="抱歉,有要紧是要离开一下！" , interval = 4 } 
-- SoundMsg_conf_pdk[8] = { msg ="不好意思,我又赢了！" , interval = 3 } 
-- SoundMsg_conf_pdk[9] = { msg ="青山不改,绿水长流,我们明日再战！" , interval = 4 } 



-- --2017/11/13斗地主
-- local SoundMsg_conf_ddz = {}
-- SoundMsg_conf_ddz[1] = { msg ="一个炸弹就翻盘！", interval = 3 } 
-- SoundMsg_conf_ddz[2] = { msg ="这么长的顺子你们见过吗？" , interval = 5 } 
-- SoundMsg_conf_ddz[3] = { msg ="上了牌桌不许走 , 谁先撤谁小狗！" , interval = 3 } 
-- SoundMsg_conf_ddz[4] = { msg ="不好意思 , 刚接了个电话。" , interval = 3 } 
-- SoundMsg_conf_ddz[5] = { msg ="网络有点差 , 请各位耐心等一等。" , interval = 3 } 
-- SoundMsg_conf_ddz[6] = { msg ="快一点出啊 , 我都要睡着了！" , interval = 3 } 
-- SoundMsg_conf_ddz[7] = { msg ="天灵灵地灵灵,神仙难挡我要赢！" , interval = 4 } 
-- SoundMsg_conf_ddz[8] = { msg ="这牌也太散了吧！" , interval = 3 } 

-- --2017/11/29三打哈
-- local SoundMsg_conf_sdh = {}
-- SoundMsg_conf_sdh[1] = { msg ="一张主牌就翻盘！", interval = 3 } 
-- SoundMsg_conf_sdh[2] = { msg ="这么长的拖拉机你们见过吗？" , interval = 5 } 
-- SoundMsg_conf_sdh[3] = { msg ="上了牌桌不许走 , 谁先撤谁小狗！" , interval = 3 } 
-- SoundMsg_conf_sdh[4] = { msg ="不好意思 , 刚接了个电话。" , interval = 3 } 
-- SoundMsg_conf_sdh[5] = { msg ="网络有点差 , 请各位耐心等一等。" , interval = 3 } 
-- SoundMsg_conf_sdh[6] = { msg ="快一点出啊 , 我都要睡着了！" , interval = 3 } 
-- SoundMsg_conf_sdh[7] = { msg ="天灵灵地灵灵,神仙难挡我要赢！" , interval = 4 } 
-- SoundMsg_conf_sdh[8] = { msg ="这牌也太散了吧！" , interval = 3 } 

-- --2017/11/22牛牛将显示头像上面出现的字体
-- local SoundMsg_conf_nn = {}
-- SoundMsg_conf_nn[1] = { msg ="快一点出啦！"  , interval = 3 } 
-- SoundMsg_conf_nn[2] = { msg ="别想太久！"  ,   interval = 5 } 
-- SoundMsg_conf_nn[3] = { msg ="上了牌桌不许走 , 谁先撤谁小狗！" , interval = 3 } 
-- SoundMsg_conf_nn[4] = { msg ="不好意思！刚接了电话。" , interval = 3 } 
-- SoundMsg_conf_nn[5] = { msg ="网络有点差，请各位耐心等一等。"    , interval = 4 } 
-- SoundMsg_conf_nn[6] = { msg ="快一点出啊，我都要睡着了！"   , interval = 3 } 
-- SoundMsg_conf_nn[7] = { msg ="天灵灵地灵灵,神仙难挡我要赢！"  , interval = 4 } 
-- SoundMsg_conf_nn[8] = { msg ="不好意思，我又赢了！" , interval = 4 } 



-- --2017/11/22娄底麻将显示头像上面出现的字体
-- local SoundMsg_conf_ldmj = {}
-- SoundMsg_conf_ldmj[1] = { msg ="不好意思！刚接了电话"  , interval = 3 } 
-- SoundMsg_conf_ldmj[2] = { msg ="网络有点差，请各位耐心等一等"  ,   interval = 5 } 
-- SoundMsg_conf_ldmj[3] = { msg ="快点出啊！我都要睡着了" , interval = 3 } 
-- SoundMsg_conf_ldmj[4] = { msg ="今天真是走运，想啥来啥" , interval = 3 } 
-- SoundMsg_conf_ldmj[5] = { msg ="注意了注意了，我要胡牌了"    , interval = 4 } 
-- SoundMsg_conf_ldmj[6] = { msg ="你中的码也太多了！"   , interval = 3 } 
-- SoundMsg_conf_ldmj[7] = { msg ="你的牌打得也太好了！"  , interval = 4 } 
-- SoundMsg_conf_ldmj[8] = { msg ="一手烂牌臭到底" , interval = 4 } 




function Item_Speak:ctor(dir, pos)

    local game_code = RuleMgr:get_cur_rule_data("SERVER_MODEL")
    local category = RuleMgr:get_room_category_by_sever_model(game_code)

    if category == "phz" then
        Item_Speak.super.ctor(self, "layout/chat/Item_Speak_Phz.csb")
    else
        Item_Speak.super.ctor(self, "layout/chat/Item_Speak.csb")
    end
    
    self.bg = self:findChildByName("img_speakbg")
    self.label = self:findChildByName("txt")
    self.ctn_node = self:findChildByName("ctn_node")
    
    self.dir = dir

    self.pos = pos
end

function Item_Speak:onEnter()
	local p = self:convertToWorldSpace(cc.p(0,0))
	local size = self.bg:getContentSize()
    size = cc.size(size.width*0.7, size.height*0.7) 
    
	--位置确定
	local a = self:getPositionX()
	if display.width / 2 < p.x then
        self.bg:setFlippedX(true)
        self:setPositionX(self:getPositionX()-170)
	    if size.height + p.y > display.height then
            self.bg:setFlippedY(true)
            self.label:setPositionY(53)
            self.ctn_node:setPositionY(53)
            self:setPositionY( -180)
        end 
	end


    if self.dir and self.dir == SITE_DIR.UP or self.pos and self.pos == 3 then
        self.bg:setFlippedY(true)
        self.label:setPositionY(53)
        self.ctn_node:setPositionY(53)
        self:setPositionY( -180)
    end
end

function Item_Speak:onExit()

end

function Item_Speak:onClose()
    self:removeFromParent()
end

function Item_Speak:setFlippe(_needDownPos)
    _needDownPos = _needDownPos or false
    if _needDownPos then
        self.bg:setFlippedY(true)
        self.label:setPositionY(53)
        self.ctn_node:setPositionY(53)
        self:setPositionY( -160)
    end
end

function Item_Speak:setSpeakString( index , sex , types )
    dump("item speak string " .. index)

    index = index * 1
    dump(SoundMsg_conf.gameType)
    local soundMsg = SoundMsg_conf.gameType[types][index]
    if soundMsg ~= nil then
        local msg = soundMsg.msg
        local interval = soundMsg.interval
        self.label:setString(msg) 	
        local name = "/"
        if types == 1 then--斗地主
            name ="/ddz/"
        elseif types == 2 then--跑得快
            name ="/pdk/"
        elseif types == 3 then--牛牛
            name ="/nn/"
        elseif  types == 4 then--湖南麻将
            name ="/ldmj/"
         elseif types == 6 then--三打哈
            name ="/sdh/"
        end
        local effpath = string.format("FuncVoice"..name.."g_chat%d.mp3", index) 
        if sex == 1 then--0女 1男
            effpath = string.format("FuncVoice"..name.."b_chat%d.mp3", index)
        end
        
        audioMgr:playEffect(effpath, false)

        local a1 = cc.DelayTime:create(interval)  
        local a2 = cc.CallFunc:create(function()
                self:onClose()
                end)
        local action = cc.Sequence:create({a1,a2})
        self:runAction(action)
       
    else
        self:onClose()
    end
end
function Item_Speak:setEmoji(index)
    dump("item speak emoji " .. index)
    index = index * 1
    local emoji = Emoji_conf[index]
    if emoji ~= nil then
        local frames = emoji.endFames   
        
        local eNode = display.newCSNode(string.format("layout/emoji/emoji_%02d.csb",index))           
        self.ctn_node:addChild(eNode)
          
        local a1 = cc.CSLoader:createTimeline(string.format("layout/emoji/emoji_%02d.csb",index))
        a1:play("a0",true) 

        local a2 = cc.DelayTime:create(frames/60)-- 延时一段时间删除   
        local a3 = cc.CallFunc:create(function()
                self:onClose()
                end)
        local action = cc.Sequence:create({a2,a3})
        eNode:runAction(a1)
        eNode:runAction(action) 
    else
        self:onClose()
    end
end

function Item_Speak:speakVioce(interval , filename)
    local eNode = display.newCSNode("layout/emoji/item_speakVoice.csb") 
    self.ctn_node:addChild(eNode)

    local a1 = cc.CSLoader:createTimeline("layout/emoji/item_speakVoice.csb")
    a1:play("a0",true) 
    local a2 = cc.DelayTime:create(interval)-- 延时一段时间删除   
    local a3 = cc.CallFunc:create(function()
            self:onClose()
            os.remove(filename)
            end)
    local action = cc.Sequence:create({a2,a3})
    eNode:runAction(a1)
    eNode:runAction(action)
end

return Item_Speak