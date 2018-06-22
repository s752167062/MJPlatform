local UI2Code = class("UI2Code", cc.load("mvc").ViewBase)

UI2Code.RESOURCE_FILENAME = "layout/SellerShare/UI2Code.csb"
UI2Code.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },
    ["btn_share"]       = {    ["varname"] = "btn_share"            ,  ["events"] = { {event = "click" ,  method ="onShare"         } }     },
    ["btn_share2friend"]= {    ["varname"] = "btn_share2friend"     ,  ["events"] = { {event = "click" ,  method ="onShare2Friend"  } }     },
    ["imagebg"]         = {    ["varname"] = "imagebg"              },
    ["Image_1"]         = {    ["varname"] = "Image_1"              },
    ["Image_2"]         = {    ["varname"] = "Image_2"              },
    ["Panel_2"]         = {    ["varname"] = "Panel_2"              }
}

function UI2Code:onCreate()
    dump("CREATE")
end

function UI2Code:onEnter()
    dump("ENTER")
end

function UI2Code:onExit()
    dump("EXIT")
end

function UI2Code:setURL(url)
    self.url = url
    if self.url and string.len(self.url) > 0 then 
         --下载二维码
        local filename = SellerShareMgr:makeFileNameByURL(self.url)
        local filepath = writePathManager:getAppPlatformWritePath().."/"..filename
        dump(" //// 2code filenmae : " .. filename)
        dump(" //// 2code url      : " .. self.url)
        if cc.FileUtils:getInstance():isFileExist(filepath) then 
            self:setImage(filepath)
            return
        end

        --下载
        local function callfunc()
            self:setImage(filepath)
        end
        SellerShareMgr:DownloadFile(self.url , filename , callfunc)
    else
        dump(" //// 二维码地址空")
    end
end

function UI2Code:setImage(filepath)
    if cc.FileUtils:getInstance():isFileExist(filepath) then 
        cc.Director:getInstance():getTextureCache():reloadTexture(filepath); -- 重新加载纹理
        local sp = cc.Sprite:create(filepath)
        if sp then 
            local size   = self.imagebg:getContentSize()
            local spsize = sp:getContentSize()

            sp:setScaleX(size.width / spsize.width)
            sp:setScaleY(size.height / spsize.height)
            sp:setAnchorPoint(cc.p(0,0))
            sp:addTo(self.imagebg)
        end
    end        
end

function UI2Code:openImg(filepath)
    self.Image_1:setVisible(false)
    self.Image_2:setVisible(true)
    self.btn_share:setVisible(false)
    self.btn_share2friend:setVisible(false)
    --显示本地下载的二维码
    if cc.FileUtils:getInstance():isFileExist(filepath) then 
        dump(" ### 显示本地下载的二维码 ",filepath)
        cc.Director:getInstance():getTextureCache():reloadTexture(filepath); -- 重新加载纹理
        local sp = cc.Sprite:create(filepath)
        if sp then 
            local size   = self.Panel_2:getContentSize()
            local spsize = sp:getContentSize()

            sp:setScaleX(size.width / spsize.width)
            sp:setScaleY(size.height / spsize.height)
            sp:setAnchorPoint(cc.p(0,0))
            sp:addTo(self.Panel_2)
        else
            dump("# sprite null")
        end
    else
        dump(" ### 显示本地下载的二维码 未找到图片",filepath)
    end   
end

------ 按钮 -------
function UI2Code:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UI2Code:onShare()
    self:shareImageMergeByType(WX_SHARE_TYPE.FRIENDS)
end

function UI2Code:onShare2Friend()
    self:shareImageMergeByType(WX_SHARE_TYPE.TIME_LINE)
end

function UI2Code:shareImageMergeByType(share_type)
    local bg_path = cc.FileUtils:getInstance():fullPathForFilename("ui/image/sellershare/SHARE_BG.jpg")

    local filename = SellerShareMgr:makeFileNameByURL(self.url or "")
    local file2codepath = writePathManager:getAppPlatformWritePath()..filename

    if cc.FileUtils:getInstance():isFileExist(file2codepath) and cc.FileUtils:getInstance():isFileExist(bg_path) then 
        -- SDKController:getInstance():shareImageMerge(bg_path , file2codepath ,SellerShareMgr._playerInfo_ss.imgheadPath  , SellerShareMgr._playerInfo_ss.name ,share_type)--
        
        local data = {}
        data[1] = {type = IMAGE_MERGE_TYPE.IMAGE , data = bg_path           , p_x = 310 , p_y = 310 , size_w = 100 , size_h = 200 , font_size = 30 , color_code = "#ff0000"}
        data[2] = {type = IMAGE_MERGE_TYPE.IMAGE , data = SellerShareMgr._playerInfo_ss.imgheadPath , p_x = 15  , p_y = 888 , size_w = 120 , size_h = 120 , font_size = 30 , color_code = "#ff0000"}
        data[3] = {type = IMAGE_MERGE_TYPE.IMAGE , data = file2codepath , p_x = 440 , p_y = 870 , size_w = 180 , size_h = 180 , font_size = 30 , color_code = "#ff0000"}
        data[4] = {type = IMAGE_MERGE_TYPE.TXT   , data = SellerShareMgr._playerInfo_ss.name        , p_x = 210 , p_y = 930 , size_w = 100 , size_h = 200 , font_size = 30 , color_code = "#ffffff"}
        release_print("JSON DATA :" ,json.encode(data))
        SDKMgr:sdkMergeImageShareByJSON(json.encode(data) , share_type ,nil)
    else
        dump("####### 不存在图片合成")
    end    
end

return UI2Code