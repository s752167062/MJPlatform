
local SoundMsg_conf = {}

SoundMsg_conf[1]  = { msg ="真倒霉，一手的红中都被废"            , interval  = 3 } 
SoundMsg_conf[2]  = { msg ="悲了个催，谁能告诉我红中长啥样"      , interval  = 5 } 
SoundMsg_conf[3]  = { msg ="今天真是走运，想啥来啥"              , interval  = 3 } 
SoundMsg_conf[4]  = { msg ="注意了注意了，我要胡牌了"            , interval  = 3 } 
SoundMsg_conf[5]  = { msg ="你中的码也太多了！"                  , interval  = 3 } 
SoundMsg_conf[6]  = { msg ="你的牌打得也太好了！"                , interval  = 3 } 
SoundMsg_conf[7]  = { msg ="一手烂牌臭到底"           		     , interval  = 4 } 
SoundMsg_conf[8]  = { msg ="不好意思！刚接了电话"                , interval  = 3 } 
SoundMsg_conf[9]  = { msg ="网络有点差，请各位耐心等一等"        , interval  = 4 } 
SoundMsg_conf[10] = { msg ="快点出啊！我都要睡着了"              , interval  = 4 } 

SoundMsg_conf[11] = { msg ="快一点出啦！"					      , interval  = 3 } 
SoundMsg_conf[12] = { msg ="别想太久！"                           , interval  = 5 } 
SoundMsg_conf[13] = { msg ="不好意思,网络太差了！"                , interval  = 3 } 
SoundMsg_conf[14] = { msg ="不要吵了,有什么好吵的,专心玩游戏吧！" , interval  = 3 } 
SoundMsg_conf[15] = { msg ="我炸你的桃花朵朵开！"                 , interval  = 3 } 
SoundMsg_conf[16] = { msg ="炸得好！"                             , interval  = 3 } 
SoundMsg_conf[17] = { msg ="抱歉,有要紧是要离开一下！"            , interval  = 4 } 
SoundMsg_conf[18] = { msg ="不好意思,我又赢了！"                  , interval  = 3 } 
SoundMsg_conf[19] = { msg ="青山不改,绿水长流,我们明日再战！"     , interval  = 4 } 

SoundMsg_conf[20] = { msg ="一个炸弹就翻盘！"                     , interval  = 3 } 
SoundMsg_conf[21] = { msg ="这么长的顺子你们见过吗？"             , interval  = 5 } 
SoundMsg_conf[22] = { msg ="上了牌桌不许走 , 谁先撤谁小狗！"      , interval  = 3 } 
SoundMsg_conf[23] = { msg ="不好意思 , 刚接了个电话。"            , interval  = 3 } 
SoundMsg_conf[24] = { msg ="网络有点差 , 请各位耐心等一等。"      , interval  = 3 } 
SoundMsg_conf[25] = { msg ="快一点出啊 , 我都要睡着了！"          , interval  = 3 } 
SoundMsg_conf[26] = { msg ="天灵灵地灵灵,神仙难挡我要赢！"        , interval  = 4 } 
SoundMsg_conf[27] = { msg ="这牌也太散了吧！"                     , interval  = 3 } 


--2018/1/3新增需求更改内容并且替换之前15条更改为只有十条，即十条怎么下拉都不会误发出去，腾讯棋牌类也是十条的
SoundMsg_conf[30] = { msg ="您太牛啦~"                            , interval  = 3 } 
SoundMsg_conf[31] = { msg ="哈哈~手气真好！"                      , interval  = 5 } 
SoundMsg_conf[32] = { msg ="快点出牌哟~"                          , interval  = 3 } 
SoundMsg_conf[33] = { msg ="今天真高兴!"                          , interval  = 3 } 
SoundMsg_conf[34] = { msg ="这个吃的好！"                         , interval  = 4 } 
SoundMsg_conf[35] = { msg ="您放炮，我不胡。"                     , interval  = 3 } 
SoundMsg_conf[36] = { msg ="不好意思，我有事要先走一步啦！"       , interval  = 4 } 
SoundMsg_conf[37] = { msg ="您的牌打的太好啦！"                   , interval  = 4 } 
SoundMsg_conf[38] = { msg ="大家好！很高兴见到各位。"             , interval  = 4 } 
SoundMsg_conf[39] = { msg ="怎么又断线了？！网络怎么这么差呀！"   , interval  = 4 } 


--2017/11/29三打哈
SoundMsg_conf[40] = { msg ="青山不改，绿水长流，咱们明日再战！"   , interval  = 5 }  
SoundMsg_conf[41] = { msg ="您的牌打得也忒好啦！"                 , interval  = 4 } 

--2017/12/19麻将新增加需求加上七条显示内容
SoundMsg_conf[42] = {msg ="快点出牌咯！"                          , interval  = 3 }
SoundMsg_conf[43] = {msg ="天灵灵地灵灵，来一次好牌行不行？！"    , interval  = 5 }
SoundMsg_conf[44] = {msg ="我一夹菜你就转桌，我一听牌你就自摸。"  , interval  = 3 }
SoundMsg_conf[45] = {msg ="做了一天的最佳炮手。"                  , interval  = 3 }
SoundMsg_conf[46] = {msg ="不要走！决战到天亮。"                  , interval  = 3 }
SoundMsg_conf[47] = {msg ="大家小心，我马上自摸！"                , interval  = 4 }
SoundMsg_conf[48] = {msg ="上家就是冤家，放牌给我吃行不行？"      , interval  = 3 }



SoundMsg_conf.gameType = {}

--斗地主语音
SoundMsg_conf.gameType[1] = {SoundMsg_conf[20],SoundMsg_conf[21],SoundMsg_conf[22],SoundMsg_conf[23],SoundMsg_conf[24]
                             ,SoundMsg_conf[25],SoundMsg_conf[26],SoundMsg_conf[27]}

--跑的快语音
SoundMsg_conf.gameType[2] = {SoundMsg_conf[11],SoundMsg_conf[12],SoundMsg_conf[13],SoundMsg_conf[14],SoundMsg_conf[15]
                             ,SoundMsg_conf[16],SoundMsg_conf[17],SoundMsg_conf[18],SoundMsg_conf[19]}

 --牛牛语音
SoundMsg_conf.gameType[3] = {SoundMsg_conf[11],SoundMsg_conf[12],SoundMsg_conf[22],SoundMsg_conf[23],SoundMsg_conf[24]
                             ,SoundMsg_conf[25],SoundMsg_conf[26],SoundMsg_conf[18]}


--麻将类语音(包含红中即所有的麻将都统一改成十条语音)
SoundMsg_conf.gameType[4] = {SoundMsg_conf[30],SoundMsg_conf[31],SoundMsg_conf[32],SoundMsg_conf[33],SoundMsg_conf[34]
							 ,SoundMsg_conf[35],SoundMsg_conf[36],SoundMsg_conf[37],SoundMsg_conf[38],SoundMsg_conf[39]}


-- --红中语音
-- SoundMsg_conf.gameType[5] = {SoundMsg_conf[1],SoundMsg_conf[2],SoundMsg_conf[3],SoundMsg_conf[4],SoundMsg_conf[5]
--                              ,SoundMsg_conf[6],SoundMsg_conf[7],SoundMsg_conf[8],SoundMsg_conf[9],SoundMsg_conf[10]
--                              ,SoundMsg_conf[42],SoundMsg_conf[43],SoundMsg_conf[44],SoundMsg_conf[45],SoundMsg_conf[46]
--                              ,SoundMsg_conf[47],SoundMsg_conf[48]}


--三打哈语音
SoundMsg_conf.gameType[6] = {SoundMsg_conf[40],SoundMsg_conf[41],SoundMsg_conf[22],SoundMsg_conf[23],SoundMsg_conf[24]
                             ,SoundMsg_conf[25],SoundMsg_conf[26],SoundMsg_conf[27]}

return SoundMsg_conf