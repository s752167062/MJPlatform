--@麻将特效管理类 
--@Author 	longma
--@date 	2017/07/20
--@dec  以后麻将类的特效可以在此添加/修改

local MJNewEffectMgr = {}
-- local PlayFactory = require("app.Common.CUIPlayEff")
-- local CommonEffect = require("app.common.CommonEffect")
local MJEffectF = require("app.common.MJEffectF") --特效帧管理
local MJSoundF  = require("app.common.MJSoundF")  --音效播放

--[[
	初始化特效管理器，设置特效播放节点
]]
-- function MJNewEffectMgr:init(node)
-- 	self.root = node
-- end

--[[
	玩家特效播放位置
]]
local player_pos = {
	[1] = cc.p(0,90),
	[2] = cc.p(-90,50),
	[3] = cc.p(0,-90),
	[4] = cc.p(90,50)
}

local paixin_path = "image/effect/eff_pai_xin/"
local paixin_conf = {
	--key:paixin Id,value:资源路径
	[0] = "pin_hu", --平胡
	[1] = "qi_xiao_dui", --小七对
	[2] = "da_qi_dui", --大七对
	[3] = "qing_yi_se", --清一色
	[4] = "peng_peng_hu", --碰碰胡
	[5] = "gang_shang_hua", --杠上花
	[6] = "13_yao", --十三幺
	[7] = "13_lan", --十三烂
	[8] = "da_diao_che", --大吊车
	[9] = "fu_13_lan", --副十三烂
	[10] = "gang_shang_pao", --杠上炮
	[11] = "hai_di_lao_yuan", --海底捞月
	[12] = "hai_di_pao", --海底跑
	[13] = "hun_yi_se", --混一色
	[14] = "qi_dui", --七对
	[15] = "quan_qiu_ren", --全球人
	[16] = "tian_hu", --天胡
	[17] = "xiao_diao_che", --小吊车
	[18] = "zheng_13_lan", --正十三烂
	[19] = "long_qi_dui", --豪华七对
	[20] = "shuang_long_qi_dui", --双豪七对
	[21] = "chao_long_qi_dui", --超豪七对
	[22] = "men_qing",--门清
	[23] = "pin_hu_qi_xiao_dui", -- 平胡七小对
    [24] = "zi_yi_se", -- 字一色
    [25] = "yao_9", --幺九
    [26] = "zhua_yu",   --抓鱼
    [27] = "tian_ting", --天听

}

-- 获取总共有几种牌型的方法，以后用到牌型的地方 请统一从这里拿 
-- 如果这里没有这个牌型的 请手动添加
function MJNewEffectMgr:getPaiXin()
	return clone(paixin_conf)
end

--{1,2} 1:动画路径 2:胡牌后显示到人物头像上的图的路径
local huPaiTypeConf = {

	[100] = {"layout/effect_mj/eff_new_hu_text.csb"}, -- 胡动画
	[101] = {"layout/effect_mj/eff_new_hu_long.csb"}, -- 胡前奏

	--0流局
	[0]  = {"layout/effect_mj/eff_zimo.csb","image/effect_mj/text/txt_zimo.png"},
	--自摸
	[1]  = {"layout/effect_mj/eff_zimo.csb","image/effect_mj/text/txt_zimo.png"},
	--抢杠胡 
	[2]  = {"layout/effect_mj/eff_qiangganghu.csb","image/effect_mj/text/txt_qiangganghu.png"},
	--点炮
	[3]  = {"layout/effect_mj/eff_zhuapao.csb","image/effect_mj/text/txt_zhuapao.png"}, --需求：点炮特效更换为抓炮
	--抓炮
	[4]  = {"layout/effect_mj/eff_zhuapao.csb","image/effect_mj/text/txt_zhuapao.png"}, 
	--放炮 
	[5]  = {"layout/effect_mj/eff_fangpao.csb","image/effect_mj/text/txt_fangpao.png"},
	--海底捞 
	[6]  = {"layout/effect_mj/eff_haidilao.csb","image/effect_mj/text/txt_haidilao.png"},
	--海底炮 
	[7]  = {"layout/effect_mj/eff_haidipao.csb","image/effect_mj/text/txt_haidipao.png"},
	--杠上炮
	[8]  = {"layout/effect_mj/eff_gangshangpao.csb","image/effect_mj/text/txt_gangshangpao.png"},
	--杠上花
	[9]  = {"layout/effect_mj/eff_gangshanghua.csb","image/effect_mj/text/txt_gangshanghua.png"},
	--一炮多响
	[10] = {"layout/effect_mj/eff_yipaoduoxiang.csb","image/effect_mj/text/txt_yipaoduoxiang.png"},
	--一杠多炮
	[11] = {"layout/effect_mj/eff_yigangduopao.csb","image/effect_mj/text/txt_yigangduopao.png"},
	
			--长沙麻将胡牌类型序号加30
    [31] = {"layout/effect_mj/eff_zimo.csb","image/effect_mj/text/txt_zimo.png"}, -- 自摸
    [32] = {"layout/effect_mj/eff_zhuapao.csb","image/effect_mj/text/txt_zhuapao.png"},-- 抓跑
    [33] = {"layout/effect_mj/eff_qiangganghu.csb","image/effect_mj/text/txt_qiangganghu.png"}, -- 抢杠胡
    [34] = {"layout/effect_mj/eff_fangpao.csb","image/effect_mj/text/txt_fangpao.png"}, -- 放炮
    [35] = {"layout/effect_mj/eff_gangshangpao.csb","image/effect_mj/text/txt_gangshangpao.png"}, -- 被抢杠
	}

function MJNewEffectMgr:getHuPaiTypeConf()
	return clone(huPaiTypeConf)
end 

local ChiPengGangConf = {
	[1] = "layout/effect_mj/eff_chi.csb", --吃
	[2] = "layout/effect_mj/eff_peng.csb",--碰
	[3] = "layout/effect_mj/eff_gang.csb",--杠
	[4] = "layout/effect_mj/eff_diandian.csb",--明杠(晃晃麻将)
	[5] = "layout/effect_mj/eff_huanghuang.csb",--碰杠(晃晃麻将)
	[6] = "layout/effect_mj/eff_zhulongzi.csb",--暗杠(晃晃麻将)
	[7] = "layout/effect_mj/eff_buzhang.csb",   --补张(长沙麻将)
}

-- MJNewEffectMgr.effConf = {}
-- MJNewEffectMgr.effConf[1] = {1,2,3}
-- MJNewEffectMgr.effConf[2] = {1,2,6} 



function MJNewEffectMgr:getChiPengGangConf()
	return clone(ChiPengGangConf)
end

--[[
	胡牌类型动画
	winnrInfo：{
				pos = 1,
				head_pos = cc.p(100,100),
				huType = {1,2,3},
				sex = 1,
				}
]]
function MJNewEffectMgr:showPaiXin(winnerInfo)
	for k,info in pairs(winnerInfo) do
		local pos = info.pos
		local huType = info.huType or -1
		local nilStop = false;

		if huType ~= -1 then
			for i = 1,#huType do
				if paixin_conf[huType[i]] == nil then
					nilStop = true;
				end
			end
		end
		if nilStop == true then
			return
		end

		if not huType  then
				local node = cc.Node:create()
				self.root:addChild(node)
				local start_x = 0
				local length = 0
				local height = 0
				local offset = 20
				for i = 1,#huType do
					local sp = display.newCSNode("layout/effect_mj/eff_paixin.csb")
					node:addChild(sp)
					local textImage = sp:getChildByName("image")
					cclog(paixin_path..paixin_conf[huType[i]]..".png")
					local paixinFrame = display.newSpriteFrame(paixin_path..paixin_conf[huType[i]]..".png")
				    textImage:setSpriteFrame(paixinFrame)
				    textImage:setAnchorPoint(cc.p(0,0.5))

				    local line = sp:getChildByName("line")
				    line:setAnchorPoint(cc.p(0,0.5))
				    
				    sp:setPosition(cc.p(start_x+length,0))
				    local size = textImage:getContentSize()
				    local scale = textImage:getScale()
				    length = length + size.width*scale + offset
				    height = size.height*scale
				    local a1 = cc.FadeIn:create(0.2)
					local a2 = cc.FadeOut:create(0.2)
					local action = cc.Sequence:create({a1,a2})
					sp:runAction(action)
				end
				local Pos = player_pos[pos]
				local nodePos = Pos
				--local nodePos = cc.p(Pos.x-length/2,Pos.y)
				
				local toPos = cc.p(0,0)
				if pos == 1 then
					nodePos = cc.p(Pos.x-length/2,Pos.y+height/2)
					toPos = cc.p(nodePos.x + 100,nodePos.y)
				elseif pos == 2 then
					nodePos = cc.p(Pos.x,Pos.y-length/2)
					node:setRotation(-90)
					toPos = cc.p(nodePos.x ,nodePos.y+100)
				elseif pos == 3 then
					nodePos = cc.p(Pos.x+length/2,Pos.y)
					node:setRotation(180)
					toPos = cc.p(nodePos.x - 100,nodePos.y)
				elseif pos == 4 then
					nodePos = cc.p(Pos.x,Pos.y+length/2)
					node:setRotation(90)
					toPos = cc.p(nodePos.x ,nodePos.y - 100)
				end
				node:setPosition(nodePos)
				local a1 = cc.FadeIn:create(0.2)
				local a2 = cc.FadeOut:create(0.2)
				local a3 = cc.MoveTo:create(0.4,toPos)
				local action = cc.Sequence:create({a1,a2})
				local action1 = cc.Spawn:create({action,a3})
				cclog("dong hua")
				node:runAction(a3)
		end
	end
end

function MJNewEffectMgr:setChildRotation(node,rota)
	local child = node:getChildren()
	for k,node in pairs(child) do
		node:setRotation(rota)
	end
end

-- 播放动画
-- confType 请参考huPaiTypeConf
-- callfunc 回调方法
-- winnerInfo 赢家信息
function MJNewEffectMgr:playEffect(path,callfunc,winnerInfo,target,targetNode,position)
	local params = {}
	params.csb = path
	params.target = target
	params.acname = "a0"
	params.isloop = false
	params.callfunc = callfunc
	params.args = winnerInfo

	local position = position or cc.p(display.cx,display.cy)
	local effect = MJEffectF.new(params,handler(self,self.showPaiXin))
	effect:setPosition(position)
	targetNode:addChild(effect)

	print("longma position ",position.x,position.y)
end 

-- 播放胡牌动画第一阶段
-- huPaiType 胡牌类型
-- winnerInfo 赢家信息
-- target 调用此方法所在的文件object 默认用self
-- target 播放动画的层
function MJNewEffectMgr:playHu(huPaiType,winnerInfo,target,targetNode)
	print("MJNewEffectMgr:playHu")
	local  callfunction = function()
		print("MJNewEffectMgr:playHu 3")--胡牌类型动画
		print(huPaiType)
		self:playHuTypeEffect(huPaiType,winnerInfo,target,targetNode)
	end 

	local callfunc = function()
		print("MJNewEffectMgr:playHu 2")
		local path = huPaiTypeConf[100][1]--胡文字动画
		self:playEffect(path,callfunction,winnerInfo,target,targetNode)
		--MJSoundF:playSound("huwind") 
	end

	--去掉胡牌前奏
	callfunc()

	--local path = huPaiTypeConf[101][1]-- 胡前奏
	--self:playEffect(path,callfunc,winnerInfo,target,targetNode)
	if winnerInfo then 
		for k,info in pairs(winnerInfo) do
			MJSoundF:playSound(info.sex .. "hu")
		end 
	end 
end 

-- 播放胡牌动画第二阶段
-- huPaiType  服务器下发的胡牌类型
-- winnerInfo 赢家信息table
-- target 调用文件的object 默认 self
-- targetNode 要在哪个层上面播放
function MJNewEffectMgr:playHuTypeEffect(huPaiType,winnerInfo,target,targetNode)
	print("MJNewEffectMgr:playHuTypeEffect")
	-- if huPaiType == 3 and winnerInfo and #winnerInfo > 1 then--如果多个玩家赢，并且是抓炮胡牌类型
	-- 	huPaiType = 99--一炮多响
	-- end 

	local  callfunction = function()
		--胡的整个动画流程播放完毕的回调事件
		print("eventMgr:dispatchEvent(\"ZhaMaNotify\",nil)")
		eventMgr:dispatchEvent("ZhaMaNotify",nil)
    end

	local callfunc = function()
		--把胡牌类型的图片标记到玩家头像位置上
		print("MJNewEffectMgr:huTypeMoveToHead")
		MJNewEffectMgr:huTypeMoveToHead(huPaiType,callfunction,winnerInfo,targetNode)
		MJSoundF:playSound("huwind")
	end

	--播放胡牌类型动画
	printInfo("playHuTypeEffect huPaiType = "..huPaiType)
	local path = huPaiTypeConf[huPaiType][1]
	self:playEffect(path,callfunc,winnerInfo,target,targetNode)
end 

-- confType 所需图素的tag 详细请查看huPaiTypeConf
-- callback 回调方法
-- winnerInfo 赢家信息
-- targetNode 要播放动画的层
function MJNewEffectMgr:huTypeMoveToHead(confType,callBack,winnerInfo,targetNode)
	dump(winnerInfo, "MJNewEffectMgr:huTypeMoveToHead  winnerInfo")
	local image = huPaiTypeConf[confType][2]
	local call = false
	for k,info in pairs(winnerInfo) do
		dump(info, "winnerInfo list k:"..k)
		local pos = info.head_pos
		local sp = cc.Sprite:createWithSpriteFrameName(image)
		targetNode:addChild(sp)
		sp:setPosition(cc.p(display.cx,display.cy))
		local a1 = cc.MoveTo:create(0.3,pos)--cc.p(display.cx,display.top))
		local a4 = cc.ScaleTo:create(0.3,0.5)
		local action1 = cc.Spawn:create({a1,a4})
		local a2 = cc.DelayTime:create(0.3)
		local a3 = cc.CallFunc:create(function()
			print("a3 callFunc call:"..tostring(call))
			if not call then 
				callBack() 
				call = true 
			end
		end)
		local action = cc.Sequence:create({action1,a2,a3})
		sp:runAction(action)
		if info.loser_pos ~= nil then --加一次就可以了
			local sp = cc.Sprite:createWithSpriteFrameName("image/effect_mj/text/txt_fangpao.png")
			sp:setScale(0.5)
			sp:setPosition(info.loser_pos)
			targetNode:addChild(sp)
		end
	end
end

--[[
	播放吃特效
	params@chi_pos 吃牌玩位置
	params@callfunction 回调方法
]]
function MJNewEffectMgr:playChi(chi_pos,callfunction,target,targetNode)
	local path = ChiPengGangConf[1]
	self:playEffect(path,callfunction,nil,target,targetNode,player_pos[chi_pos]) 
end
--[[
	播放碰特效
	params@peng_pos 碰牌玩位置
	params@callfunction 回调方法
]]
function MJNewEffectMgr:playPeng(peng_pos,callfunction,target,targetNode)
	local path = ChiPengGangConf[2]
	self:playEffect(path,callfunction,nil,target,targetNode,player_pos[peng_pos]) 
end
--[[
	播放杠特效
	params@gang_pos 杠牌玩位置
	params@callfunction 回调方法
]]
function MJNewEffectMgr:playGang(gang_pos,callfunction,target,targetNode)
	local path = ChiPengGangConf[3]
	self:playEffect(path,callfunction,nil,target,targetNode,player_pos[gang_pos]) 
end
--[[
	播放暗杠特效
	params@gang_pos 杠牌玩位置
	params@callfunction 回调方法
]]
function MJNewEffectMgr:playAnGang(gang_pos,callfunction,target,targetNode)
	local path = ChiPengGangConf[3]
	self:playEffect(path,callfunction,nil,target,targetNode,player_pos[gang_pos])  
end

--[[
	播放暗杠特效
	params@gang_pos 杠牌玩位置
	params@callfunction 回调方法
]]
function MJNewEffectMgr:playBuZhang(gang_pos,callfunction,target,targetNode)
	local path = ChiPengGangConf[7]
	self:playEffect(path,callfunction,nil,target,targetNode,player_pos[gang_pos])  
end

function MJNewEffectMgr:playMJEffect(pos,callfunction,target,targetNode, index)
	local path = ChiPengGangConf[index]
	self:playEffect(path,callfunction,nil,target,targetNode,player_pos[pos])  
end

return MJNewEffectMgr