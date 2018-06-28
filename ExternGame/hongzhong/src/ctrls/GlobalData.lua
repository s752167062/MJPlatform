GlobalData = {}
GlobalData.game_product = "hz"

GlobalData.HallKey = ""
GlobalData.HallIP = ""
GlobalData.HallPort = 0

GlobalData.roomKey = ""
GlobalData.serverID = 0
GlobalData.roomIP = ""
GlobalData.roomPort = 0
GlobalData.roomID = 0

GlobalData.openRoom = true--是不是自己开的房
-- GlobalData.isRoomToHall = false
GlobalData.isRetryConnect = false

GlobalData.code_data = nil

GlobalData.CartNum = 0

GlobalData.HallRetryCnt = 0--大厅重连次数
GlobalData.RoomRetryCnt = 0--房间重连次数

-- GameRule.MAX_GAMECNT = 1
-- GameRule.cur_GameCNT = 1
-- GameRule.ZhaMaCNT = 2

GlobalData.EffectsVolume = 50
GlobalData.MusicVolume = 50

GlobalData.suammaryToHall = false
--应对大厅开房、加房时候的重连
GlobalData.connectRoomNumber = nil--加的房号
GlobalData.connectRoomCNT = nil --开房数据局-数
GlobalData.connectRoomZhaMa = nil --开房数据-扎码数

GlobalData.matchTime = nil --比赛的时间
GlobalData.isMatchRoom = false

GlobalData.hasTry = false

GlobalData.canShop = true;  -- 默认应该是 false

GlobalData.log = ""

GlobalData.isEnterGame = false

GlobalData.MatchAllNum = 0
GlobalData.MatchCurrNum = 0

GlobalData.roomCreateID = 0
GlobalData.roomCreateName = ""-- name
GlobalData.roomCreateImgUrl = ""
SceneType_None= 0
SceneType_Login = 1
SceneType_Hall = 2
SceneType_Game = 3
SceneType_Match = 4 --比赛
SceneType_Club = 5 --俱乐部
GlobalData.curScene = SceneType_None

GlobalData.NotifyContexts = {}
GlobalData.isLoginOut = false

GlobalData.startLine = 1

GlobalData.BaseVersion = ""


GlobalData.shiming_name = ""
GlobalData.shiming_id = ""
GlobalData.shiming_success = false

-- GameRule.canDaiKai = true
-- GameRule.isQiXiaoDui = 0
-- GameRule.isMiLuoHongZhong = 0

GlobalData.notIP = false -- true为关闭IP检测功能
GlobalData.notGPS = false -- true为关闭GPS检测功能

--GlobalData.dotimes = 0
--GlobalData.MAXTIMES = 3
--GlobalData.doAgainURL = nil

GlobalData.lineNet = ""

function GlobalData:initData()
    GlobalFun:getImei()
    --[[
    if Game_conf.log then
        local path = ex_fileMgr:getWritablePath() .. "timeError.log"
        GlobalData.log = ccx_read(path)
    end]]
end
