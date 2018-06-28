local itemRanker = class("itemRanker", ex_fileMgr:loadLua("packages.mvc.ViewBase"))

itemRanker.RESOURCE_FILENAME = "activity2/itemRanker.csb"
itemRanker.RESOURCE_BINDING = {
    ["head_2"]  = {    ["varname"] = "head_2"      },
    ["no1"]  = {    ["varname"] = "no1"      },
    ["no2"]  = {    ["varname"] = "no2"      },
    ["no3"]  = {    ["varname"] = "no3"      },
    ["txt_name"]     = {    ["varname"] = "txt_name"         },
    ["txt_id"]       = {    ["varname"] = "txt_id"           },
    ["txt_starnum"]  = {    ["varname"] = "txt_starnum"      },

}

function itemRanker:onCreate()
    cclog("CREATE")
end

function itemRanker:onEnter()
    cclog("ENTER")

end

function itemRanker:onExit()
    cclog("EXIT")
end


function itemRanker:initData(data)
    if data then 
        local icon_path = data._iconpath
        local name      = data._name
        local id    = data._id
        local score = data._score
        local rank  = data._rank or ""

        self.txt_name:setString(name)
        self.txt_id:setString("ID:"..id or "")
        self.txt_starnum:setString("福蛋X "..score or "")

        if self["no"..rank ] then 
            self["no"..rank]:setVisible(true)
        end  

        self:setIcon(icon_path)  
    end
end

function itemRanker:setIcon(iconpath)
    local filename = ActivityMgr:makeFileNameByURL(iconpath)
    local ablepath = ex_fileMgr:getWritablePath()
    if ex_fileMgr:isFileExist(ablepath .. filename) then 
        self:addSprite(ablepath..filename)
    else
        local function callfunc()
            cclog(" activity -- DownloadFile callback ", filename)
            self:addSprite(ablepath..filename)    
        end
        ActivityMgr.DownloadFile(iconpath , filename , callfunc)
    end    
end

function itemRanker:addSprite(filename)
    local head = cc.Sprite:create(filename)
    if head then 
        local size_head = head:getContentSize()
        local size_bg   = self.head_2:getContentSize()

        head:setScaleX( (size_bg.width - 3) / size_head.width)
        head:setScaleY( (size_bg.height - 3) / size_head.height)
        head:setPosition(cc.p( 25, 25))

        self.head_2:addChild(head)
    end
end

return itemRanker