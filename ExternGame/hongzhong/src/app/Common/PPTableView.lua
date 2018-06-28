local PPTableView = class("PPTableView")

function PPTableView:ctor(scrollView, cellWidget, cellNum, cellSize, target)
    --从属控件
    self.m_scrollView = scrollView

    --cell控件
    self.m_cellWidget = cellWidget

    --引用计数加1，记住retain，必定会release(引用计数减1) 
    self.m_cellWidget:retain()

    --cell的宽高
    self.m_cellWidth    = cellSize.width or 1
    self.m_cellHeight   = cellSize.height or 1
    cclog("m_cellWidth, m_cellHeight", self.m_cellWidth, self.m_cellHeight)

    --cell数量 = tabview的高度 / 单个cell的高度 + 1
    self.m_cellNum = cellNum

    --回调对象
    self.target = target

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

    --设置是否回弹
    --self.m_tableView:setBounceEnabled( self.m_scrollView:isBounceEnabled() )
    --设置滚动方向
	self.m_tableView:setDirection( self.m_scrollView:getDirection() )
    --竖直从上往下排列
	self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    --设置代理
	self.m_tableView:setDelegate()

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

function PPTableView:tableCellAtIndex(view, idx)
	local index = idx + 1
	local cell = view:dequeueCell()

    if nil == cell then
        cell = cc.TableViewCell:new()

        --创建列表项
        local item = self.m_cellWidget:clone()
        item:setPosition(cc.p(0, 0))
        item:setTag(123)
        cell:addChild(item)

        --不吞噬触摸事件  
        item:setSwallowTouches(false)

        if self.target and self.target.setTableViewCell then
            self.target:setTableViewCell(item, index)
        end
    else
        local item = cell:getChildByTag(123)
        if item then
            if self.target and self.target.setTableViewCell then
                self.target:setTableViewCell(item, index)
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