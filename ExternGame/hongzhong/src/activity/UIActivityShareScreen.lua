local uiActivityShareScreen = class("uiActivityShareScreen", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

uiActivityShareScreen.RESOURCE_FILENAME = "activity2/uiActivityShareScreen.csb"
uiActivityShareScreen.RESOURCE_BINDING = {
    ["btn_share"]      = {    ["varname"] = "btn_share"               ,  ["events"] = { {event = "click" ,  method ="onShare"    } }       },
    ["btn_getreward"]  = {    ["varname"] = "btn_getreward"           ,  ["events"] = { {event = "click" ,  method ="onReward"    } }       },
}

function uiActivityShareScreen:onCreate()
    cclog("CREATE")
end

function uiActivityShareScreen:onEnter()
    cclog("ENTER")
    self:shareScreenShot()
end

function uiActivityShareScreen:onExit()
    cclog("EXIT")
end

function uiActivityShareScreen:showMsg(MSG)
    self.txt_msg:setString(MSG or "")
end


--截图
function uiActivityShareScreen:screenShot(filename , scale,type)
    local size = cc.Director:getInstance():getVisibleSize()
    local renderTexture = cc.RenderTexture:create(size.width * scale, size.height * scale , cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888 , 0x88F0) 
    renderTexture:retain()
    local scene = cc.Director:getInstance():getRunningScene();
    local point = scene:getAnchorPoint()
    --渲染纹理捕捉
    renderTexture:begin()

    --缩小屏幕截屏区域
    scene:setScale(scale)
    scene:setAnchorPoint(cc.p(0,0))
    scene:visit()     --绘制场景

    local function name()
        renderTexture:endToLua()
        
        local path = ex_fileMgr:getWritablePath()
        renderTexture:saveToFile(filename ,cc.IMAGE_FORMAT_PNG )
        --恢复屏幕尺寸
        scene:setScale(1);  
        scene:setAnchorPoint(point);

        if ex_fileMgr:isFileExist(path.."/"..filename) then
            cclog(" ----- 截图完成 "..path .. "/"..filename)
        end
        if scale == 1 then
            ex_audioMgr:playEffect("sound/screenShot.mp3",false)
            self:screenShot("thumb.png" , 240 / cc.Director:getInstance():getVisibleSize().width ,type)
        else
            local function wecharShare()
                self:removeFromParent()
                if ex_fileMgr:isFileExist(path.."/thumb.png") and ex_fileMgr:isFileExist(path.."/screenshot.png") then
                    if type == nil then
                        SDKController:getInstance():shareScreenShot(ex_fileMgr:getWritablePath())
                    elseif type == "QQ" or type == "ALIPAY" then
                        SDKController:getInstance():umengShareLocalImg(type , path.."/screenshot.png" , path.."/thumb.png")
                    elseif type == "YX" then 
                        yxsdkMgr:sdkImageShare(path.."/screenshot.png" , 0 , nil) 
                    end
                else
                    cclog(" --- 截屏文件不全 ")
                    ActivityMgr:showToast("截图失败")
                    OnShareScreenShotComp("0,文件不全")
                end
            end
            
            local ac = cc.DelayTime:create(scale)
            local ac2 = cc.CallFunc:create(wecharShare)  
            scene:runAction(cc.Sequence:create({ ac , ac2}))
        end     
    end

    local scheduler = cc.Director:getInstance():getScheduler()  
    local schedulerID = nil  
    schedulerID = scheduler:scheduleScriptFunc(function()  
        name()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
    end,0,false)    
    
end

function uiActivityShareScreen:shareScreenShot(type)
    local path = ex_fileMgr:getWritablePath()
    if ex_fileMgr:isFileExist(path.."/thumb.png") then
        os.rename(path.."/thumb.png", path.."/"..os.time()..".png")
    end
    if ex_fileMgr:isFileExist(path.."/screenshot.png") then
        os.rename(path.."/screenshot.png", path.."/"..os.time()..".png")
    end

    self:screenShot("screenshot.png" , 1,type)
end


------ 按钮 -------
function uiActivityShareScreen:onShare()
    cclog("-------onShare")
    -- self:removeFromParent()
end

function uiActivityShareScreen:onReward()
    cclog("-------onReward")
    -- self:removeFromParent()
end

return uiActivityShareScreen