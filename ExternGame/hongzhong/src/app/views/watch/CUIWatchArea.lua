local CUIWatchArea = class("CUIWatchArea",function() 
    return cc.Node:create()
end)

function CUIWatchArea:ctor()--data,isWatch)
    self.root = display.newCSNode("watch/CUIWatchArea.csb")
    self.root:addTo(self)
end

function CUIWatchArea:setWatchList(data,isWatch)

    local bg = self.root:getChildByName("bg")
    self.witchlist =  self.root:getChildByName("watchlist")
    self.witchlist:removeAllItems()

    if data and #data > 0 or isWatch then
        self.root:getChildByName("txt_tip"):setVisible(false)
        local flag = false
        for i=1,#data do
            if data[i].id == PlayerInfo.playerUserID then
                flag = true
                break
            end
        end
        if flag == false and isWatch then
            table.insert(data,1,{id=PlayerInfo.playerUserID,img=PlayerInfo.headimgurl})
        end

        local w,h = 100*(#data),90*(math.ceil(#data/5))
        if w > 400 then
            w = 400
        end
        if w < 200 then
            w = 200
        end

        if h< 100 then
            h = 100
        end
        if h > 250 then
            h = 250
        end
        bg:setContentSize(w,h)
        self.witchlist:setContentSize(w-20,h-20)
        
        for index = 1, math.ceil(#data/5) do
            local layout = ccui.Layout:create()
            layout:setContentSize(cc.size(w-20,80))
            
            for j=1,5 do
                if (index-1)*5+j <= #data then
                    local item = ex_fileMgr:loadLua("app.views.watch.CUIWatch_guanzhong").new(data[(index-1)*5+j])
                    item:setPosition(cc.p((j-1)*75+40,40))
                    item:addTo(layout)
                end
            end
            self.witchlist:pushBackCustomItem(layout)
        end
    else
        bg:setContentSize(200,100)
        self.witchlist:setContentSize(180,80)
        self.root:getChildByName("txt_tip"):setVisible(true)
    end
end

return CUIWatchArea