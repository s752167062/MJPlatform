
local UI_RoomCardRecord = class("UI_RoomCardRecord", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))
local _w = nil
function UI_RoomCardRecord:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_RoomCardRecord.csb")
    self.root:addTo(self)

	UI_RoomCardRecord.super.ctor(self)
    _w = self._childW
    
	self:initUI()
	self:setMainUI()
end

function UI_RoomCardRecord:initUI()
	self.btn_close    		= _w["btn_close"]
	self.btn_left    		= _w["btn_left"]
	self.btn_right    		= _w["btn_right"]
	self.list     			= _w["list"]
	self.txt_pageNum    	= _w["txt_pageNum"]

end

function UI_RoomCardRecord:setMainUI()
	CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onRoomCardRecord(data) end, "S2C_onGiveRoomCardRecord")
	
	self.list:setScrollBarWidth(0.1)	
end


function UI_RoomCardRecord:onEnter()

	self._roomCardTb = nil
	self._roomCardShowTb = nil
	self._roomCardSumPage = 0
	self._roomCardcurPage = 0

	self:setPage_RoomCardStatistics()
	
	local clubID = ClubManager:getClubID()
	ex_clubHandler:toGiveRoomCardRecord(clubID, 1)


	-- self:res_onRoomCardRecord()
end

function UI_RoomCardRecord:onExit(  )
	CCXNotifyCenter:unListenByObj(self)
end

function UI_RoomCardRecord:onClick(_sender)
    -- body
    local name = _sender:getName()
    if name == "btn_close" then   
        self:closeUI()
    elseif name == "btn_left" then
    	self:paging_rc(true)
    elseif name == "btn_right" then
    	self:paging_rc(false)
    end
end

--房卡统计
function UI_RoomCardRecord:setPage_RoomCardStatistics()
	self.list:removeAllItems()
	
	self._roomCardSumPage = 0
	self._roomCardcurPage = 0
	self.txt_pageNum:setString(self._roomCardcurPage.."/"..self._roomCardSumPage)

	self:checkRoomCardRecord(1)
end

function UI_RoomCardRecord:checkRoomCardRecord(_index)
	cclog("_index:".._index)
	local clubID = ClubManager:getClubID()
	ex_clubHandler:toGiveRoomCardRecord(clubID, _index)
end

function UI_RoomCardRecord:res_onRoomCardRecord(data)
	cclog("wtf UI_RoomCardRecord:res_onRoomCardRecord")

	self.list:removeAllItems()

	
	-- local data = {}
	-- data.maxPage = 10
	-- data.curPage = 1
	-- data.pageData = {}
 -- 	for i = 1, 20 do
 --        local item = {}
 --        item.time = "2018-1-"..i
 --        item.recvName = "玩家名字七个字"
 --        item.recvID = "123456"
 --        item.recvNum = 333
 --        table.insert(data.pageData , item)
 --    end

    print_r(data)


    self._roomCardTb = data.pageData
   
    self._roomCardSumPage = data.maxPage
	self._roomCardcurPage = data.curPage

	self.txt_pageNum:setString(self._roomCardcurPage.."/"..self._roomCardSumPage)

	self:insertDataToListView()

end

function UI_RoomCardRecord:insertDataToListView()
	--设置ui item
	--self.list:removeAllItems()

	cclog("#self._roomCardTb:"..#(self._roomCardTb))

	--local lastLayout = ccui.Layout:create()
	for i, v in ipairs(self._roomCardTb) do

        local lastLayout = display.newCSNode("club/Item_roomcardrecord.csb"):getChildByName("itemLayout")
        lastLayout:removeFromParent()
        lastLayout:setTag(i)
		lastLayout:setSwallowTouches(false)
		--lastLayout:setTouchEnabled(true)
		lastLayout:addTouchEventListener(function(sender, type)
        	if type == 2 then
	        	cclog("lastLayout type:"..type.. "   tag:"..sender:getTag())
	        	self:showRoomCardDetail(sender:getTag())
	        end
        end)

        local _itemW = self:loadChildrenWidget(lastLayout)

        _itemW["content"]:setString(v.time.."    赠送   "..v.recvName.."  【ID:"..v.recvID.."】  "..v.recvNum.."张房卡")
        _itemW["content"]:setString(string.format("%s     赠送      %s [ID:%s]      %s张房卡", v.time, v.recvName, v.recvID, v.recvNum))
	    self.list:pushBackCustomItem(lastLayout)
	  
	end
end

--房卡统计翻页
function UI_RoomCardRecord:paging_rc(_flag, _isDefault)	--true左边 false右边
	local newPage = self._roomCardcurPage
	if _flag then cclog("左边") newPage = newPage - 1 end
	if not _flag then cclog("右边") newPage = newPage + 1 end
	cclog("newPage:"..newPage.."  self._roomCardSumPage:"..self._roomCardSumPage)
	if newPage > 0 and newPage <= self._roomCardSumPage then
		--符合条件
		self:checkRoomCardRecord(newPage)
	end
end

return UI_RoomCardRecord
