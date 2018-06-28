--[[
	说明：
    0、
    ex_fileMgr:loadLua("activity/ActivityMgr") --双旦活动

	1、
	    --ActivityMgr
    ActivityMgr:initonLogin("hz") -- --hz 红中 --wmj王麻将  --zn扎鸟
    ActivityMgr:registeNetAgreement()

    1.1、
        --ActivityMgr
    local activity_node =  cc.Node:create()
    self.root:addChild(activity_node) 
    ActivityMgr:setHallRootAndBg(self , self.root:getChildByName("bg") , activity_node)
    ActivityMgr:checkActivityStatus()
    ActivityMgr:getActivityUserInfo()

    1.2
        --ActivityMgr
    local activity_node =  cc.Node:create()
    self.root:addChild(activity_node) 
    ActivityMgr:setClubRoot(self , activity_node)
    ActivityMgr:checkActivityStatusClub()
    ActivityMgr:getActivityUserInfoClub()


    2
    ActivityMgr:setRoomRoot(self)
    ActivityMgr:initRoomUI()

    胡牌协议下发时 CCXNotifyCenter:notify("ActivitysStarGotLock", true) -- 活动任务显示上锁
    小结算打开时 CCXNotifyCenter:notify("ActivitysStarGotLock", false) -- 活动任务显示解锁
    加在俱乐部的刷新按钮事件中 CCXNotifyCenter:notify("ActivitysReCheckActivity") -- 用于活动的刷新（活动结束后可以删除）
]]

ActivityMgr = {}

--活动开启状态
ActivityMgr.ACTIVITY_STATUE_NO=0 --还没开启
ActivityMgr.ACTIVITY_STATUE_OPENED=1 --活动进行中
ActivityMgr.ACTIVITY_STATUE_REWARD=2 --活动停止，领取中
ActivityMgr.ACTIVITY_STATUE = ActivityMgr.ACTIVITY_STATUE_NO

--场景状态
ActivityMgr.UI_STATUE_NO=0
ActivityMgr.UI_STATUE_HALL=1 --大厅界面中
ActivityMgr.UI_STATUE_ROOM=2 --房间界面中
ActivityMgr.UI_STATUE_CLUB=3 --俱乐部界面中
ActivityMgr.UI_STATUE = ActivityMgr.UI_STATUE_NO

ActivityMgr.showActivityRule = true -- 显示活动介绍
ActivityMgr.reward_status = true -- 活动结束可以领取奖励
ActivityMgr.ActivityUserInfo = nil --活动玩家填写的信息
ActivityMgr.gameMode = "hz" --hz红中麻将 --wmj王麻将  --zn扎鸟
ActivityMgr.starBuff = {}
ActivityMgr.starBuffLoakStatus = false
--层级管理
ActivityMgr.ZOrder_base = 0
ActivityMgr.ZOrder_btn  = 11
ActivityMgr.ZOrder_UI   = 12
ActivityMgr.ZOrder_Dialog = 13

--奖励类型
ActivityMgr.RewardType = {
    [100] = { key = 100 , txt = "1"     ,winscore = 1, msg = "【8局的房间】游戏1次" },       --#扎鸟【6局的房间】游戏1次
    [101] = { key = 101 , txt = "1_0"   ,winscore = 3, msg = "【8局的房间】游戏1次" },       --#扎鸟【6局的房间】游戏1次
    [102] = { key = 102 , txt = "2"     ,winscore = 2, msg = "【8局的房间】游戏3次" },       --#扎鸟【6局的房间】游戏3次
    [103] = { key = 103 , txt = "3_0"   ,winscore = 3, msg = "【8局的房间】3次大赢家" },      --#扎鸟【6局的房间】3次大赢家
    [104] = { key = 104 , txt = "4"     ,winscore = 2, msg = "【16局的房间】游戏1次" },      --#扎鸟【12局的房间】游戏1次
    [105] = { key = 105 , txt = "4_0"   ,winscore = 6, msg = "【16局的房间】游戏1次" },      --#扎鸟【12局的房间】游戏1次
    [106] = { key = 106 , txt = "5"     ,winscore = 4, msg = "【16局的房间】游戏3次" },      --#扎鸟【12局的房间】游戏3次
    [107] = { key = 107 , txt = "6_0"   ,winscore = 6, msg = "【16局的房间】3次大赢家" },     --#扎鸟【12局的房间】3次大赢家
    [156] = { key = 156 , txt = "7"     ,winscore = 10,msg = "【四红中】天胡" },
    [157] = { key = 157 , txt = "8"     ,winscore = 6, msg = "【四红中】胡牌" },
    [158] = { key = 158 , txt = "9"     ,winscore = 9, msg = "【四红中】未胡牌" },
    [159] = { key = 159 , txt = "10"    ,winscore = 3, msg = "【三红中】胡牌" },
    [160] = { key = 160 , txt = "12"    ,winscore = 2, msg = "【无红中】自摸" },
    [161] = { key = 161 , txt = "13"    ,winscore = 1, msg = "【明杠/碰杠】" },
    [162] = { key = 162 , txt = "14"    ,winscore = 2, msg = "【暗杠】" },
    [163] = { key = 163 , txt = "15"    ,winscore = 2, msg = "【胡七对】" },

    [164] = { key = 164 , txt = "7"     ,winscore = 10,msg = "【超豪七对自摸】" },
    [165] = { key = 165 , txt = "8"     ,winscore = 9, msg = "【超豪七对抓炮】" },
    [166] = { key = 166 , txt = "9"     ,winscore = 8, msg = "【双豪七对自摸】" },
    [167] = { key = 167 , txt = "10"    ,winscore = 7, msg = "【双豪七对抓炮】" },
    [168] = { key = 168 , txt = "12"    ,winscore = 6, msg = "【豪华七对自摸】" },
    [169] = { key = 169 , txt = "13"    ,winscore = 5, msg = "【豪华七对抓炮】" },
    [170] = { key = 170 , txt = "14"    ,winscore = 4, msg = "【七对、碰碰胡清一色、板板胡、海底捞自摸】" }, -- 
    [171] = { key = 171 , txt = "15"    ,winscore = 3, msg = "【七对、碰碰胡清一色、板板胡、海底捞抓炮】" }, --
    [172] = { key = 172 , txt = "11"    ,winscore = 6, msg = "【三红中】未胡牌" },

    --扎鸟用
    [173] = { key = 173 , txt = "14"    ,winscore = 4, msg = "【七对自摸】" }, -- 
    [174] = { key = 174 , txt = "14"    ,winscore = 4, msg = "【碰碰胡自摸】" }, -- 
    [175] = { key = 175 , txt = "14"    ,winscore = 4, msg = "【清一色自摸】" }, -- 
    [176] = { key = 176 , txt = "14"    ,winscore = 4, msg = "【板板胡自摸】" }, -- 
    [177] = { key = 177 , txt = "14"    ,winscore = 4, msg = "【海底捞自摸】" }, -- 

    [178] = { key = 178 , txt = "15"    ,winscore = 3, msg = "【七对抓炮】" }, --
    [179] = { key = 179 , txt = "15"    ,winscore = 3, msg = "【碰碰胡抓炮】" }, --
    [180] = { key = 180 , txt = "15"    ,winscore = 3, msg = "【清一色抓炮】" }, --
    [181] = { key = 181 , txt = "15"    ,winscore = 3, msg = "【板板胡抓炮】" }, --
    [182] = { key = 182 , txt = "15"    ,winscore = 3, msg = "【海底捞抓炮】" }, --

    [183] = { key = 183 , txt = "14"    ,winscore = 4, msg = "【将将胡自摸】" }, -- 
    [184] = { key = 184 , txt = "15"    ,winscore = 3, msg = "【将将胡抓炮】" }, -- 
}

ActivityMgr.LotteryType = {
    [500] = { key = 500 , desc = "红包" , icon = "image2/activity3/icon500.png" , txt = "txt_hongbao"}, --
    [501] = { key = 501 , desc = "房卡" , icon = "image2/activity3/icon501.png" , txt = "txt_fangka"}, --
    [502] = { key = 502 , desc = "\"新\"字" , icon = "image2/activity3/icon502.png" , txt = "txt_xin"}, --
    [503] = { key = 503 , desc = "\"春\"字" , icon = "image2/activity3/icon503.png" , txt = "txt_cun"}, --
    [504] = { key = 504 , desc = "\"筑\"字" , icon = "image2/activity3/icon504.png" , txt = "txt_zhu"}, --
    [505] = { key = 505 , desc = "\"福\"字" , icon = "image2/activity3/icon505.png" , txt = "txt_fu"}, --
    [506] = { key = 506 , desc = "福蛋" , icon = "image2/activity3/icon506.png" , txt = "txt_fudan"}, --

}

function ActivityMgr:setHallRootAndBg(node , bgnode ,ctn_activity)
    cclog(" --- ////// ;;;; setHallRootAndBg ")
    ActivityMgr.UI_STATUE = ActivityMgr.UI_STATUE_HALL
    self.roomNode = nil
    self.clubNode = nil
    if node then 
        self.hallNode = node
    end    
    if bgnode then 
        self.hallbgNode = bgnode
    end    
    if ctn_activity then 
        self.hallctn_activity = ctn_activity
    end    
end

function ActivityMgr:setRoomRoot(node)
    cclog(" --- ////// ;;;; setRoomRoot ")
    ActivityMgr.UI_STATUE = ActivityMgr.UI_STATUE_ROOM
    self.hallNode = nil
    self.clubNode = nil
    if node then 
        self.roomNode = node
    end    
end

function ActivityMgr:setClubRoot(node , ctn_activity)
    cclog(" --- ////// ;;;; setClubRoot ")
    ActivityMgr.UI_STATUE = ActivityMgr.UI_STATUE_CLUB
    self.roomNode = nil
    self.hallNode = nil
    if node then 
        self.clubNode = node
    end    

    if ctn_activity then 
        self.clubctn_activity = ctn_activity
    end
end

function ActivityMgr:initonLogin(gameMode)
    ActivityMgr.showActivityRule = true 
    ActivityMgr.gameMode = gameMode or "hz"

    if gameMode == "zn" then 
        ActivityMgr.RewardType[100] = { key = 100 , txt = "1"     ,winscore = 1, msg = "【6局的房间】游戏1次" }      --#扎鸟【6局的房间】游戏1次
        ActivityMgr.RewardType[101] = { key = 101 , txt = "1_0"   ,winscore = 3, msg = "【6局的房间】游戏1次" }       --#扎鸟【6局的房间】游戏1次
        ActivityMgr.RewardType[102] = { key = 102 , txt = "2"     ,winscore = 2, msg = "【6局的房间】游戏3次" }       --#扎鸟【6局的房间】游戏3次
        ActivityMgr.RewardType[103] = { key = 103 , txt = "3_0"   ,winscore = 3, msg = "【6局的房间】3次大赢家" }      --#扎鸟【6局的房间】3次大赢家
        ActivityMgr.RewardType[104] = { key = 104 , txt = "4"     ,winscore = 2, msg = "【12局的房间】游戏1次" }      --#扎鸟【12局的房间】游戏1次
        ActivityMgr.RewardType[105] = { key = 105 , txt = "4_0"   ,winscore = 6, msg = "【12局的房间】游戏1次" }      --#扎鸟【12局的房间】游戏1次
        ActivityMgr.RewardType[106] = { key = 106 , txt = "5"     ,winscore = 4, msg = "【12局的房间】游戏3次" }      --#扎鸟【12局的房间】游戏3次
        ActivityMgr.RewardType[107] = { key = 107 , txt = "6_0"   ,winscore = 6, msg = "【12局的房间】3次大赢家" }     --#扎鸟【12局的房间】3次大赢家
    end   

    CCXNotifyCenter:listen(self,function(self,obj,data) ActivityMgr:lockStarGot(data) end ,"ActivitysStarGotLock") 
    CCXNotifyCenter:listen(self,function(self,obj,data) ActivityMgr:reCheckActivity(data) end ,"ActivitysReCheckActivity")    
end

function ActivityMgr:initHallUI()
    ActivityMgr.UI_STATUE = ActivityMgr.UI_STATUE_HALL
    if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_OPENED then --活动开放中
        if ActivityMgr.showActivityRule then 
            ActivityMgr.showActivityRule = false -- 从登陆界面进入大厅 显示活动介绍
            --显示活动展示页
            self:showActivityMain()
        end  
        --添加活动进行中按钮
        self:addRewardBtn(ActivityMgr.ACTIVITY_STATUE_OPENED , ActivityMgr.reward_status)
        -- 显示活动效果
        self:showActivityEff()
        -- 显示缓存的 任务UI 
        self:showGotStar()
    elseif  ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_REWARD then --活动停止，领取奖励时间
        --添加活动结束了按钮 活动领奖按钮 
        self:addRewardBtn(ActivityMgr.ACTIVITY_STATUE_REWARD , ActivityMgr.reward_status)
        -- 显示缓存的 任务UI 
        self:showGotStar()
    end    

    --大厅重置 gotStar 表现锁
    ActivityMgr.starBuffLoakStatus = false
end 

function ActivityMgr:initRoomUI()
    ActivityMgr.UI_STATUE = ActivityMgr.UI_STATUE_ROOM
    if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_OPENED then --活动开放中

    elseif  ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_REWARD then --活动停止，领取奖励时间
    
    end 
end

function ActivityMgr:initClubUI()
    ActivityMgr.UI_STATUE = ActivityMgr.UI_STATUE_CLUB
    if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_OPENED then --活动开放中
        --添加活动进行中按钮
        self:addClubRewardBtn(ActivityMgr.ACTIVITY_STATUE_OPENED , ActivityMgr.reward_status)
        -- 显示活动效果
        self:showClubActivityEff()
    elseif  ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_REWARD then --活动停止，领取奖励时间
        --添加活动结束了按钮 活动领奖按钮 
        self:addClubRewardBtn(ActivityMgr.ACTIVITY_STATUE_REWARD , ActivityMgr.reward_status)
    end 
    -- 显示缓存的 任务UI
    self:showGotStar()
    --重置 gotStar 表现锁
    ActivityMgr.starBuffLoakStatus = false
end

--网络重连时重新请求，获取活动状态
function ActivityMgr:reCheckActivity()
    ActivityMgr:checkActivityStatus()
    ActivityMgr:getActivityUserInfo()
end    
-- function ActivityMgr:addEnterBtn2Node(node , position)
-- 	if node then 
-- 		self.node = node
-- 		display.loadSpriteFrames("image/sellershare.plist","image/sellershare.png")--载入图像到帧缓存 

-- 		local spriteFrame = display.newSpriteFrame("btn_enterseller.png")  
--   		local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame) 
-- 		sprite:setPosition(position or self:enterBtnPosition())
-- 		sprite:setScaleY(0.8)
-- 		sprite:setScaleX(0.9)
-- 		sprite:addTo(node)

--   		local btn = ccui.Button:create("btn_enterseller.png","btn_enterseller.png","btn_enterseller.png",ccui.TextureResType.plistType)
--         btn:loadTextures("btn_enterseller.png","btn_enterseller.png","btn_enterseller.png")
-- 	    btn:setPosition(position or self:enterBtnPosition())
-- 	    btn:setOpacity(0)
-- 	    btn:addClickEventListener(function() self:enterBtnClick() end)
-- 	    btn:addTo(node)

-- 	else
-- 		cclog(" >>>>>> ActivityMgr addEnterBtn2Node nil >>>>>>")
-- 	end	
-- end


function ActivityMgr:showToast(msg,func)
    local dialog = ex_fileMgr:loadLua("activity.UIActivityDialog").new()
    dialog:setLocalZOrder(ActivityMgr.ZOrder_Dialog)
    dialog:showMsg(msg,func)

    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
        dialog:addTo(self.hallNode);
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_ROOM then 
        dialog:addTo(self.roomNode);
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        dialog:addTo(self.clubNode);
    else
        local scene = cc.Director:getInstance():getRunningScene()
        if scene then
            dialog:addTo(scene); -- 没在大厅，房间的话加到当前场景中
        end    
    end    
end

function ActivityMgr:showActivityMain(status)
    local activitymain
    if ActivityMgr.gameMode == "zn" then --扎鸟
        activitymain = ex_fileMgr:loadLua("activity.UIActivityMain_zn").new()
    elseif ActivityMgr.gameMode == "hz" then --红中 
        activitymain = ex_fileMgr:loadLua("activity.UIActivityMain").new()
    else
        activitymain = ex_fileMgr:loadLua("activity.UIActivityMain_wmj").new()
    end    
    activitymain:setName("act_activitymain")
    
    if self.hallNode then 
        cclog("---- showActivityMain hallNode ")
        if self.hallNode:getChildByName("act_activitymain") == nil then 
            activitymain:addTo(self.hallNode );
            activitymain:setLocalZOrder(ActivityMgr.ZOrder_UI)
        end    
        return 
    elseif self.clubNode then 
        cclog("---- showActivityMain clubNode ")
        if self.clubNode:getChildByName("act_activitymain") == nil then 
            activitymain:addTo(self.clubNode);
            activitymain:setLocalZOrder(ActivityMgr.ZOrder_UI)
        end    
    end
    cclog("Activity showActivityMain self.hallNode  null")
end

function ActivityMgr:showActivityEff()
    if self.hallctn_activity then 
        if self.hallctn_activity:getChildByName("act_uiHallActivity") == nil then 
            -- 添加雪效果
            local resourceNode_ 
            if ActivityMgr.gameMode == "zn" then --扎鸟
                resourceNode_ = display.newCSNode("activity2/uiHallActivity_zn.csb")
            elseif ActivityMgr.gameMode == "hz" then --红中
                resourceNode_ = display.newCSNode("activity2/uiHallActivity.csb")
            else    
                resourceNode_ = display.newCSNode("activity2/uiHallActivity_wmj.csb")
            end   
            resourceNode_:setName("act_uiHallActivity") 
            resourceNode_:addTo(self.hallctn_activity);
        else
            cclog(" --- act_uiHallActivity already exit")
        end    
    else
            cclog("Activity showActivityEff self.hallctn_activity  null")
    end

    if self.hallbgNode then 
        if self.hallbgNode:getChildByName("act_uiHallActivityBG") == nil then 
            --添加背景
            local resourceNode_ = display.newCSNode("activity2/uiHallActivityBG.csb")
            resourceNode_:setName("act_uiHallActivityBG")
            resourceNode_:addTo(self.hallbgNode)
        else
            cclog(" --- act_uiHallActivityBG already exit")
        end    
    else
            cclog("Activity showActivityEff self.hallctn_activity  null")
    end    

end

function ActivityMgr:addRewardBtn(activity_status , reward_status)
    if self.hallctn_activity then 
        local base = self.hallctn_activity:getChildByName("act_itemActivity") 
        if base then 
            base:setStatus(activity_status , reward_status)
        else
            local itemActivity = ex_fileMgr:loadLua("activity.itemActivity").new()
            itemActivity:setStatus(activity_status , reward_status)
            itemActivity:setPosition(cc.p(1081.48,506.99))
            itemActivity:setName("act_itemActivity")
            itemActivity:addTo(self.hallctn_activity);
        end    
        return 
    end
    cclog("Activity addRewardBtn self.hallctn_activity  null")
end

--俱乐部显示
function ActivityMgr:addClubRewardBtn( activity_status , reward_status )
    if self.clubctn_activity then 
        local base = self.clubctn_activity:getChildByName("act_ClubitemActivity") 
        if base then 
            base:setStatus(activity_status , reward_status)
        else
            local itemActivity = ex_fileMgr:loadLua("activity.itemActivity").new()
            itemActivity:setStatus(activity_status , reward_status)
            itemActivity:setPosition(cc.p(234,605))
            itemActivity:setName("act_ClubitemActivity")
            itemActivity:addTo(self.clubctn_activity);
        end    
        return 
    end
    cclog("Activity addClubRewardBtn self.clubctn_activity  null")    
end
--俱乐部显示
function ActivityMgr:showClubActivityEff( ... )
    if self.clubctn_activity then 
        if self.clubctn_activity:getChildByName("act_uiClubActivity") == nil then 
            -- 添加雪效果
            local resourceNode_ = display.newCSNode("activity2/uiClubActivity.csb")
            -- if ActivityMgr.gameMode == "zn" then --扎鸟
            --     resourceNode_ = display.newCSNode("activity2/uiHallActivity_zn.csb")
            -- elseif ActivityMgr.gameMode == "hz" then --红中
                -- resourceNode_ = display.newCSNode("activity2/uiClubActivity.csb")
            -- else    
                -- resourceNode_ = display.newCSNode("activity2/uiHallActivity_wmj.csb")
            -- end   
            resourceNode_:setName("act_uiClubActivity") 
            resourceNode_:addTo(self.clubctn_activity);
        else
            cclog(" --- act_uiClubActivity already exit")
        end    
    else
            cclog("Activity showClubActivityEff self.clubctn_activity  null")
    end
end

function ActivityMgr:showActivityDetail(club_DATA)
    local activitymain
    if ActivityMgr.gameMode == "zn" then --扎鸟
        activitymain = ex_fileMgr:loadLua("activity.UIActivityRewardDetail_zn").new()
    elseif ActivityMgr.gameMode == "hz" then --红中
        activitymain = ex_fileMgr:loadLua("activity.UIActivityRewardDetail").new()
    else
        activitymain = ex_fileMgr:loadLua("activity.UIActivityRewardDetail_wmj").new()
    end    
    if self.hallNode then 
        activitymain:addTo(self.hallNode);
        activitymain:setClubData(club_DATA) 
        activitymain:setLocalZOrder(ActivityMgr.ZOrder_UI)
        return 
    elseif self.clubNode then 
        activitymain:addTo(self.clubNode);
        activitymain:setClubData(club_DATA) 
        activitymain:setLocalZOrder(ActivityMgr.ZOrder_UI)
    end
    cclog("Activity showActivityDetail self.hallNode  null")
end

--任务完成 获得的道具
function ActivityMgr:showActivityRewardStar(data)
    local activityreward = ex_fileMgr:loadLua("activity.UIActivityStarGot").new()
    activityreward:setData(data)
    activityreward:setName("activity_startGot")
    activityreward:setLocalZOrder(ActivityMgr.ZOrder_UI)

    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then
        activityreward:addTo(self.hallNode);
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_ROOM then 
        activityreward:addTo(self.roomNode);
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        activityreward:addTo(self.clubNode);
    else
        local scene = cc.Director:getInstance():getRunningScene()
        if scene then
            activityreward:addTo(scene); -- 没在大厅，房间的话加到当前场景中
        end    
    end
end

function ActivityMgr:showGotStar()
    print("  showGotStar ---------------------")
    local new_buff = {}
    for k,item in pairs(ActivityMgr.starBuff) do
        local res    = item.res
        local status = item.ui_status
        if status == ActivityMgr.UI_STATUE then 
            self:showActivityRewardStar(res)
        else
            table.insert(new_buff , item)
        end        
    end
    --清空
    ActivityMgr.starBuff = new_buff
end

function ActivityMgr:lockStarGot(bool)
    print(" ------ ActivityMgr lockStarGot  ",bool)
    ActivityMgr.starBuffLoakStatus = bool
    if bool == false then 
        self:showGotStar()
    end
end    

function ActivityMgr:showActivityLingQu(itemdata)
    if self.hallNode then 
        local activitycash = ex_fileMgr:loadLua("activity.UIActivityRewardCash").new()
        activitycash:setItemData(itemdata)
        activitycash:addTo(self.hallNode);
        activitycash:setLocalZOrder(ActivityMgr.ZOrder_UI)
        return 
    elseif self.clubNode then 
        local activitycash = ex_fileMgr:loadLua("activity.UIActivityRewardCash").new()
        activitycash:setItemData(itemdata)
        activitycash:addTo(self.clubNode);
        activitycash:setLocalZOrder(ActivityMgr.ZOrder_UI)
        return 
    end
    cclog("Activity showActivityLingQu self.hallNode  null")
end

function ActivityMgr:shareScreenRewards()
    if self.hallNode then 
        local activitycash = ex_fileMgr:loadLua("activity.UIActivityShareScreen").new()
        activitycash:addTo(self.hallNode);
        activitycash:setLocalZOrder(ActivityMgr.ZOrder_UI)
    elseif self.clubNode then
        local activitycash = ex_fileMgr:loadLua("activity.UIActivityShareScreen").new()
        activitycash:addTo(self.clubNode);
        activitycash:setLocalZOrder(ActivityMgr.ZOrder_UI)
    end    
    cclog("Activity shareScreenRewards self.hallNode  null")
end

function ActivityMgr:getAnimateWithkey(key , format , begin_frame , frame_count , frame)
    local kstr = tostring(key)
    -- local animation = display.getAnimationCache(kstr)
    local animate = nil

    -- if key and animation then
    --     animate = cc.Animate:create(animation)
    -- else
        -- display.loadSpriteFrames(cfg.plist, cfg.png)
        local frames = display.newFrames(format, begin_frame, frame_count)
        local animation = display.newAnimation(frames, frame)
        -- display.setAnimationCache(kstr, animation)

        animate = cc.Animate:create(animation)
    -- end

    return animate
end

--------------------------TOOLS  -----------------------------
--------- 下载
function ActivityMgr.DownloadFile(url , filename , callfunc)
    if url == nil or filename == nil then
    	return 
    end
    cclog("开始下载文件 " .. url)
    if true then
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
        xhr:open("GET", url)
        local function onReadyStateChanged()
            if xhr.readyState == 4 and xhr.status == 200 then
                local response = xhr.response
                local size     = table.getn(response)
                release_print("Http Status Code:" .. xhr.statusText .. ",size=" .. size)
                local file = io.open(ex_fileMgr:getWritablePath().."/"..filename,"wb")
                for i = 1, size do
                    file:write(string.char(response[i]))
                end
                file:close() 
                if callfunc then 
                    callfunc() 
                end 
            else
                release_print("xhr.readyState is:" .. xhr.readyState .. ",xhr.status is: " .. xhr.status)
            end
            xhr:unregisterScriptHandler()
        end
        xhr:registerScriptHandler(onReadyStateChanged)
        xhr:send()
    end
end

-- 字符串切分成数组
function ActivityMgr.split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

-- 字符串去除指定字符
function ActivityMgr.removeChar(s , char)
	if type(char) ~= "string" or string.len(char) <= 0  then
		return 
	end
	
	local start = 1 
	local newStr = ""
	while true do
		local pos = string.find(s,char,start,true) 
		if not pos then
			break
		end
		
        newStr = newStr .. string.sub(s, start, pos - 1)
        start = pos + string.len(char)
	end
    newStr = newStr .. string.sub (s, start)
    return newStr
end

-- 根据URL生成图片名
function ActivityMgr:makeFileNameByURL(URL)
    -- local filename = string.sub(URL, -10)
    -- if not string.find(filename,".png",1) then 
    --     filename = os.date("%d_")..filename .. ".png"
    -- end

    -- filename = ActivityMgr.removeChar(filename , "/")
    -- return filename

    -- --换成MD5
    if URL == nil or URL == "" then
        return "default.png"
    end
    local url_md5 = require("md5").sumhexa(URL) or "x0000_default_md5"
    if not string.find(url_md5,".png",1) then 
        url_md5 = url_md5 .. ".png"
    end
    dump(" //// SS FILE NAME " .. url_md5)
    return url_md5

end

function ActivityMgr:timeOutCallfunc(time , callfunc)
    local scheduler = cc.Director:getInstance():getScheduler()  
    local schedulerID = nil  
    schedulerID = scheduler:scheduleScriptFunc(function()  
        if callfunc then callfunc() end
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
    end,time,false)    
end




---------------------------------------------
--注册协议
function ActivityMgr:registeNetAgreement()
    cclog(" 注册大厅协议 ---****---")
	-- ex_hallHandler:funs[1315] = handler(self,self.onActivityStatus) --function(obj) cclog(" ###HALL  1315") self:onActivityStatus(obj) end
 --    ex_hallHandler:funs[1316] = handler(self,self.onActivityClubList) --function(obj) cclog(" ###HALL  1316") self:onActivityClubList(obj) end
 --    ex_hallHandler:funs[1317] = handler(self,self.onActivityClubDetail) --function(obj) cclog(" ###HALL  1317") self:onActivityClubDetail(obj) end
 --    ex_hallHandler:funs[1318] = handler(self,self.onActivityRewardHall) --function(obj) cclog(" ###HALL  1318") self:onActivityReward(obj) end
 --    ex_hallHandler:funs[1319] = handler(self,self.onUploadActivityUserInfo) --function(obj) cclog(" ###HALL  1319") self:onUploadActivityUserInfo(obj) end
 --    ex_hallHandler:funs[1320] = handler(self,self.onGetActivityUserInfo) --function(obj) cclog(" ###HALL  1320") self:onGetActivityUserInfo(obj) end
 --    --春节新增#2222
 --    ex_hallHandler:funs[1321] = handler(self,self.onGetActivityClubFudai)  --福袋数
 --    ex_hallHandler:funs[1322] = handler(self,self.onGetActivityLottery) --抽奖
 --    ex_hallHandler:funs[1323] = handler(self,self.onGetActivityMyRes)   --我的道具
 --    ex_hallHandler:funs[1324] = handler(self,self.onGetActivityRankDetail) --前十排名
 --    ex_hallHandler:funs[1325] = handler(self,self.onActivityChangeCards) --领取房卡
 --    ex_hallHandler:funs[1326] = handler(self,self.onActivityChangeHongbao) --新春祝福兑换




 --    cclog(" 注册房间协议 ---****---")
 --    ex_roomHandler:funs[1318] = handler(self,self.onActivityRewardRoom) --function(obj) cclog(" ###ROOM  1318") self:onActivityReward(obj) end

 --    cclog(" 注册俱乐部协议 ---****---")
 --    ex_clubHandler:funs[1315] = handler(self,self.onActivityStatus) --function(obj) cclog(" ###HALL  1315") self:onActivityStatus(obj) end
 --    ex_clubHandler:funs[1316] = handler(self,self.onActivityClubList) --function(obj) cclog(" ###HALL  1316") self:onActivityClubList(obj) end
 --    ex_clubHandler:funs[1317] = handler(self,self.onActivityClubDetail) --function(obj) cclog(" ###HALL  1317") self:onActivityClubDetail(obj) end
 --    ex_clubHandler:funs[1318] = handler(self,self.onActivityRewardClub) --function(obj) cclog(" ###HALL  1318") self:onActivityReward(obj) end
 --    ex_clubHandler:funs[1319] = handler(self,self.onUploadActivityUserInfo) --function(obj) cclog(" ###HALL  1319") self:onUploadActivityUserInfo(obj) end
 --    ex_clubHandler:funs[1320] = handler(self,self.onGetActivityUserInfo) --function(obj) cclog(" ###HALL  1320") self:onGetActivityUserInfo(obj) end
 --    --春节新增#2222
 --    ex_clubHandler:funs[1321] = handler(self,self.onGetActivityClubFudai)  --福袋数
 --    ex_clubHandler:funs[1322] = handler(self,self.onGetActivityLottery) --抽奖
 --    ex_clubHandler:funs[1323] = handler(self,self.onGetActivityMyRes)   --我的道具
 --    ex_clubHandler:funs[1324] = handler(self,self.onGetActivityRankDetail) --前十排名
 --    ex_clubHandler:funs[1325] = handler(self,self.onActivityChangeCards) --领取房卡
 --    ex_clubHandler:funs[1326] = handler(self,self.onActivityChangeHongbao) --新春祝福兑换

end



--------------------协议 ---------------------
-----------获取活动状态 ** 只会在进入大厅时请求
function ActivityMgr:checkActivityStatus()
	cclog(" Activity 请求 活动状态信息")
	local obj = Write.new(1315)
    obj:send()
    
end
function ActivityMgr:checkActivityStatusClub()
    cclog(" ActivityClub 请求 活动状态信息")
    local obj = Write.new(1315)
    obj:send()
    
end

function ActivityMgr:onActivityStatus(obj)
	cclog(" Activity 活动状态信息 回调")
	local status = obj:readByte() -- 进行中0 未开始1 结束2 byte
    cclog(" --- ",status)
	if status == 0 then 
        ActivityMgr.ACTIVITY_STATUE = ActivityMgr.ACTIVITY_STATUE_OPENED  --活动进行中
    elseif status == 2 then
        ActivityMgr.ACTIVITY_STATUE = ActivityMgr.ACTIVITY_STATUE_REWARD  --活动停止，领取中
        --读取玩家领奖状态
        local rstatus = obj:readByte()
        ActivityMgr.reward_status = ( rstatus == 0) -- 0可以领奖  1不可以领奖
        cclog(" --- ",rstatus)
    else
        ActivityMgr.ACTIVITY_STATUE = ActivityMgr.ACTIVITY_STATUE_NO
    end     

    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then 
        self:initHallUI()--初始化大厅UI
    elseif ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_CLUB then 
        self:initClubUI()
    end    
    CCXNotifyCenter:notify("onActivityStatus")
end

-----------获取我的奖励列表
function ActivityMgr:getActivityClubList()
    cclog(" Activity 请求 活动列表")
    local obj = Write.new(1316) 
    obj:send()
    
end
function ActivityMgr:getActivityClubListClub()
    cclog(" ActivityClub 请求 活动列表")
    local obj = Write.new(1316) 
    obj:send()
    
end

function ActivityMgr:onActivityClubList(obj)
    cclog(" Activity 活动列表 回调")
    local res = {}
    local status = obj:readByte() -- 0 表示有信息 1表示没有
    if status == 0 then
        res._data = {}
        local pnum = obj:readShort()
        cclog(" +++ _data count ", pnum)
        for i=1,pnum do
            obj:readShort()
            local info = {}
            info.icon       = obj:readString() --俱乐部icon
            info.clubID     = obj:readLong()   --俱乐部ID
            info.clubName   = obj:readString() --俱乐部名
            info.userName   = obj:readString() --玩家名
            info.userID     = obj:readLong()   --玩家ID
            info.ranking    = obj:readInt()    --排名

            info.round_cound = obj:readInt() --打完的局数

            if ActivityMgr.ACTIVITY_STATUE == ActivityMgr.ACTIVITY_STATUE_REWARD then
                info.reward_status    = obj:readByte()    --领取状态  0 可以领取  1不可领取  ---------2条件为达成
                info.reward_status_msg= obj:readString()  --未能领取原因  0 状态下是领取的奖品信息
            end    
            res._data[#res._data + 1] = info
        end
    end

    res.status = status
    print_r(res)
    CCXNotifyCenter:notify("onActivityClubList", res)
end

-----------根据俱乐部获取我的奖励详细
function ActivityMgr:getActivityClubDetail(clubID)
    cclog(" Activity 请求 活动奖励详细信息")
    local obj = Write.new(1317) 
    obj:writeByte(clubID or 0)
    obj:send()
    
end
function ActivityMgr:getActivityClubDetailClub(clubID)
    cclog(" ActivityClub 请求 活动奖励详细信息")
    local obj = Write.new(1317) 
    obj:writeByte(clubID or 0)
    obj:send()
    
end

function ActivityMgr:onActivityClubDetail(obj)
    cclog(" Activity 活动奖励详细信息 回调")
    local res = {}
    local status = obj:readByte() -- 0 表示有信息 1表示没有
    if status == 0 then
        res.ranking = obj:readInt()  -- 排名
        res.fudai  = obj:readInt()   -- 福袋 --原圣诞星
        res.eggNum = obj:readInt()   -- 福蛋 #2222
        res._data = {}
        local pnum = obj:readShort()
        cclog(" +++ _data count ", pnum)
        for i=1,pnum do
            obj:readShort()
            local info = {}
            info._type     = obj:readInt()    --类别
            info._score    = obj:readInt()    --分数

            res._data[#res._data + 1] = info
        end

        --前三名玩家数据
        res._rankdata = {}
        local ranknum = obj:readShort()
        cclog(" +++ _rankdata count ", ranknum)
        for j=1,ranknum do
            obj:readShort()
            local info = {}
            info._iconpath = obj:readString()    --头像地址
            info._name     = obj:readString()    --名字
            info._id       = obj:readLong()      --ID
            info._score    = obj:readInt()       --分数
            -- info._rank     = obj:readByte()      --排名

            res._rankdata[#res._rankdata + 1] = info
        end

        -- res._rankdata[1] = { _iconpath="",_name="333",_id=333,_score=333 }
        -- res._rankdata[2] = { _iconpath="",_name="111",_id=111,_score=111 }
        -- res._rankdata[3] = { _iconpath="",_name="444",_id=444,_score=444 }
        -- res._rankdata[4] = { _iconpath="",_name="222",_id=222,_score=222 }
        -- res._rankdata[5] = { _iconpath="",_name="777",_id=777,_score=777 }
    end

    res.status = status
    print_r(res)
    CCXNotifyCenter:notify("onActivityClubDetail", res)
end


-----------上传玩家信息 
function ActivityMgr:uploadActivityUserInfo(clubID, userName ,wechat,phone,alipay)
    cclog(" Activity 上传玩家信息", clubID, userName ,wechat,phone)
    local obj = Write.new(1319)
    obj:writeByte(clubID or 0)
    obj:writeString(userName or "")
    obj:writeString(wechat or "")
    obj:writeString(phone or "")
    obj:writeString(alipay or "")
    obj:send()
end

function ActivityMgr:uploadActivityUserInfoClub(clubID, userName ,wechat,phone, alipay)
    cclog(" ActivityClub 上传玩家信息", clubID, userName ,wechat,phone)
    local obj = Write.new(1319)
    obj:writeByte(clubID or 0)
    obj:writeString(userName or "")
    obj:writeString(wechat or "")
    obj:writeString(phone or "")
    obj:writeString(alipay or "")
    obj:send()
end

function ActivityMgr:onUploadActivityUserInfo(obj)
    cclog(" Activity 上传玩家信息 回调")
    local status = obj:readByte() -- 进行中0 未开始1 结束2 byte
    cclog(" -- ", status)
    if status == 0 then 
        self:showToast("提交信息成功")
        if ActivityMgr.ActivityUserInfoTemp then 
            ActivityMgr.ActivityUserInfo = ActivityMgr.ActivityUserInfoTemp
        end 
        
        CCXNotifyCenter:notify("onUploadActivityUserInfo")
        CCXNotifyCenter:notify("onGetActivityUserInfo")   
    else
        local errmsg = obj:readString()
        self:showToast(errmsg or "提交信息失败")
    end    
end

-----------获取活动玩家填写的信息 
function ActivityMgr:getActivityUserInfo()
    cclog(" Activity 获取活动玩家填写的信息")
    local obj = Write.new(1320)
    obj:send()
    
end
function ActivityMgr:getActivityUserInfoClub()
    cclog(" ActivityClub 获取活动玩家填写的信息")
    local obj = Write.new(1320)
    obj:send()
end

function ActivityMgr:onGetActivityUserInfo(obj)
    cclog(" Activity 获取活动玩家填写的信息 回调")
    local status = obj:readByte() -- 填写了0 未填写1 
    cclog("--- status ", status)
    if status == 0 then 
        local NAME  = obj:readString()
        local wechat= obj:readString()
        local phone = obj:readString()
        local alipay = obj:readString()

        ActivityMgr.ActivityUserInfo = { name= NAME ,wechat= wechat ,phone= phone , alipay= alipay }
        cclog("-- info " ,NAME  , wechat , phone )
        CCXNotifyCenter:notify("onGetActivityUserInfo")
    end    
end

------------------room & hall 这里是只是显示控制------
--获得奖励
function ActivityMgr:onActivityRewardHall(obj)
    cclog(" Activity 活动奖励 回调 --------------------------------------------Hall ")
    local res = {}
    local pnum = obj:readShort()
    cclog(" +++ _data count ", pnum)
    for i=1,pnum do
        res[#res + 1] = obj:readInt()    --类别
    end
    print_r(res)

    --
    if ActivityMgr.UI_STATUE == ActivityMgr.UI_STATUE_HALL then 
        self:showActivityRewardStar(res)   
    else
        table.insert(ActivityMgr.starBuff , { res = res , ui_status = ActivityMgr.UI_STATUE_HALL} )
    end    
end

function ActivityMgr:onActivityRewardClub(obj)
    cclog(" Activity 活动奖励 回调 --------------------------------------------Club ")
    local res = {}
    local pnum = obj:readShort()
    cclog(" +++ _data count ", pnum)
    for i=1,pnum do
        res[#res + 1] = obj:readInt()    --类别
    end
    print_r(res)

    --
    if ActivityMgr.UI_STATUE ==ActivityMgr.UI_STATUE_CLUB then 
        self:showActivityRewardStar(res)   
    else
        table.insert(ActivityMgr.starBuff , { res = res , ui_status = ActivityMgr.UI_STATUE_CLUB} )
    end    
end

function ActivityMgr:onActivityRewardRoom(obj)
    cclog(" Activity 活动奖励 回调 --------------------------------------------Room ")
    local res = {}
    local pnum = obj:readShort()
    cclog(" +++ _data count ", pnum)
    for i=1,pnum do
        res[#res + 1] = obj:readInt()    --类别
    end
    print_r(res)

    if ActivityMgr.starBuffLoakStatus == false then 
        self:showActivityRewardStar(res)
    else
        table.insert(ActivityMgr.starBuff , { res = res , ui_status = ActivityMgr.UI_STATUE_ROOM})
    end       
end




---------------------#2222 春节-----------
-- 获取福袋数量
function ActivityMgr:getActivityClubFudai(clubID)
    cclog(" Activity 获取福袋数量clubID:", clubID)
    local obj = Write.new(1321)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:getActivityClubFudaiClub(clubID)
    cclog(" Activity 获取福袋数量clubID:", clubID)
    local obj = Write.new(1321)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:onGetActivityClubFudai(obj)
    local fudainum = obj:readInt()    --福袋数量
    CCXNotifyCenter:notify("GetActivityClubFudai" , fudainum)
end

--抽奖 
function ActivityMgr:activityLottery(clubID,times)
    cclog(" Activity 抽奖clubID:", clubID, times)
    local obj = Write.new(1322)
    obj:writeLong(clubID or 0)
    obj:writeInt(times or 0)
    obj:send()
end

function ActivityMgr:activityLotteryClub(clubID,times)
    cclog(" Activity 抽奖clubID:", clubID , times)
    local obj = Write.new(1322)
    obj:writeLong(clubID or 0)
    obj:writeInt(times or 0)
    obj:send()
end

function ActivityMgr:onGetActivityLottery(obj)
    cclog(" Activity 抽奖结果")
    local status = obj:readByte()    --结果
    cclog(" Activity status" , status)
    if status == 0 then
        -- local fudai_num = obj:readInt()
        local res = {}
        local num = obj:readShort()
        cclog(" +++ num count ", num)
        for j=1,num do
            obj:readShort()
            local info = {}
            info._type = obj:readInt()       --类型名
            info._num  = obj:readInt()       --数量

            res[#res + 1] = info
        end
        CCXNotifyCenter:notify("GetActivityLottery" , res)
        -- CCXNotifyCenter:notify("reSetFuadiNum" , fudai_num) -- 不使用，重新请求一遍
    else
        self:showToast("福袋数量不足")
        CCXNotifyCenter:notify("GetActivityLottery" , {})
    end    
end

--我的道具
function ActivityMgr:getActivityMyRes(clubID)
    cclog(" Activity 我的道具clubID:", clubID)
    local obj = Write.new(1323)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:getActivityMyResClub(clubID)
    cclog(" Activity 我的道具clubID:", clubID)
    local obj = Write.new(1323)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:onGetActivityMyRes(obj)
    local status = obj:readByte()    --结果
    if status == 0 then
        local res = {}
        local num = obj:readShort()
        cclog(" +++ num count ", num)
        for j=1,num do
            obj:readShort()
            local info = {}
            info._type = obj:readInt()    --类型名
            info._num  = obj:readInt()    --数量

            res[#res + 1] = info
        end
        CCXNotifyCenter:notify("GetActivityMyRes", res)
    else
        cclog("--#2222 没有道具")
        -- self:showToast("没有道具")
        --test
        -- CCXNotifyCenter:notify("GetActivityMyRes", {{_type=500 , _num=100} , {_type=501 , _num=101} , {_type=502 , _num=102} , {_type=503 , _num=103} , {_type=504 , _num=104} , {_type=505 , _num=105}, {_type=506 , _num=106}})
    end    
end

--前十排名详情
function ActivityMgr:getActivityRankDetail(clubID)
    cclog(" Activity 前十排名clubID:", clubID)
    local obj = Write.new(1324)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:getActivityRankDetailClub(clubID)
    cclog(" Activity 前十排名clubID:", clubID)
    local obj = Write.new(1324)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:onGetActivityRankDetail(obj)
    local num = obj:readShort()
    cclog(" +++ num count ", num)
    local res = {}
    for j=1,num do
        obj:readShort()
        local info = {}
        info._icon = obj:readString() 
        info._name = obj:readString()
        info._uid   = obj:readLong()  
        info._score = obj:readInt()   
        info._rank  = j 
        res[#res + 1] = info
    end

    CCXNotifyCenter:notify("GetActivityRankDetail",res)
end

--活动结束后领取房卡
function ActivityMgr:activityChangeCards(clubID)
    cclog(" Activity 活动结束后领取房卡clubID:", clubID)
    local obj = Write.new(1325)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:activityChangeCardsClub(clubID)
    cclog(" Activity 活动结束后领取房卡clubID:", clubID)
    local obj = Write.new(1325)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:onActivityChangeCards(obj)
    local status = obj:readByte()
    if status ==0 then 
        local cardNum = obj:readInt() -- 成功领取的数量
        self:showToast(string.format("成功领取房卡%d张", cardNum))
        CCXNotifyCenter:notify("ActivityChangeCards",cardNum)
    else
        local detail = obj:readString()
        self:showToast(detail or "没有道具")
    end    
end

--活动结束后的新春祝福红包兑换 
function ActivityMgr:activityChangeHongbao(clubID)
    cclog(" Activity 活动兑换红包clubID:", clubID)
    local obj = Write.new(1326)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:activityChangeHongbaoClub(clubID)
    cclog(" Activity 活动兑换红包clubID:", clubID)
    local obj = Write.new(1326)
    obj:writeLong(clubID or 0)
    obj:send()
end

function ActivityMgr:onActivityChangeHongbao(obj)
    cclog(" Activity 活动兑换回调")
    local status = obj:readByte()
    if status ==0 then 
        local res = {}
        local num = obj:readShort()
        cclog(" +++ num count ", num)
        for j=1,num do
            obj:readShort()
            local info = {}
            info._type = obj:readInt()    --类型名
            info._num  = obj:readInt()    --数量

            res[#res + 1] = info
        end
        CCXNotifyCenter:notify("ActivityChangeHongbao",res)
    else
        cclog("-----" , status)
        local detail = obj:readString()
        self:showToast(detail or "没有道具")
        CCXNotifyCenter:notify("ActivityChangeHongbao",{})
    end    
end
