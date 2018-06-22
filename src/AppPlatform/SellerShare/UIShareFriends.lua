local UIShareFriends = class("UIShareFriends", cc.load("mvc").ViewBase)

UIShareFriends.RESOURCE_FILENAME = "layout/SellerShare/UIShareFriends.csb"
UIShareFriends.RESOURCE_BINDING = {
    ["btn_close"]       = {    ["varname"] = "btn_close"    ,  ["events"] = { {event = "click" ,  method ="onBack"  } }     },
    ["ctn_mine"]        = {    ["varname"] = "ctn_mine"             },
    ["listview"]        = {    ["varname"] = "listview"             }
}

local num = 3 -- 每行的人数
local pageindex = 1
local pagesize  = 12
function UIShareFriends:onCreate()
    dump("CREATE")
    self.userdata = {}
end

function UIShareFriends:onEnter()
    dump("ENTER")
    pageindex = 1

    self:initSuperiorPlayerInfo(self.info)
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:initData(data) end,"onUser_acquire_junior_account")

    eventMgr:registerEventListener("onUser_acquire_junior_account"      ,handler(self,self.initData     ),"UIShareFriends")
    SellerShareMgr:User_acquire_junior_account(pageindex , pagesize)
end

function UIShareFriends:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget("UIShareFriends")
    -- CCXNotifyCenter:unListenByObj(self)
end

function UIShareFriends:initData(result_)
    -- 累加列表
    if result_ ~= nil and #result_.res > 0 then
        local data = result_.res
        for i=1,#data do
            self.userdata[#self.userdata +1] = data[i]
        end

        for i=((pageindex -1)*pagesize) +1 , #self.userdata , num do
            local layout = self:createLayout(i);
            if layout then 
                self.listview:pushBackCustomItem(layout)
            end    
        end

        if (result_.max_page or 0 ) > pageindex then 
            dump("********* 请求下一页")
            pageindex = pageindex + 1
            SellerShareMgr:User_acquire_junior_account(pageindex , pagesize)
        else
            dump("********* 列表全部获取完，开始下载头像")
            self:downloadHeadImgOneByOne()--下载本页的玩家头像
        end   
        

    else
        dump("********* 没有数据 *********")
        self:downloadHeadImgOneByOne()--下载本页的玩家头像
    end
end

function UIShareFriends:initPlayerInfo(info)
    self.info = info
end
--上级
function UIShareFriends:initSuperiorPlayerInfo(info)
    print_r(info)
    if info then 
        local imghead = info.superior_iconUrl or ""
        local name =  info.superior_nickname or ""
        local id = info.superior_id or ""
        if string.len(imghead) <= 0 and string.len(name) <= 0 and string.len(id) <= 0 then
            dump("-- 不存在上级用户 --")
            return 
        end  
        if id * 1 == 0 then id = "" end   

        local item = display.newCSNode("layout/SellerShare/item_head.csb")
        local txt_name  = item:getChildByName("txt_name")
        local txt_id    = item:getChildByName("txt_id")
        local img_head  = item:getChildByName("img_head")

        txt_name:setString(name)
        txt_id:setString(id)
        self.ctn_mine:addChild(item)

        --下载头像
        local filename = SellerShareMgr:makeFileNameByURL(imghead)
        dump(" //// superior_iconUrl filenmae : ",filename)
        local filepath = writePathManager:getAppPlatformWritePath().."/"..filename
        local function callfunc()
            dump("//// 下载图片回调")
            if cc.FileUtils:getInstance():isFileExist(filepath) then 
                cc.Director:getInstance():getTextureCache():reloadTexture(filepath); -- 重新加载纹理
                local sp = cc.Sprite:create(filepath)
                if sp then 
                    dump(" init superior img ",img_head)
                    local size   = img_head:getContentSize()
                    dump(" init superior img 2")
                    local spsize = sp:getContentSize()
                    dump(" init superior img 3")

                    sp:setScaleX(size.width / spsize.width)
                    sp:setScaleY(size.height / spsize.height)
                    sp:setAnchorPoint(cc.p(0,0))
                    sp:addTo(img_head)
                    dump(" init superior img added")
                end
            end        
        end

        if cc.FileUtils:getInstance():isFileExist(filepath) then
            callfunc() -- 
        else
            SellerShareMgr:DownloadFile(imghead , filename , callfunc)
        end
        
    end    
end


function UIShareFriends:createLayout(index)
    dump(" --- plane index " ,index)
    local panel = ccui.Layout:create()
    panel:setContentSize(cc.size(760,100))
    panel:setColor(cc.c4b(255,255,180,180))
    panel:setAnchorPoint(cc.p(0.5,0.5))
    panel:setName("PLANE")
    for i = 0, num-1 do
        local data = self.userdata[index + i]
        if data then 
            local item = self:createItem(index + i)
            item:addTo(panel)
        end    
    end
    return panel
end

function UIShareFriends:createItem(index)
    dump(" --- createItem ",index)
    local item  = display.newCSNode("layout/SellerShare/item_head.csb")
    local txt_name  = item:getChildByName("txt_name")
    local txt_id    = item:getChildByName("txt_id")

    --设置数据
    local data = self.userdata[index]
    if data then 
        local id = data.junior_id or ""
        if id * 1 == 0 then id = "" end   

        txt_id:setString(id or "")
        txt_name:setString(data.junior_nickname or "")
    else
        dump("没有数据的项")
    end  

    --设置位置
    local t1,t2 = math.modf((index - 1 )/num);
    local x = (t2 * 790) + 50
    local y = 50

    item:setPosition(cc.p(x,y))
    item:setName("ITEM"..index)
    return item
end

function UIShareFriends:downloadHeadImgOneByOne()
    --one by one 下载图片
    dump(" --- 下载 ： index , pagesize , @userdata " , pageindex , pagesize , #self.userdata )
    for i=1,#self.userdata do -- ((pageindex -1)*pagesize) +1
        dump("  下载 ++ " ,i )
        local data = self.userdata[i]
        if data then 
            local filename = SellerShareMgr:makeFileNameByURL(data.junior_iconUrl)
            dump(" //// friends _ filename ",filename)
            local filepath = writePathManager:getAppPlatformWritePath().."/"..filename
            local function callfunc()
                dump("//// 下载图片回调")
                if cc.FileUtils:getInstance():isFileExist(filepath) then 
                    cc.Director:getInstance():getTextureCache():reloadTexture(path); -- 重新加载纹理
                    local sp = cc.Sprite:create(filepath)
                    if sp then 
                        local index = math.modf((i - 1)/num);
                        local item  = self.listview:getItem(index) -- 起始0
                        if item then 
                            dump(index , " ----- set img " , "ITEM",i)
                            local root  = item:getChildByName("ITEM"..i)
                            local img   = root:getChildByName("img_head")
                            local size  = img:getContentSize()
                            local spsize = sp:getContentSize()

                            sp:setScaleX(size.width / spsize.width)
                            sp:setScaleY(size.height / spsize.height)
                            sp:setAnchorPoint(cc.p(0,0))
                            sp:addTo(img)
                        end    
                    end    
                end    
            end
            if cc.FileUtils:getInstance():isFileExist(filepath) then
                callfunc() --
            else    
                SellerShareMgr:DownloadFile(data.junior_iconUrl , filename , callfunc)
            end
        end
    end
end

function UIShareFriends:createSpriteByFile(filename)
    -- body
end

------ 按钮 -------
function UIShareFriends:onBack()
    dump(" --- onBack")
    self:removeFromParent()
end

return UIShareFriends