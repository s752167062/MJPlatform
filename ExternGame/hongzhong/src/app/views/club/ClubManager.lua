--带local是局部变量，不带local全局变量
ClubManager = {}
ClubManager._config = {}
ClubManager.yao_qing_jin_fang = {}

PATH_CLUB_LUA = "app/views/club/"

function copyTable(_t1, _t2)
	local function func(t1, t2)
		for key, var in pairs(t1) do
			if type(var) == "table" then
				t2[key] = {}
				func(var, t2[key])
			else	
				t2[key] = var
			end
		end
	end
	if _t2 == nil then 
        _t2 = {} 
    end
	func(_t1, _t2)
	return _t2
end

ClubManager.joinConditionTable = {
    {v="申请加入", id=0},
    -- {v="允许加入", id=1},
    {v="拒绝加入", id=2},
}

--俱乐部图标table
--[1]客户端字段， [2]服务器字段
local iconPrefx = "image_club/com_icon/"
ClubManager.iconTable = {
    {v=iconPrefx.."icon1.png", id=1},
    {v=iconPrefx.."icon2.png", id=2},
    {v=iconPrefx.."icon3.png", id=3},
    {v=iconPrefx.."icon4.png", id=4},
    {v=iconPrefx.."icon5.png", id=5},
    {v=iconPrefx.."icon6.png", id=6},
    {v=iconPrefx.."icon7.png", id=7},
    {v=iconPrefx.."icon8.png", id=8},
    {v=iconPrefx.."icon9.png", id=9},
    {v=iconPrefx.."icon10.png", id=10},
}

ClubManager.memberInfo = {
    id = 0,
    userID = 0,
    name = "",
    icon = "",
    jiarutime = "",
    beizhu = "",
    isHeimingdan = false,
    isOnline = false,
}


function ClubManager:init()
	

	--玩家ID
	self._config["playerID"] = 0
	--玩家权力值
	self._config["playerPower"] = 0


	--俱乐部id
	self._config["clubSecndId"] = 0
    self._config["clubID"] = 0
	--俱乐部名字
	self._config["clubName"] = "未命名"
	--俱乐部成员数
	self._config["clubPeopleNum"] = 0
	--俱乐部最大成员数
	self._config["clubPeopleMaxNum"] = 0
	--会长ID
	self._config["clubQunzhuID"] = 0
	--会长名字
	self._config["clubQunzhuName"] = "暂无"
	--管理员ID
	self._config["clubGuanliyuanID"] = 0
	--管理员名字
	self._config["clubGuanliyuanName"] = "暂无"
	--俱乐部描述
	self._config["clubDesc"] = ""
	self._config["clubDescTemp"] = ""
	--俱乐部公告
	self._config["clubNotice"] = ""
	self._config["clubNoticeTemp"] = ""
	--俱乐部创建时间
	self._config["clubCreateTime"] = ""
	--俱乐部加入条件 0 需要申请 1 不需要申请即可加入  2 拒绝加入
	self._config["clubCondition"] = "0"
	self._config["clubConditionTemp"] = 0
	--俱乐部地址
	self._config["clubAdress"] = ""
	--申请列表个数（红点展示）
	self._config["clubJoinReqNum"] = 0
	--俱乐部图标
	self._config["clubIcon"] = "1"
	self._config["clubIconTemp"] = ""

    --成员列表
    self._config["memberList"] = {}

    self._config["gameType"] = {
                        {gtype = "hz", name = "红中麻将"}
                    }   ---类似集合那样有各个玩法的话，他们的属性配置也不一样

    --房卡统计
    self._config["FKTJMaxPage"] = 0
    self._config["FKTJCurPage"] = 0
    self._config["FKTJPageObjMaxNum"] = 0
    self._config["FKTJPageObjCurNum"] = 0



    self._config["game_setting"] = {}

    self._config["showNoticeOnce"] = "" --临时弹出公告内容

end

function ClubManager:getInfo(key)
    return self._config[key]
end

function ClubManager:setInfo(key,value)
    cclog("ClubManager:setInfo >>", key, value)
    self._config[key] = value
    --print(value , key)
end

function ClubManager:print()
	-- body
	print_r(self._config)
end

function ClubManager:getClubID() -- 大俱乐部
	-- body
	return self._config["clubID"]
end

function ClubManager:getClubSecndID() --大俱乐部包含许多小俱乐部玩法
    -- body
    return self._config["clubSecndId"]
end

function ClubManager:getClubConditionTxt()
    -- body
    local txt = ClubManager.joinConditionTable[1].v
    for i=1,#ClubManager.joinConditionTable do
        local d = ClubManager.joinConditionTable[i]
        if tostring(d.id) == tostring(self._config["clubCondition"]) then
            txt = d.v
        end
    end
    return txt
end

function ClubManager:getClubIconPathById(id)
    -- body
    local txt = ClubManager.iconTable[1].v
    for i=1,#ClubManager.iconTable do
        local d = ClubManager.iconTable[i]
        if tostring(d.id) == tostring(id) then
            txt = d.v
        end
    end
    return txt
end

function ClubManager:getClubIconPath()
    -- body
    local path = ClubManager:getClubIconPathById(self._config["clubIcon"])
    cclog("getClubIconPath=",path)
    return path
end

function ClubManager:canKickPeople(userID)
    -- body  我是会长或者管理员就能踢人，但是如果踢的人是会长或者自己，就不能踢
    local flag = false
    if PlayerInfo.playerUserID == self._config["clubGuanliyuanID"] or PlayerInfo.playerUserID == self._config["clubQunzhuID"] then
        flag = true
    else
        flag = false
    end


    if self._config["clubQunzhuID"] == userID or PlayerInfo.playerUserID == userID then
        flag = false
    end

    return flag
end

function ClubManager:canRemoveBlackList(userID)
    -- body
    if self._config["playerID"] == userID then
        return false
    elseif self._config["playerID"] == self._config["clubGuanliyuanID"] then
        return true
    elseif self._config["playerID"] == self._config["clubQunzhuID"] then
        return true 
    else
        return false
    end
end

function ClubManager:isQunZhu()
    -- body
    if self._config["playerID"] == self._config["clubQunzhuID"] then
        return true 
    else
        return false
    end
end

function ClubManager:isGuanliyuan()
    -- body
    if self._config["playerID"] == self._config["clubGuanliyuanID"] then
        return true
    elseif self._config["playerID"] == self._config["clubQunzhuID"] then
        return true 
    else
        return false
    end
end

--获取职位 平民0 会长1 管理员2
function ClubManager:getZhiWei(playerID)
    if playerID == self._config["clubQunzhuID"] then
        return 1
    elseif playerID == self._config["clubGuanliyuanID"] then
        return 2 
    else
        return 0
    end
end

function ClubManager:canDismissClub()
    -- body
    if self._config["playerID"] == self._config["clubGuanliyuanID"] then
        return true
    elseif self._config["playerID"] == self._config["clubQunzhuID"] then
        return true 
    else
        return false
    end
end

function ClubManager:copyMemberInfo(t1, t2)
    -- body

end

-- function ClubManager:setMemberList(res)
-- 	-- body
--     self._config["memberList"] = {}
--     local list = res.data
--     for i=1,#list do
--         local d = list[i]
--         local info = clone(ClubManager.memberInfo)
--         info = copyTable(d, info)
--         self._config["memberList"][#self._config["memberList"]+1] = info
--     end
--     print_r(self._config["memberList"], "setMemberList")
-- end

-- --更新单条成员信息
-- function ClubManager:updateMemberInfo(res)
-- 	-- body
--     local isFind = false
--     for i=1,#self._config["memberList"] do
--         local info = self._config["memberList"][i]
--         if tostring(info.id) == tostring(res.id) then
--             info = copyTable(res, info)
--             isFind = true
--             break
--         end
--     end
--     if not isFind then
--         local info = clone(ClubManager.memberInfo)
--         info = copyTable(res, info)
--         self._config["memberList"][#self._config["memberList"] + 1] = info
--     end
--     print_r(self._config["memberList"], "updateMemberInfo")
-- end

-- function ClubManager:getMemberList()
-- 	-- body
-- end


function ClubManager:getGameTypeNameText(gtype)
    local info = self:getInfo("gameType")
    for k,v in pairs(info) do
        if v.gtype == gtype then
            return v.name 
        end
    end


   return ""
end

function ClubManager:getGameTypeForServer(param)
    local info = self:getInfo("gameType")
    return info[1].gtype    -- 目前王麻将只有一个王麻将的玩法，暂时这样写，以后集合的情况下再说吧
    
end



function ClubManager:setYaoQingJinFang(uid, ytime)
    self.yao_qing_jin_fang[uid] = ytime
end

function ClubManager:getYaoQingJinFang(uid)
    return self.yao_qing_jin_fang[uid]
end

function ClubManager:cleanYaoQingJinFang()
    self.yao_qing_jin_fang = {}
end

