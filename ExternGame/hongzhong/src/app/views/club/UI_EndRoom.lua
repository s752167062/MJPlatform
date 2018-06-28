
local UI_EndRoom = class("UI_EndRoom", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_EndRoom:ctor(data)
	self.app = data.app
    self.root = display.newCSNode("club/UI_EndRoom.csb")
    self.root:addTo(self)
    
	UI_EndRoom.super.ctor(self)
	_w = self._childW




	CCXNotifyCenter:listen(self,function(obj,key,data) self:res_onOpenRoomList(data) end, "res_onOpenRoomList")
	CCXNotifyCenter:listen(self,function(obj,key,data) self:onDeleteRoom(data.roomID) end, "CLUB:onDeleteRoom")
	


	self.roomList2 = _w["roomList2"]



	self.readyRoomItems = {} --不当数组来用的
	self.endRoomItems = {} --不当数组来用的

	self.cur_pageIdx = 1
    self.max_pageIdx = 100
    self.txt_page = _w["txt_page"]
end

function UI_EndRoom:onEnter()
	ex_clubHandler:gotoOpenRoomList(2, 1)
end



function UI_EndRoom:onExit()
    CCXNotifyCenter:unListenByObj(self)

end



function UI_EndRoom:onClick(_sender)
	local name = _sender:getName()
    if name == "btn_close" then
        self:onUIClose()
    elseif name == "btn_last" then --列表上一页
        if self.cur_pageIdx -1 >0 then
            ex_clubHandler:gotoOpenRoomList(2, self.cur_pageIdx -1)
        end
    elseif name == "btn_next" then  --列表下一页
        if self.cur_pageIdx +1 <= self.max_pageIdx then
            ex_clubHandler:gotoOpenRoomList(2,self.cur_pageIdx +1)
        end
    end
end


function UI_EndRoom:onUIClose()
    self:removeFromParent()
end

function UI_EndRoom:setPage(cur, max)
    self.txt_page:setString(string.format("%s/%s", cur, max))
    self.cur_pageIdx = cur
    self.max_pageIdx = max
end

function UI_EndRoom:onDeleteRoom(roomID)   --删除房间，同时应该也要删除列表

	local del_list = {}
	for k,v in pairs(self.endRoomItems) do
		if v.data.id == roomID then
			
			del_list[k] = k
		end
	end

	for k,v in pairs(del_list) do
		if self:listViewRemoveItemByIdx(self.roomList2, k) then
			table.remove(self.endRoomItems, k)
		end
	end

end

function UI_EndRoom:listViewRemoveItemByIdx(listview, idx)  --删除listview的一个item
	if idx then
		listview:removeItem(idx -1)
		return true
	end

	return false
end

function UI_EndRoom:getlistViewItemByIdx(listview, idx)  --获取listview的一个item
	local item = listview:getItem(idx -1)  --c++是从0开始的
	return item
end


function UI_EndRoom:res_onOpenRoomList(data)
	cclog ("UI_ClubMain:res_onOpenRoomList >>>>")
	print_r(data)
	
	if data.roomType == 2 then--已结束房间
		self:cleanEndList()
		self:setPage(data.pageIdx, data.pageMax)
		for k,v in ipairs(data.roomTb) do
			local layout = ccui.Layout:create()
        	layout:setContentSize(cc.size(772,135))
        	self.roomList2:pushBackCustomItem(layout)

        	local item = display.newCSNode("club/Item_kaifangliebiao.csb")
        	item:addTo(layout)

        	local _itemW = self:loadChildrenWidget(item)

        	self.endRoomItems[k] = {data = v}

        	
        	_itemW["gameName"]:setString("红中麻将")
			_itemW["yijieshu"]:setVisible(true)
			-- _itemW["yikaishi"]:setVisible(false)
			-- _itemW["weikaishi"]:setVisible(false)
			
			_itemW["roomID"]:setString(tostring(v.id))
			_itemW["roomRoundStr"]:setString(string.format("%s/%s局", tostring(v.finishRoundNum), tostring(v.roundNum)))
			_itemW["peopleStr"]:setString(string.format("%s/%s人", tostring(v.maxPeopleNum), tostring(v.maxPeopleNum)))

			_itemW["openRoomTime"]:setString(os.date("%Y-%m-%d %H:%M:%S", v.createTime))
			-- _itemW["surplusTime"]:setString("")

			-- _itemW["txt_zhama"]:setString(GameRule:getZhaMaTextFromServer(v.zhaNum, v.isNewMa))

			for i =1,4 do
				if i <= v.maxPeopleNum then
					_itemW["playerName_" .. i]:setString(v.playerTb[i] and v.playerTb[i].playerName or "(空位)")
					GlobalFun:uiTextCut(_itemW["playerName_" .. i])
					_itemW["score_" .. i]:setString(string.format("(%s)", v.playerTb[i].score))
					
				else
					_itemW["playerName_" .. i]:setString("")
					_itemW["score_" .. i]:setString("")
				end
			end


			-- _itemW["btn_dismiss"]:setVisible(false)

			-- _itemW["btn_delete"]:addClickEventListener(
			-- 	function (_sender)
			-- 		cclog("I'm a btn_delete")
			-- 	end)
		end

		self.roomList2:jumpToTop()
	end
end



function UI_EndRoom:cleanEndList()
	self.endRoomItems = {}
	self.roomList2:removeAllItems()
end



return UI_EndRoom










