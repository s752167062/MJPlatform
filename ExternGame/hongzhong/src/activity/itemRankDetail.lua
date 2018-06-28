local itemRankDetail = class("itemRankDetail", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

itemRankDetail.RESOURCE_FILENAME = "activity2/itemRankDetail.csb"
itemRankDetail.RESOURCE_BINDING = {
    ["bg1"]         = {    ["varname"] = "bg1"             },
    ["bg2"]         = {    ["varname"] = "bg2"             },
    ["icon"]        = {    ["varname"] = "icon"             },
    ["base"]        = {    ["varname"] = "base"             },
    ["txt_id"]      = {    ["varname"] = "txt_id"           },
    ["txt_name"]    = {    ["varname"] = "txt_name"         },
    ["txt_num"]     = {    ["varname"] = "txt_num"          },
    ["txt_mynum"]   = {    ["varname"] = "txt_mynum"         },
}

function itemRankDetail:onCreate()
    cclog("CREATE")
    self.callfunc = nil
    self.isUIExit = true
end

function itemRankDetail:onEnter()
    cclog("ENTER")
end
function itemRankDetail:onExit()
    cclog("EXIT")
    self.iscreate = nil
end

function itemRankDetail:initData(data)
    if data then 
        self.data = data
        local _icon =data._icon
        local _name =data._name
        local _uid  =data._uid
        local _score=data._score
        local _rank =data._rank

        self.txt_id:setString(_uid or "0")
        self.txt_name:setString(_name or "0")
        self.txt_num:setString(string.format("福蛋 X%d", _score or 0))
        self.txt_mynum:setString(_rank or "0")

        local rank = tonumber(_rank or 0) or 0
        if rank >0 and rank <4 then 
            local img_rank = self.txt_mynum:getChildByName("no"..rank)
            if img_rank then
                img_rank:setVisible(true)
            end 
        elseif rank == 0 then
            self.txt_mynum:setString("")
            local norank = self.txt_mynum:getChildByName("norank")
            if norank then 
                norank:setVisible(true)
            end
        end    

        local tag = math.fmod(_rank , 2)
        self.bg1:setVisible(tag == 1)
        self.bg2:setVisible(tag == 0)

        self:downloadIcon(_icon)
    end    
end

function itemRankDetail:setIcon(index)
    cclog("---#ccc index ", index , self.data._rank)
    if self.data and self.data._rank == index and self.isUIExit then 
        local iconpath = self.data._icon
        local filename = ActivityMgr:makeFileNameByURL(iconpath)
        local ablepath = ex_fileMgr:getWritablePath()
        if ex_fileMgr:isFileExist(ablepath .. filename) then 
            local head = cc.Sprite:create(ablepath .. filename)
            if head then 
                local size_head = head:getContentSize()
                local size_bg   = self.base:getContentSize()
                head:setScaleX( (size_bg.width  - 3) / size_head.width)
                head:setScaleY( (size_bg.height - 3) / size_head.height)
                head:setPosition(cc.p( 25, 25))

                self.base:addChild(head)
            end
        else
            cclog("----- 并没有发现头像文件 ----- #2222")
        end    
    end    
end

function itemRankDetail:downloadIcon(iconpath)
    local filename = ActivityMgr:makeFileNameByURL(iconpath)
    local ablepath = ex_fileMgr:getWritablePath()
    if ex_fileMgr:isFileExist(ablepath .. filename) then 
        self:setIcon(self.data._rank)
    else
        local function callfunc()
            self:setIcon(self.data._rank)
        end
        ActivityMgr.DownloadFile(iconpath , filename , callfunc)
    end   
end


return itemRankDetail