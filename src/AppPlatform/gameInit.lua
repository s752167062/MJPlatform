--@游戏全局单例注册
--注册方式:singleMgr:register("文件名","别名",初始化参数(将传入ctor()方法))
--使用方法:别名:fun()

cc.FileUtils:getInstance():setPopupNotify(false)

-- local tb = cc.FileUtils:getInstance():getSearchPaths()
-- for k,v in pairs(tb) do
--     print("path3_"..k,v)
-- end

--非全路径，默认搜索app路径+搜索路径+文件名
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
-- cc.FileUtils:getInstance():addSearchPath("res/ui")
--全路径，则直接搜索全路径+文件名（热更需要注意）

for k,v in ipairs(G_WRITEABLEPATH) do
    local writePath = v
    local tb = cc.FileUtils:getInstance():getSearchPaths()
    table.insert(tb, 1, writePath.."src/")
    table.insert(tb, 1, writePath.."res/")
    -- table.insert(tb, 1, writePath.."res/ui")
    cc.FileUtils:getInstance():setSearchPaths(tb)
end

-- local tb = cc.FileUtils:getInstance():getSearchPaths()
-- for k,v in pairs(tb) do
--     print("path4_"..k,v)
-- end

-- print(package.path);
-- print(package.cpath);





















cclog = function(...)
    release_print(...)
end

print = function(...)
    release_print(...)
end

require "mime"--录像用

local function registerSingle(app)

    --扩展游戏环境管理类
    singleMgr:register("app.ctrls.externGameEnvMgr_ctrl","externGameEnvMgr",nil)
    --扩展游戏管理类
    singleMgr:register("app.ctrls.externGameMgr_ctrl","externGameMgr",nil)
    --平台提供给扩展游戏的接口类
    singleMgr:register("app.ctrls.platformExportMgr_ctrl","platformExportMgr",nil)
    --平台通知扩展游戏的事件
    singleMgr:register("app.ctrls.PlatformExportEventMgr_ctrl","platformExportEventMgr",nil)
    --扩展游戏下载类
    singleMgr:register("app.ctrls.downGameMgr_ctrl","downGameMgr",nil)
    --更新页面管理类
    singleMgr:register("app.ctrls.launcherSceneMgr_ctrl","launcherSceneMgr",nil)
    --lua文件存储类
    singleMgr:register("app.ctrls.LuaFileUtils_ctrl","luaFileUtils",nil)

    --俱乐部管理类
    singleMgr:register("app.ctrls.clubMgr_ctrl","clubMgr",nil)

    --协议请求管理类
    singleMgr:register("app.ctrls.socket.HallSendMgr","hallSendMgr",nil)

    --网关协议请求管理类
    singleMgr:register("app.ctrls.socket.GatewaySendMgr","gatewaySendMgr",nil)

    --全局write方法
    singleMgr:register("app.ctrls.socket.Write","Write",nil)
    
    --计时器管理类
    singleMgr:register("app.ctrls.timerMgr_ctrl","timerMgr",nil)
    --当前场景UI管理类
    singleMgr:register("app.ctrls.viewMgr_ctrl","viewMgr",app)
    --游戏状态机类
    singleMgr:register("app.ctrls.gameState_ctrl","gameState",app)
    --游戏配置类
    singleMgr:register("app.ctrls.gameConfMgr_ctrl","gameConfMgr",nil)
    --公共函数类
    singleMgr:register("app.ctrls.comFunMgr_ctrl","comFunMgr",nil)
    --音效管理类
    singleMgr:register("app.ctrls.audioMgr_ctrl","audioMgr",nil)
    --特效管理类
    singleMgr:register("app.ctrls.effectMgr_ctrl","effMgr",nil)
    --文本信息管理类
    singleMgr:register("app.ctrls.msgMgr_ctrl","msgMgr",nil)
    --SDK管理类
    singleMgr:register("app.ctrls.sdkMgr_ctrl","SDKMgr",nil)
    --平台功能函数管理类
    singleMgr:register("app.ctrls.platformMgr_ctrl","platformMgr",nil)
    --游戏网络层管理类
    singleMgr:register("app.ctrls.gameNetMgr_ctrl","gameNetMgr",nil)
    --游戏增量更新管理类
    singleMgr:register("app.ctrls.updateMgr_ctrl","updateMgr",nil)
    --事件管理类
    singleMgr:register("app.ctrls.eventMgr_ctrl","eventMgr",nil)
    --游戏数据类
    singleMgr:register("app.ctrls.comDataMgr_ctrl","comDataMgr",nil)
    --分销模块
    singleMgr:register("app.ctrls.SellerShareManager","SellerShareMgr",nil) 

    --跑马灯管理类
    singleMgr:register("app.ctrls.marqueeMgr_ctrl","marqueeMgr",nil)
end

--@游戏全局变量注册(禁止注册任何业务全局变量)
local function registerGlobValue()
    --游戏状态机状态类型
    GAMESTATE = {
    STATE_NO                = 0,--无状态
    STATE_LOGO              = 1,--LOGO状态
    STATE_LOGIN             = 2,--登录状态
    STATE_UPDATE            = 3,--更新状态
    STATE_COMMHALL          = 4,--大厅状态(综合大厅)
    STATE_HALL              = 5,--大厅(游戏大厅)
    STATE_ROOM              = 6,--房间状态
    STATE_OVER              = 7,--结算状态(总结算)
    STATE_CLUB              = 8}--俱乐部状态
    
    --游戏网络线路
    GAME_NET_LINE = {
        LINE_NO         = 0,--无线路
        LINE_LIANTONG   = 1,--联通
        LINE_DIANXIN    = 2,--电信
        LINE_YIDONG     = 3,--移动
        LINE_YOUXIDUN   = 4}--游戏遁
    --网络SOCKET类型
    GAME_SOCKET_TYPE = {
        SOCKET_TYPE_HALL = 1,   --大厅类型
        SOCKET_TYPE_ROOM = 2,   --房间类型
        SOCKET_TYPE_CLUB = 3}   --俱乐部类型
    --网络SOCKET状态
    GAME_SOCKET_STATE = {
        SOCKET_STATE_NORMAL     = 1,   --正常
        SOCKET_STATE_RETRY      = 2,   --重连
        SOCKET_STATE_CLOSED     = 3,   --关闭
        SOCKET_STATE_DESTORY    = 4}   --销毁
    --服务器类型
    GAME_SERVER_TYPE = {
        SERVER_TYPE_GATE         = 1,   --网关
        SERVER_TYPE_HALL         = 2,   --游戏大厅
        SERVER_TYPE_ROOM         = 3,   --游戏房间
        SERVER_TYPE_CLUB         = 4,   --游戏俱乐部
        SERVER_TYPE_LOGIN         = 5,   --登录
        SERVER_TYPE_COMMHALL     = 6}   --公共大厅   

    --玩家方位
    SITE_DIR = {
        MY_SELF         = 1,    --自己
        LEFT            = 2,    --左
        RIGHT           = 3,    --右
        UP              = 4,    --上
        NO              = -1}   --无
    
    --@分享场景
    SHARE_SCENE = {
        NORMAL = 0,
        REQUEST = 1,
        HALL=2,
        SUMMARY = 3,
    }
    --微信分享类型
    WX_SHARE_TYPE = {
        FRIENDS         = 0,    --微信好友
        TIME_LINE       = 1}    --盆友圈 
    --图片合并类型
    IMAGE_MERGE_TYPE = {
        IMAGE           = 0,    --图片
        TXT             = 1}    --文本

    --分享平台类型
    SHARE_PLATFORM_TYPE = {
        WECHAT         = 0,    --微信
        DD             = 1}    --钉钉

    --资源路径
    GAME_UTILS_MJ_PATH = "layout/game/game_utils_mj/"
    VIEW_PATH = "layout/"

    --全局单例管理对象
    singleMgr = require("app.ctrls.singleMgr_ctrl"):new()

    LOG = function(...)
        local str = ""
        local data = {...}
        if data and #data >= 1 and type(data[1]) == "table" then
            local value = data[1]
            local desciption = data[2]
            local nesting = data[3]
            if type(nesting) ~= "number" then 
                nesting = 3 
            end
            local lookupTable = {}
            local result = {}
            local function dump_value_(v)
                if type(v) == "string" then
                    v = "\"" .. v .. "\""
                end
                return tostring(v)
            end
            local function dump_(value, desciption, indent, nest, keylen)
                desciption = desciption or "<val>"
                local spc = ""
                if type(keylen) == "number" then
                    spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
                end
                if type(value) ~= "table" then
                    result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
                elseif lookupTable[tostring(value)] then
                    result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
                else
                    lookupTable[tostring(value)] = true
                    if nest > nesting then
                        result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
                    else
                        result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
                        local indent2 = indent.."    "
                        local keys = {}
                        local keylen = 0
                        local values = {}
                        for k, v in pairs(value) do
                            keys[#keys + 1] = k
                            local vk = dump_value_(k)
                            local vkl = string.len(vk)
                            if vkl > keylen then keylen = vkl end
                            values[k] = v
                        end
                        table.sort(keys, function(a, b)
                            if type(a) == "number" and type(b) == "number" then
                                return a < b
                            else
                                return tostring(a) < tostring(b)
                            end
                        end)
                        for i, k in ipairs(keys) do
                            dump_(values[k], k, indent2, nest + 1, keylen)
                        end
                        result[#result +1] = string.format("%s}", indent)
                    end
                end
            end
            dump_(value, desciption, "\32\32", 1)
            str = str.."LOG FROM:"
            str = str..string.trim(string.split(debug.traceback("", 2), "\n")[3]).."\n"
            for i, line in ipairs(result) do
                str = str..line
                str = str.."\n"
            end
        else
            str = str.."LOG FROM:"
            str = str..string.trim(string.split(debug.traceback("", 2), "\n")[3]).."\n"
            str = str.."<val> = "
            str = str..string.format(...)
        end
        print(str) 
    end
end

function appStart()
    registerGlobValue()
    registerSingle(require("app.MyApp"):create())

    

    appPlatformGlobalManager:disableGlobalValue()
    -- cc.disable_global()--禁止全局变量
    gameState:changeState(GAMESTATE.STATE_LOGO)
end