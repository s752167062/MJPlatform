--@渲染管线着色器管理类
--@Author   sunfan
--@date     2017/07/27

local FILTERS = {
GRAY =          {require("app.GLShader.gray_filter"), 4, {0.299, 0.587, 0.114, 0.0}}
}

local Node = cc.Node

--新建shader
local function newFilter(filterName, param, nomvp)
    local filterData = FILTERS[filterName]
    assert(filterData, string.format("filter type[%s] is invalid", filterName))
    local cls, count, default = unpack(filterData)
    local paramCount = (param and #param) or 0
    if count == nil then
        if paramCount == 0 then
            return cls.new(nomvp)
        end
    elseif count == 0 then
        return cls.new(nomvp)
    else
        if paramCount == 0 then
            return cls.new(nomvp, unpack(default))
        end
        assert(paramCount == count, 
            string.format("filter.newFilter() - the parameters have a wrong amount! Expect %d, get %d.", 
            count, paramCount))
    end
    return cls.new(nomvp, unpack(param))
end

--设置滤镜参数
--@filterName     滤镜名称
--@filterParam    备用参数
--@nomvp          是否使用nomvp,默认为teue,不必关心
function Node:setFilter(filterName, filterParam, nomvp)
    if nomvp ~= false then
        nomvp = true
    end
    local filter = newFilter(filterName, filterParam, nomvp)
    local shader = filter:getShader()
    self:setGLProgramState(shader)
end

--清除shader
function Node:clearFilter()
    self:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName("ShaderPositionTextureColor_noMVP"))
end

--置灰
function Node:setGray(value)
    if value then
        self:setFilter("GRAY")
        self._isGray = true
    else
        self:clearFilter()
        self._isGray = false
    end
end

--果冻效果
function Node:setJelly(value)
    if value then
        local actionAccessGameList = {
            [1] = cc.EaseOut:create(cc.ScaleTo:create(0.3, 0.8, 1.15), 1),
            [2] = cc.EaseIn:create(cc.ScaleTo:create(0.3, 1, 0.9), 1),
            [3] = cc.EaseOut:create(cc.ScaleTo:create(0.3, 0.9, 1.05), 1),
            [4] = cc.EaseIn:create(cc.ScaleTo:create(0.3, 1, 1), 1),
            [5] = cc.DelayTime:create(1),
        }
        self._actionAccess = cc.RepeatForever:create(cc.Sequence:create(
                actionAccessGameList[1],
                actionAccessGameList[2],
                actionAccessGameList[3],
                actionAccessGameList[4],
                actionAccessGameList[5]))
        self:runAction(self._actionAccess)
    else
        if self._actionAccess then
            self:stopAction(self._actionAccess)
            self._actionAccess = nil
        end
    end
end

--是否已置灰
function Node:isGray()
    if self._isGray == nil then
        return false
    end
    return self._isGray
end