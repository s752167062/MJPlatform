--TableView公共控件

--[[参考例子
function xxxx:resetRenmingList()
    -- body
    self.dataList = {}
    self.colNum = 5
    local cellRowNum = 10 --这里要计算有多少行   --math.ceil((#self.dataList)/self.colNum)
    local item = display.newCSNode("club/Item_test.csb"):getChildByName("itemLayout")
    self.tableView = PPTableView.new(self.renmingList, item, cellRowNum, self.colNum, cc.size(100,100), self)
end

function xxxx:tableCellHighlight(table, cell)
    cclog("tableCellHighlight")
end

function xxxx:tableCellUnhighlight(table, cell)
    cclog("tableCellUnhighlight")
end

function xxxx:setTableViewCell(layout, row)
    for i=1,self.colNum do
        local index = (row-1) * self.colNum + i
        local item = layout:getChildByTag(i)
        if item then
            cclog("row, index=",row, index)
            if index > #self.dataList then
                item:setVisible(true)
            else
                item:setVisible(true)
            end
            local img = item:getChildByName("img")
            img:setVisible(true)
            img:setTouchEnabled(true)
            img:setSwallowTouches(false)--setTouchEnabled要在setSwallowTouches 前面设置
            img:addClickEventListener(function() self:agree(index, "img") end)
        end
    end
end
--]]

local PPTableView = class("PPTableView")

function PPTableView:ctor(scrollView, cellWidget, cellNum, colNum, cellSize, target)
    --从属控件
    self.m_scrollView = scrollView
    --cell控件
    --注意：cellWidget里的child必须都是继承widget控件才会有clone方法， node是没有clone方法
    self.m_cellWidget = cellWidget
    --引用计数加1，记住retain，必定会release(引用计数减1) 
    self.m_cellWidget:retain()
    --cell的宽高
    self.m_cellWidth    = cellSize.width or 1
    self.m_cellHeight   = cellSize.height or 1
    --cell数量 = tabview的高度 / 单个cell的高度 + 1
    self.m_cellNum = cellNum
    --列，一行个数
    self.m_colNum = colNum
    --回调对象
    self.target = target

    cclog("m_cellWidth, m_cellHeight, m_cellNum, m_colNum", self.m_cellWidth, self.m_cellHeight, self.m_cellNum, self.m_colNum)
    self:init()
end

function PPTableView:init()
    self:initTableView()
end

function PPTableView:onExit()
    -- body
    self.m_cellWidget:release()
end

function PPTableView:initTableView()
    --scroll的尺寸
    local sizeScroll = self.m_scrollView:getContentSize()
    --scroll的位置坐标
    local positionScroll = cc.p(self.m_scrollView:getPositionX(), self.m_scrollView:getPositionY());

    --创建TableView
    self.m_tableView = cc.TableView:create( cc.size( sizeScroll.width, sizeScroll.height) )
    --TabelView添加到PanleMain
	self.m_scrollView:addChild(self.m_tableView)
	--self.m_tableView:setPosition(positionScroll)

    --设置滚动方向
	self.m_tableView:setDirection( self.m_scrollView:getDirection() )
    --竖直从上往下排列
	self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    --设置代理
	self.m_tableView:setDelegate()

    --self.m_tableView:registerScriptHandler( handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED) 
    --self.m_tableView:registerScriptHandler( handler(self, self.tableCellHighlight), cc.TABLECELL_HIGH_LIGHT) 
    --self.m_tableView:registerScriptHandler( handler(self, self.tableCellUnhighlight), cc.TABLECELL_UNHIGH_LIGHT) 

    self.m_tableView:registerScriptHandler( handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)           --滚动时的回掉函数
	self.m_tableView:registerScriptHandler( handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)             --列表项的尺寸
	self.m_tableView:registerScriptHandler( handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)              --创建列表项
	self.m_tableView:registerScriptHandler( handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW) --列表项的数量

    self.m_tableView:reloadData()
end

function PPTableView:scrollViewDidScroll(view)
    self.m_bMovedTableView = true
end

function PPTableView:cellSizeForTable(view, idx)
	return self.m_cellWidth, self.m_cellHeight
end

function PPTableView:numberOfCellsInTableView(view)
	return self.m_cellNum
end

-- function PPTableView:tableCellHighlight(view, cell)
--     -- body
--     if self.target and self.target.tableCellHighlight then
--         self.target:tableCellHighlight(view, cell)
--     end
-- end

-- function PPTableView:tableCellUnhighlight(view, cell)
--     -- body
--     if self.target and self.target.tableCellUnhighlight then
--         self.target:tableCellUnhighlight(view, cell)
--     end
-- end

-- function PPTableView:tableCellTouched(view, cell)
--     -- body
--     if self.target and self.target.tableCellTouched then
--         self.target:tableCellTouched(view, cell)
--     end
-- end

function PPTableView:createCell(layout)
    -- body
    local _isHor = true
    local size = self.m_cellWidget:getContentSize()
    local width = size.width
    local height = size.height
    local _interval = 0

    for i=0,self.m_colNum-1 do
        local index = i + 1--列索引
        local item = self.m_cellWidget:clone()
        item:setSwallowTouches(false)
        item:setTag(index)
        layout:addChild(item)

        local x, y = item:getPosition()
        if (_isHor == false) then
            y = self.m_cellHeight - height * i + _interval * i    
        else
            x = width * i + _interval * i
        end
        item:setPosition(cc.p(x, y))
    end
end

function PPTableView:tableCellAtIndex(view, idx)
	local index = idx + 1--行索引
	local cell = view:dequeueCell()

    if nil == cell then
        cell = cc.TableViewCell:new()

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(self.m_cellWidth,self.m_cellHeight))
        layout:setTag(123)
        layout:setPosition(cc.p(0, 0))
        cell:addChild(layout)

        layout:setSwallowTouches(false)--不吞噬触摸事件  

        --创建列表项
        self:createCell(layout)

        if self.target and self.target.setTableViewCell then
            self.target:setTableViewCell(layout, index)
        end
    else
        local layout = cell:getChildByTag(123)
        if layout then
            if self.target and self.target.setTableViewCell then
                self.target:setTableViewCell(layout, index)
            end
        end
    end
	return cell
end

function PPTableView:refresh()
    -- body
    self.m_tableView:reloadData()
end

function PPTableView:setCellNum(num)
    -- body
    self.m_cellNum = num
    self:refresh()
end

return PPTableView