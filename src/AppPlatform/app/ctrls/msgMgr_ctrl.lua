--@文本提示信息
--@Author 	sunfan
--@date 	2017/05/12
local MsgMgr = class("MsgMgr")

function MsgMgr:ctor(params)
	self._msgs = {}
	self._msgs["CONNECT_FAIL"] 				= "连接服务器失败"
	self._msgs["LOGING"] 					= "正在登录,请稍候"
	self._msgs["RE_LOGING"] 				= "正在重新登录,请稍候"
	self._msgs["RE_EMPOWER"] 				= "授权出错,请重新授权开始游戏"
	self._msgs["GET_INFO_FAIL"] 			= "登陆失败，请稍后重新登陆"
	self._msgs["RE_CONNECT_FAIL"] 			= "重连失败,请重新登录游戏"
	self._msgs["SERVER_MSG_ERROR"] 			= "大厅信息接收失败,请重新登录游戏"
	self._msgs["SELECT_LINE_FAIL"] 			= "没有可用网络或服务器无响应,请确保在正常的网络环境下游戏"
	self._msgs["SERVER_ERROR"] 				= "服务器内部错误"
	self._msgs["USER_CANCEL_WX_LOGIN_MSG"] 	= "微信登录取消!"
	self._msgs["LINE_LIANTONG"] 			= "联通"
	self._msgs["LINE_DIANXIN"] 				= "电信"
	self._msgs["LINE_YIDONG"] 				= "移动"
	self._msgs["LINE_YOUXIDUN"] 			= "游戏遁"
	self._msgs["LINE_NO"] 					= "无线路"
	self._msgs["SOCKET_CREATE"] 			= "创建了一个socket->"
	self._msgs["HALL_SEND_HEARTBEAT"] 		= "大厅发送心跳序列:"
	self._msgs["HALL_RECIVE_HEARTBEAT"] 	= "大厅接收心跳序列:"
	self._msgs["ROOM_SEND_HEARTBEAT"] 		= "房间发送心跳序列:"
	self._msgs["ROOM_RECIVE_HEARTBEAT"] 	= "房间接收心跳序列:"
	self._msgs["CLUB_SEND_HEARTBEAT"] 		= "俱乐部发送心跳序列:"
	self._msgs["CLUB_RECIVE_HEARTBEAT"] 	= "俱乐部接收心跳序列:"
	self._msgs["RECIVE_PROTOCOL"] 			= "收到协议:"
	self._msgs["SEND_PROTOCOL"] 			= "发送协议:"
	self._msgs["HALL_SOCKET_RETRY"] 		= "大厅socket重连:"
	self._msgs["ROOM_SOCKET_RETRY"] 		= "房间socket重连:"
	self._msgs["CLUB_SOCKET_RETRY"] 		= "俱乐部socket重连:"
	self._msgs["HALL_SOCKET_DESTORY"] 		= "大厅socket销毁:"
	self._msgs["ROOM_SOCKET_DESTORY"] 		= "房间socket销毁:"
	self._msgs["CLUB_SOCKET_DESTORY"] 		= "俱乐部socket销毁:"
	self._msgs["MSG_RECONNET"] 				= "加载中,请稍候!"
	self._msgs["JUMP_TO_HALL"] 				= "加载中,请稍候!"
	self._msgs["JUMP_TO_ROOM"] 				= "正在加载资源..."
	self._msgs["JUMP_TO_CLUB"] 				= "加载中,请稍候!"
	self._msgs["JUMP_TO_ROOM_FAIL"] 		= "前往房间失败,请点击确定重新登陆!"
	self._msgs["JUMP_TO_HALL_FAIL"] 		= "前往大厅失败,请点击确定重新登陆!"
	self._msgs["JUMP_TO_CLUB_FAIL"] 		= "前往俱乐部失败,请点击确定重新登陆!"
	self._msgs["JUMP_TO_ROOM_FAIL_MSG"] 	= "前往房间失败,请重新登陆!"
	self._msgs["JUMP_TO_HALL_FAIL_MSG"] 	= "前往大厅失败,请重新登陆!"
	self._msgs["JUMP_TO_CLUB_FAIL_MSG"] 	= "前往俱乐部失败,请重新登陆!"
	self._msgs["HALL_CONNECT_CLOSED"] 		= "大厅连接已断开,请点击确定重新登陆!"
	self._msgs["ROOM_CONNECT_CLOSED"] 		= "房间连接已断开,请点击确定重新登陆!"
	self._msgs["CLUB_CONNECT_CLOSED"] 		= "俱乐部连接已断开,请点击确定重新登陆!"
	self._msgs["WARNING_LV1"] 				= "您现在网络不佳,请在良好网络环境下游戏!"
	self._msgs["WARNING_LV2"] 				= "您现在网络不佳,请在良好网络环境下游戏!"
	self._msgs["WARNING_LV3"] 				= "您现在网络不佳,请在良好网络环境下游戏!"
	self._msgs["WARNING_LV4"] 				= "您现在网络不佳,请在良好网络环境下游戏!"
	self._msgs["WARNING_LV5"] 				= "您现在网络不佳,请在良好网络环境下游戏!"
	self._msgs["HEARTBEAT_OUTOFTIME"] 		= "正在连接服务器."--"CODE:10001"--"心跳超时"
	self._msgs["PROTOCOL_OUTOFTIME"] 		= "正在连接服务器.."--"CODE:10002"--"协议校验超时"
	self._msgs["BUILD_NET_OUTOFTIME"] 		= "正在连接服务器..."--"CODE:10003"--"建立网络链接超时"
	self._msgs["NONET_CANUSE_OUTOFTIME"] 	= "正在连接服务器...."--"CODE:10004"--"没有可用网络或者服务器不可到达"
	self._msgs["RECIVE_PROTOCOL_FAIL"] 		= "正在连接服务器....."--"CODE:10005"--"协议接收失败"
	self._msgs["CHANGE_NET_RECONNECT"] 		= "正在连接服务器......"--"CODE:10006"--"切换网络重连"
	self._msgs["GAME_CHANGE_LINE"] 			= "正在切换线路!"
--- 以上为网络部分信息提示，随时全局替换，其余业务提示请勿写入
	self._msgs["WAIT_ROOM_DATA_RELEASE"] 	= "临时房间数据被占用中，需要先等待释放"
	self._msgs["ROOM_ID"] 					= "房间号: %d"
	self._msgs["ROUND"] 					= "局数: "
	self._msgs["HOLDER"] 					= "房主: %d"
	self._msgs["CREATE_ROOM_ROUND"] 		= "%d局(%d房卡)"
	self._msgs["CREATE_ROOM_ROUND_AA"] 		= "%d局(每人%d房卡)"
	self._msgs["CREATE_ROOM_PLAYER"] 		= "%d人"
	self._msgs["CREATE_ROOM_MA"] 			= "%d码"
	self._msgs["CREATE_ROOM_ZHA"] 			= "%d炸"
	self._msgs["DOT"]						= "、"
	self._msgs["DELETE_NO_HANDLER_EVENT"] 	= "事件错误,删除未处理事件:"
	self._msgs["MSG_NO_TYPE_STATE"] 		= "处理无类型状态:"
	self._msgs["TIMER_DELETE_FAIL"] 		= "%s中的定时器没有删除"
	self._msgs["CARDS_DATA_ERROR"] 			= "牌数据错误"
	self._msgs["RESULT_DATA"] 				= "结算数据"
	self._msgs["EXIT_ROOM_SUCCESS"]			= "退出房间成功"
	self._msgs["EXIT_ROOM_FAIL"]			= "退出房间失败"
	self._msgs["ERROR_DATA"]				= "数据错误%s"
	self._msgs["ERROR_CARDS_TYPE"]			= "错误的牌型"
	self._msgs["ERROR_GO_HALL"]				= "房间异常,返回大厅"
	self._msgs["SERVER_REFUSE"]				= "服务器拒绝了你的请求"
	self._msgs["GO_BACK_HALL"]				= "房间解散，返回大厅"
	self._msgs["GOBACK_HALL"]				= "返回大厅"
	self._msgs["PLAYER_ID"]					= "玩家ID:%d"
	self._msgs["SHARE_ROOM_ID"]				= "房间号【%d】"
	self._msgs["SHARE_MSG"]					= "我在[湖南麻将]开了%d局%d人房间，湖南的%s，快来玩吧！"
	self._msgs["SHARE_ROOMMSG"]			    = "我在[湖南麻将]开了%d局%d人房间，湖南的%s，%s, 快来玩吧！"
	self._msgs["SHARE_DOUGONGNIU"]			= "我在[湖南麻将]开了%d轮庄%d人房间，湖南的%s-%s，快来玩吧！"
	self._msgs["SHARE_DOUNIU"]				= "我在[湖南麻将]开了%d局%d人房间，湖南的%s-%s，快来玩吧！"
	self._msgs["SHARE_TITLE"]				= "趣牌湖南麻将"
	self._msgs["SHARE_MSG2"]				= "一把趣牌，好运自来! \n %s 在趣牌湖南麻将等你来玩！"
	self._msgs["SHOP_FANGKA"]				= "房卡"
	self._msgs["SHOP_JINBIKA"]				= "金币"
	-- self._msgs["SHOP_ITEM_INFO"]			= "可创建任意模式玩法房间，1张房卡可玩8局（棋牌10局）"
	-- self._msgs["SHOP_GOLD_INFO"]			= "可用于金币场，根据不同金币场消耗不同的金币数量"
	self._msgs["SHOP_ITEM_INFO"]			= "可用于创建房间"
	self._msgs["SHOP_GOLD_INFO"]			= "可用于金币场消耗"
	self._msgs["USERAGREEMENT"] 			= "用户使用协议"
	self._msgs["GONGGAO"] 					= "公    告"
	self._msgs["CANCEL"] 					= "取消"
	self._msgs["SURE"] 						= "确定"
	self._msgs["GOLD_MATCH_TIPS1"] 			= "金币数高于进场数，请移步去挑战其他游戏场。"
	self._msgs["GOLD_MATCH_TIPS2"]			= "你的金币不足，请前往商城购买金币后继续游戏。"
	self._msgs["GOLD_MATCH_TIPS3"]			= "匹配时间过长，请重新匹配"
	self._msgs["AUTO_MATCH"]				= "自动匹配"
	self._msgs["CANCEL_MATCH"]				= "取消匹配"
	self._msgs["AGAIN_MATCH"]				= "重新匹配"
	self._msgs["GOLD_MATCH_OUTROOM_TIPS"]   = "牌局中，不能退出！"
	self._msgs["VIDEO_TIPS1"]				= "录像数据数据解析或下发出错"
	self._msgs["VIDEO_TIPS2"]				= "收到录像数据"
	self._msgs["GIVEUP_HU"]					= "确定要放弃胡牌吗?"
	self._msgs["GOLD_MATCH_LIMIT"]			= "%s - %s 金币"
	self._msgs["GOLD_MATCH_LIMIT_MAX"]		= "%s 以上"
	self._msgs["GOLD_MATCH_LIMIT_MIN"]		= "低于 %s"
	self._msgs["GOLD_MATCH_DIFEN"]			= "底分%d"
	self._msgs["GET_FANGKA_TIPS"]			= "获得房卡 :%s 张"
	self._msgs["GET_GOLD_TIPS"]				= "获得金币 :%s 个"
	self._msgs["DISMISS_CONFIRM1"]			= "确定申请解散房间吗？"
	self._msgs["DISMISS_CONFIRM2"]			= "确定申请解散房间吗？"
	self._msgs["EXIT_CONFIRM"]				= "确定退出房间吗？"
	self._msgs["DISMISS_ROOM"]				= "解散房间"
	self._msgs["OUT_ROOM"]					= "返回大厅"
	self._msgs["WAIT_OPEN"]					= "敬请期待"
	self._msgs["ROOM_ID"]					= "房号:%s"
	self._msgs["ROOM_CREATE_NAME"]			= "房主:%s"
	self._msgs["ROOM_CREATE_ID"]			= "ID:%s"
	self._msgs["ROOM_WANFA"]				= "玩法:%s"
	self._msgs["WAIT_GIFT_OPEN"]			= "礼物系统，暂未开放！"
	self._msgs["SHARE_TITLE_DEFAULT"]		= "一把趣牌，好运自来！"
	self._msgs["SHARE_DESC_DEFAULT"]		= "玩家%s 在趣牌湖南麻将等你来玩"
	self._msgs["SHIMING_TIPS"]				= "请填写正确信息"
	self._msgs["GOLDMATCH_EXITROOM_TIPS"]	= "金币场不允许中途退出"
	self._msgs["GOLDMATCH_HELP"]			= "金币场规则"
	self._msgs["REQUIRE_CAPITULATE"]        = "确定发起投降吗？"

	self._msgs["AAKaifang"]					= "AA开房"


	--##############代开房
	self._msgs["WAIT_PLAYER"]				= "等待玩家"
	self._msgs["SHARE_ROOM"]				= "分享房间"
	self._msgs["DIMISS_ROOM"]				= "解散房间"
	self._msgs["ENTER_ROOM"] 				= "进入房间"
	self._msgs["CONTINUE_CREATE_ROOM"] 		= "继续创建"
	self._msgs["CREATE_ROOM_SUCCESS"] 		= "创建成功，房间号【%s】"
	self._msgs["YIJIESHU"]					= "已结束"
	self._msgs["JINXINZHONG"]				= "进行中"
	self._msgs["AGENT_PLAYER_NUM"]			= "人数: %d/%d"
	self._msgs["AGENT_ROUND_NUM"]			= "局数: %d/%d" 
	self._msgs["AGENT_ROUND_NUM2"]			= "牌局(%d/%d)"
	self._msgs["AGENT_REMAIN_TIME"]			= "剩余时间: %s"
	self._msgs["AGENT_ROUND_DOUGONGNIU"]	= "局数: %d轮庄" 
	self._msgs["AGENT_SHARE_MSG"]			= "我在[湖南麻将]开了%d局%d人房间,%s，快来一起玩吧!"
	--##############红中游戏
	self._msgs["ZHAMA1"]					= "一码全中"
	self._msgs["ZHAMA2"]					= "扎%d个码"
	self._msgs["CURROUNDPASS"]				= "%d/%d"
	self._msgs["SURPLUSNUM"]				= "%d"
	self._msgs["ISOVERWAIT"]				= "比赛未结束，请耐心等待其他玩家!"
	self._msgs["ISOVERWAITREMAIN"]			= "(还剩%d桌)"
	self._msgs["HUTXT1"]					= "放杠自摸"
	self._msgs["HUTXT2"]					= "自摸"
	self._msgs["HUTXT3"]					= "放杠抢杠胡"
	self._msgs["HUTXT4"]					= "抢杠胡"
	self._msgs["HUTXT5"]					= "抓炮胡"
	self._msgs["FANGGANG"]					= "放杠"
	self._msgs["ROOMID"]					= "房间号码:%06d"
	self._msgs["JIEGANG"]					= "接杠"
	self._msgs["GONGGANG"]					= "公杠"
	self._msgs["ANGANG"]					= "暗杠"
	self._msgs["MALE"]						= "男"
	self._msgs["FEMALE"]					= "女"
	self._msgs["MILUOHONGZHONG"]			= "汨罗红中"
	self._msgs["HUQIDUI"]					= "胡七对"
	self._msgs["KEPANGGUAN"]				= "可旁观"
	--##############红中游戏

	--##############怀化麻将
	self._msgs["HHMJ_YES"]					= "是"	
	self._msgs["HHMJ_NO"]					= "否"
	self._msgs["HHMJ_FEN"]			 		= "%d分"	
	self._msgs["HHMJ_BUKEYI"]				= "不可以"	
	self._msgs["HHMJ_KEYI"]					= "可以"	
	self._msgs["HHMJ_BAOSANJIA"]			= "包三家"	
	self._msgs["HHMJ_WANFA"]				= "玩法"
	self._msgs["HHMJ_KEZHUAPAO"]			= "可抓炮"
	self._msgs["HHMJ_BUKEZHUAPAO"]			= "不可抓炮"
	self._msgs["HHMJ_YOUDAHU"]				= "有大胡"
	self._msgs["HHMJ_KEQIANGGANGHU"]		= "可抢杠胡"
	self._msgs["HHMJ_BUKEQIANGGANGHU"]		= "不抢杠胡"
	self._msgs["HHMJ_YIGANGDUOQIANG"]		= "一杠多抢"
	self._msgs["HHMJ_QIANGGANGHUFANBEI"]	= "抢杠胡翻倍"
	self._msgs["HHMJ_QIANGGANGHUBAOSANJIA"]	= "抢杠胡翻三倍"
	self._msgs["HHMJ_PINGHULUANJIANG"]		= "平胡乱将"
	self._msgs["HHMJ_PINGHU258ZUOJIANG"]	= "平胡258做将"
	self._msgs["HHMJ_BUZHAMA"]				= "不扎码"
	self._msgs["HHMJ_ZHA1MA"]				= "扎1码"
	self._msgs["HHMJ_HUANGJUHUANGGANG"]		= "黄局黄杠"
	--##############怀化麻将

	--##############黔城麻将
	self._msgs["HHQC_HUANGJUBUHUANGGANG"]		= "黄局不黄杠"
	self._msgs["HHQC_CREATE_ROOM_ROUND"]		= "%d局(房卡*%d)"
	--##############长沙麻将
	self._msgs["CSMJ_DANGANG"]				= "单杠"	
	self._msgs["CSMJ_SHUANGGANG"]			= "双杠"	
	self._msgs["CSMJ_GANGPAI"]				= "杠牌(可吃碰杠)"	
	self._msgs["CSMJ_QUANQIUREN"]			= "全求人"	
	self._msgs["CSMJ_KEDAIPIAO"]			= "可带飘"	
	self._msgs["CSMJ_CHENGFASUANNIAO"]		= "乘法算鸟"	
	self._msgs["CSMJ_JIAFASUANNIAO"]		= "加法算鸟"	
	self._msgs["CSMJ_YINIAOYIFEN"]			= "一鸟一分"	
	self._msgs["CSMJ_NIAO"]					= "%d鸟"	

	--##############长沙麻将

	--########################晃晃麻将#################
	self._msgs["HUANGHUANGMJ_QIANGGANGHU"]			= "抢杠胡"
	self._msgs["HUANGHUANGMJ_YIGANGDUOQIANG"]		= "一杠多抢"
	self._msgs["HUANGHUANGMJ_DJWZ"]					= "自摸下局对家为庄"
	self._msgs["HUANGHUANGMJ_XJWZ"]					= "自摸下局下家为庄"
	self._msgs["HUANGHUANGMJ_MJJF"]					= "每局加分"
	self._msgs["HUANGHUANGMJ_SJJF"]					= "四局加分"
	self._msgs["HUANGHUANGMJ_DF"]					= "定分"
	self._msgs["HUANGHUANGMJ_ONLYZIMO"]				= "只能自摸胡"
	self._msgs["DIANDIAN"]							= "点点"
	self._msgs["HUANGHUANG"]						= "晃晃"
	self._msgs["ZHULONGZI"]							= "猪笼子"
	--########################晃晃麻将#################

	--########################斗地主#################
	self._msgs["CREATE_ROOM_JIAOFEN"] 		= "叫分"
	self._msgs["CREATE_ROOM_JIAODIZHU"] 	= "叫地主"
	self._msgs["CREATE_ROOM_JDDDZ"] 		= "经典斗地主"
	self._msgs["CREATE_ROOM_HLDDZ"] 		= "欢乐斗地主"
	self._msgs["CREATE_ROOM_LZDDZ"] 		= "癞子斗地主"
	self._msgs["CREATE_CARD_FAIL"] 			= "创建扑克牌失败 value = %s"
	self._msgs["DDZ_LAIZI_GROUP"]			= "可能的牌型:"
	self._msgs["DDZ_REC_PROTOCOL"]			= "收到斗地主协议 proId:%s"
	--########################斗地主#################
	--########################跑得快#################
	self._msgs["PDK_REC_PROTOCOL"]			= "收到跑得快协议 proId:%s"
	self._msgs["DTZ_REC_PROTOCOL"]			= "收到 打筒子 协议 proId:%s"
	self._msgs["BBT_REC_PROTOCOL"]			= "收到 半边天 协议 proId:%s"
	self._msgs["CREATE_ROOM_JINGDIAN"] 		= "经典"
	self._msgs["CREATE_ROOM_15ZHANG"] 		= "15张"
	self._msgs["CREATE_ROOM_SIREN"] 		= "四人" 
	self._msgs["CREATE_ROOM_SHOW_PAISHU"] 	= "显示牌数"
	self._msgs["CREATE_ROOM_SHOW_PAISHU_NO"]= "不显示牌数"  
	self._msgs["CREATE_ROOM_KCZD"]	 		= "可拆炸弹"
	self._msgs["CREATE_ROOM_SJH3"] 			= "首局先出黑桃3"
	self._msgs["CREATE_ROOM_1DECK"] 		= "一副牌"
	self._msgs["CREATE_ROOM_2DECK"] 		= "两副牌"
	self._msgs["MASTER_LEAVE_ROOM"] 		= "您确定解散当前房间吗？"
	self._msgs["NOT_MASTER_LEAVE_ROOM"] 	= "您确定离开当前房间吗？"

	--########################跑得快#################
	-- --########################三打哈#################
	self._msgs["SDH_REC_PROTOCOL"]			= "收到三打哈协议 proId:%s"
	self._msgs["CREATE_ROOM_SIREN"] 		= "四人"  
	self._msgs["CREATE_ROOM_ASK_SURRENDER"]	= "询问投降"
	self._msgs["CREATE_ROOM_BAOFU"] 		= "报副提醒"
	self._msgs["CREATE_ROOM_CHECK_CARD"] 	= "可查牌"
	self._msgs["CREATE_ROOM_SJDC"] 			= "双进单出"
	self._msgs["CREATE_ROOM_LIMIT_LEVEL"] 	= "限级(最多4倍)"
	self._msgs["CREATE_ROOM_LIMIT_LEVEL_NO"]= "不限级(无限制)"
	-- --########################三打哈#################


	--##############郴州桂东麻将##############
	self._msgs["MAIMASUANFEN"]				= "买码算分"
	self._msgs["MAIMASUANFEN1"]				= "一码一分"
	self._msgs["MAIMASUANFEN2"]				= "一码翻倍"
	self._msgs["QUANQIUREN"]				= "全求人(全开放)"	
	--##############郴州桂东麻将##############
	--#############服务器返回错误######################
	--@key : error_id
	self._msgs[5]							 = "房间不存在，请重新输入"
	--#############服务器返回错误######################

	--########################转转麻将#################
	self._msgs["ZZMJ_DIANPAO"] 				= "点炮胡"                   
	self._msgs["ZZMJ_HU7PAIR"] 				= "可胡七对"                
	self._msgs["ZZMJ_BANKERPLAYERSCORE"] 	= "庄闲(算分)"       
	self._msgs["ZZMJ_PIAO"] 				= "可带飘"                      
	self._msgs["ZZMJ_YIMAQUANZHONG"] 		= "一码全中"
	self._msgs["ZZMJ_ZIMO"] 				= "自摸胡"
	-----##############衡阳鬼麻将#############——-------
	self._msgs["HYG_LGMP"] 					= "留够码牌"
	self._msgs["HYG_BLMP"]					= "不留码牌"
	self._msgs["HYG_SZN"]					= "数字鸟"
	self._msgs["HYG_GZZN"]					= "跟庄抓鸟"
	self._msgs["HYG_ISOUTGUIPAI"]			= "是否出鬼牌吗？"

	--########################娄底麻将#################--
	self._msgs["LDMJ_LIUGOUMAPAI"]          = "留够码牌"
	self._msgs["LDMJ_ZHONGMA1"]             = "中码1分"
	self._msgs["LDMJ_ZHONGMA2"]             = "中码2分"
	self._msgs["LDMJ_HUANGPAIBUHUANGGAN"]   = "黄牌不黄杠"
	self._msgs["LDMJ_ZHUAMA"]               = "抓码"
	self._msgs["LDMJ_NIAO"]                 = "%d鸟"
	self._msgs["CREATE_ROOM_ROUNDMF"] 		= "%d局(免费)"

	--################## 斗牛 #################
	self._msgs["FANBEI_1_RICH"]						 = "牛牛×4,牛九×3,牛七牛八×2"
	self._msgs["FANBEI_2_RICH"]						 = "牛牛×3,牛九×2,牛八×2"	
	self._msgs["tuizhu"] 						 = "闲家获胜后，下局可以将所赢的计分与底注一起下注，最大推注底分为10倍，不可连续推注。"
	self._msgs["AAKaifang_DOUNIU"]			 = "AA支付(每人1房卡)"
	self._msgs["FZKaifang_DOUNIU"]			 = "房主支付(3房卡)"

	--################## gps ip #################
	self._msgs["GPS_1"]						 = "白线有GPS信号"
	self._msgs["GPS_2"]						 = "黑线未发现GPS信号"
	self._msgs["GPS_3"]						 = "红线GPS信号距离100米内"
	self._msgs["IPAlarm_1"]					 = "[%s]IP地址为: "
	self._msgs["IPAlarm_2"]					 = "IP相同"
	self._msgs["IPAlarm_3"]					 = "系统检测到有%s组IP相同的玩家，是否继续游戏?"
	self._msgs["IPAlarm_4"]					 = " IP地址相同,请注意!"
	self._msgs["IPAlarm_5"]					 = "一,二,三,四,五"
	self._msgs["Power_tip1"]			     = "无网络,2G,3G,4G,wifi,未知,有线"

	--################## gps ip #################
	self._msgs["QuickMatch_title"]           = "帮助,赛事规则,排名奖励,比赛详情,比赛结束"
	self._msgs["QuickMatch_noMatch"]           = "当前无比赛"
	self._msgs["QuickMatch_matchNoInTime"]           = "比赛未开始"
	self._msgs["QuickMatch_num"]           = "一,二,三,四,五,六,七,八,九,十"
	self._msgs["QuickMatch_whichNum"]           = "第%s名"
	self._msgs["QuickMatch_standingTxtMJ"]           = "匹配次数,胡牌次数,杠牌次数,大赢家次数,个人排名,个人积分"
	self._msgs["QuickMatch_cardExpend"]           = "(匹配一次需要%s张房卡)！"
	self._msgs["QuickMatch_goldExpend"]           = "(匹配一次需要%s金币)！"
	self._msgs["QuickMatch_limitExit"]           = "快速比赛不允许中途退出"

	--################# 沅江麻将 ##################
	self._msgs["RJMJ_XIYIZIQIAO"] 			 = "喜一字撬"
	self._msgs["RJMJ_KAHUYIZIQIAO"] 		 = "卡胡一字撬"
	self._msgs["RJMJ_BUKEYIQIANGGANGHU"]     = "不可抢杠胡"
	self._msgs["RJMJ_WUXIYIZIQIAO"]	         = "无喜一字撬"
end

--获取文本信息
function MsgMgr:getMsg(key)
	if self._msgs[key] then
		return self._msgs[key]
	end
	return "error msg:"
end

function MsgMgr:getText(key,...)
	-- body
	if self._msgs[key] then
		local data = {...}
		if #data > 0 then
			return string.format(self._msgs[key], ...)
		end
		return self._msgs[key]
	end
	return "error msg:"
end

--弹服务器返回错误提示
--@error:错误信息
function MsgMgr:showError(error)
	local error_msg = ""
	if type(error) == "number" then--代号
		error_msg = self._msgs[error] or "Undefinition error id:" .. error
	elseif type(error) == "string" then--文本
		error_msg = error
	end
	viewMgr:show("message_view"):init(error_msg)
end

--弹出文本信息框
function MsgMgr:showMsg(msg)
	if self._msgs[msg] then
		msg = self._msgs[msg]
	end
	viewMgr:show("message_view"):init(msg)
end

function MsgMgr:showToast(msg, interval)
	local view = viewMgr:isShow("CUIToastMsg")
	if view then
		viewMgr:close("CUIToastMsg")
	end

	viewMgr:show("CUIToastMsg"):show(msg, interval)
end

--弹出文本信息选择框
function MsgMgr:showAskMsg(msg, l_callBack, r_callBack, l_btnTxt, r_btnTxt, close_callBack, showClose)
	viewMgr:show("msgChoose_view"):init(msg,l_callBack,r_callBack, l_btnTxt, r_btnTxt, close_callBack, showClose)
end

--弹出文本信息确认框
function MsgMgr:showConfirmMsg(msg,callBack)
	viewMgr:show("msgConfirm_view",9999):init(msg,callBack)
end

--关闭文本信息选择框
function MsgMgr:closeAskMsg(target)
	if target and target ~= "" then
		local view = viewMgr:isShow("msgChoose_view")
		if view then
			view:closeMsg(target)
		end
	else
		viewMgr:close("msgChoose_view")
	end
end

--关闭文本信息确认框
function MsgMgr:closeConfirmMsg(target)
	if target and target ~= "" then
		local view = viewMgr:isShow("msgConfirm_view")
		if view then
			view:closeMsg(target)
		end
	else
		viewMgr:close("msgConfirm_view")
	end
end

--弹出文本信息提示框
function MsgMgr:showTips(msg)
	if self._msgs[msg] then
		msg = self._msgs[msg]
	end
	viewMgr:show("message_view"):init(msg)
end

--显示网络信息弹出框(网络层专用)
function MsgMgr:showNetMsg(msg,target)
	local view = viewMgr:isShow("netMessage_view")
	cclog("MsgMgr:showNetMsg >>>", msg, target)
	-- cclog(debug.traceback())
	if view then
		view:addMsg(msg,target)
	else
		viewMgr:show("netMessage_view",9999):init(msg,target)
	end
end

--关闭网络信息弹出框(网络层专用)
function MsgMgr:closeNetMsg(target)
	if target and target ~= "" then
		local view = viewMgr:isShow("netMessage_view")
		if view then
			view:closeMsg(target)
		end
	else
		viewMgr:close("netMessage_view")
	end
end

return MsgMgr
