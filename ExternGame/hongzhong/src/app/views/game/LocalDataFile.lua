

LocalDataFile = {}

-- 记录有意外 存/取都是在大厅的普通开房
-- 所有记录，都在大厅存一份，大厅的战绩相当于录像记录的汇总

function LocalDataFile:writeSummaryScore(data, originType, originKey)

    local tb = {}
    tb.roomID = data.roomID
    tb.gameCnt = data.gameCnt
    tb.name = data.name
    tb.years = tonumber(os.date("%Y"))
    tb.month = tonumber(os.date("%m"))
    tb.day = tonumber(os.date("%d"))
    tb.gameTime = os.date("%H:%M")
    tb.zhama = data.zhama

    tb.summary = data.summary
    tb.isFinish = true

    originType = originType or 0
    originKey = originKey or 0
    UserScoreFile:setRecardData(originType, originKey, data.roomID, tb, nil)

    if originType ~= UserScoreFile.originType_0 and originType ~= 0 then
        UserScoreFile:setRecardData(UserScoreFile.originType_0, 0, data.roomID, tb, nil)
    end
    
end

function LocalDataFile:writeSmallScore(data, originType, originKey)

    local tb = {}
    tb.roomID = data.roomID
    tb.gameCnt = data.gameCnt
    tb.name = data.name
    tb.years = tonumber(os.date("%Y"))
    tb.month = tonumber(os.date("%m"))
    tb.day = tonumber(os.date("%d"))
    tb.gameTime = os.date("%H:%M")
    tb.zhama = data.zhama

    tb.isFinish = false

    local branch = {}
    tb.branch = branch
    branch.currLevel = data.curr
    branch.currTime = os.date("%Y-%m-%d  %H:%M")
    branch.score = data.score

    originType = originType or 0
    originKey = originKey or 0
    UserScoreFile:setRecardData(originType, originKey, data.roomID, tb, data.curr)

    if originType ~= UserScoreFile.originType_0 and originType ~= 0 then
        UserScoreFile:setRecardData(UserScoreFile.originType_0, 0, data.roomID, tb, data.curr)
    end
    
end


function LocalDataFile:writeVideo(res, originType, originKey)
 
    originType = originType or 0
    originKey = originKey or 0

    local file = UserScoreFile:saveVideoByOriginKeyAndUniqueKey(originType, originKey, res[1].roomid , res[1].roomid , res[1].curr, res)
    UserScoreFile:copyVideoByOriginKeyAndUniqueKey(file, UserScoreFile.originType_0, 0, res[1].roomid , res[1].roomid , res[1].curr)
end





function LocalDataFile:readVideo(originType, originKey, uniqueKey, roomId, branchId)
    originType = originType or 0
    originKey = originKey or 0

    return UserScoreFile:readVideoByOriginKeyAndUniqueKey(originType, originKey, uniqueKey, roomId, branchId)
end

function LocalDataFile:readData(originType, originKey)
    cclog("LocalDataFile:readData >>>", originType, originKey)

    originType = originType or 0
    originKey = originKey or 0


    local tb = UserScoreFile:readFileByOriginKey(originType, originKey)
    local tmp = {}
    if tb and next(tb) then
        local idx = 0
        for i = #tb, 1, -1 do
            idx = idx+1
            tmp[idx] = tb[i]
        end
    end

    return tmp
end




