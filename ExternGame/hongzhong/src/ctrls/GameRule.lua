GameRule = {}




GameRule.canDaiKai = true
GameRule.isQiXiaoDui = 0
GameRule.isMiLuoHongZhong = 0

GameRule.PLAY_EIGHT = false
GameRule.PLAY_CONNON = false
GameRule.PLAY_AK_ONE_ALL = false

GameRule.MAX_GAMECNT = 1
GameRule.cur_GameCNT = 1
GameRule.ZhaMaCNT = 2

GameRule.GameSetting = {}
GameRule.GameSetting.type_1 = 0
GameRule.GameSetting.type_2 = 0
GameRule.GameSetting.type_3 = 0

--[[
--]]
function GameRule:setRule(params)
	GameRule.isQiXiaoDui = params.PLAY_7D == true and 1 or 0
    GameRule.isMiLuoHongZhong = params.PLAY_LEILUO == true and 1 or 0

    for k,v in pairs(params) do
    	GameRule[k] = v
    end
end



function GameRule:getRuleText(fix_txt, flag, isvideo)
    if GameRule.isMiLuoHongZhong == 1 then
        local tmp = fix_txt ~= "" and " 汨罗红中" or "汨罗红中"
        fix_txt = fix_txt .. tmp
    end

    if GameRule.isQiXiaoDui == 1 then
        local tmp = fix_txt ~= "" and " 七小对" or "七小对"
        fix_txt = fix_txt .. tmp
    end

    if isvideo then return fix_txt end
    
    if GameRule.PLAY_EIGHT == true then
        local tmp = fix_txt ~= "" and " 8个红中" or "8个红中"
        fix_txt = fix_txt .. tmp
    end

    if GameRule.PLAY_CONNON == true then
        local tmp = fix_txt ~= "" and " 可点炮" or "可点炮"
        fix_txt = fix_txt .. tmp
    end

    if GameRule.PLAY_AK_ONE_ALL == true and not flag then
        local tmp = fix_txt ~= "" and " 新一码全中" or "新一码全中"
        fix_txt = fix_txt .. tmp
    end

    return fix_txt
end

function GameRule:getZhaMaText(zhama, flag)
	local str = ""
	if zhama == 1 then
		str =  "一码全中"
	elseif zhama ~= 0 then
		str =  zhama .. "个码"
	end
	if str == "" and flag == true and GameRule.PLAY_AK_ONE_ALL == true then
		str = "新一码全中"
	end
	return str
end

function GameRule:getZhaMaTextFromServer(zhama, flag)
	cclog("GameRule:getZhaMaTextFromServer zhama:"..zhama.."  flag:" .. tostring(flag))
	local str = ""
	if zhama == 1 then
		str =  "一码全中"
	elseif zhama ~= 0 then
		str =  zhama .. "个码"
	end
	if str == "" and flag == true then
		str = "新一码全中"
	end
	return str
end

function GameRule:getShareText(player_numb)
	local msg = "我在[筑志红中麻将]开了 ".. GameRule.MAX_GAMECNT .."局,"

	msg = msg .. (GameRule.ZhaMaCNT > 1 and GameRule.ZhaMaCNT .."个码" or "") --判断0码的情况
	msg = msg .. (GameRule.ZhaMaCNT == 1 and "一码全中" or "") --判断1码的情况
	
    msg = GameRule:getRuleText(msg)

    msg = msg .. "的".. player_numb .. "人房间," .. "快来一起玩吧"

    return msg
end


function GameRule:clubRoomRuleText(params)
	local str = "房间规则："
	cclog("GameRule:clubRoomRuleText  xxx>>>")
	print_r(params)
	
	local t1 = params.type_1 == 0 and "仅会长开房" or "所有人可开房"
	local t2 = params.type_2 == 0 and "扣会长房卡" or "扣开房者房卡"
	local t3 = params.type_3 == 0 and "俱乐部成员" or "任何人"
	t3 = t3 .. "可加入"
	str = string.format("%s%s,%s,%s", str, t1,t2,t3)

	return str
end

function GameRule:clubServerRuleToText(str, params)
	local str = str

	if params.PLAY_LEILUO == true then
		str = str ~= "" and str .. ",汨罗红中" or str .. "汨罗红中"
	end

	if params.PLAY_7D == true then
		str = str ~= "" and str .. ",胡七对" or str .. "胡七对"
	end

	if params.canWatch == true then
		str = str ~= "" and str .. ",可旁观" or str .. "可旁观"
	end

	if params.PLAY_EIGHT == true then
		str = str ~= "" and str .. ",8个红中" or str .. "8个红中"
	end

	if params.PLAY_CONNON == true then
		str = str ~= "" and str .. ",可点炮" or str .. "可点炮"
	end

	if params.PLAY_AK_ONE_ALL == true then
		str = str ~= "" and str .. ",新一码全中" or str .. "新一码全中"
	end
	
	return str
end

function GameRule:clubGameRuleText(json_str)
	-- "ju":8,"PLAY_LEILUO":true,"playerNum":4,"PLAY_7D":false,"za":3
	local params =json.decode(json_str)
	local str = ""
	params.ju = params.ju or 0
	str = string.format("游戏规则：%s人%s,%s", params.playerNum, params.ju == 0 and ",玩家自定义局数" or params.ju .. "局", GameRule:getZhaMaText(params.za))
	str = GameRule:clubServerRuleToText(str, params)
	return str
end

function GameRule:clubGameRuleText2(json_str)
	local params =json.decode(json_str)
	local str = ""
	params.ju = params.ju or 0
	local pre = GameRule:getZhaMaText(params.za)
	str = string.format("%s人%s%s", params.playerNum, params.ju == 0 and ",玩家自定义局数" or params.ju .. "局", pre == "" and "" or ","..pre)
	str = GameRule:clubServerRuleToText(str, params)
	str = string.gsub(str, ",", "，")
	return str
end














return GameRule




