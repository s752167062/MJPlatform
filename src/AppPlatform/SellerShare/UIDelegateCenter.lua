local UIDelegateCenter = class("UIDelegateCenter", cc.load("mvc").ViewBase)

UIDelegateCenter.RESOURCE_FILENAME = "layout/SellerShare/UIDelegateCenter.csb"
UIDelegateCenter.RESOURCE_BINDING = {
    ["btn_base_info"]       = {    ["varname"] = "btn_base_info"    ,  ["events"] = { {event = "click" ,  method ="onBaseInfo"      } }     },
    ["btn_give_card"]       = {    ["varname"] = "btn_give_card"    ,  ["events"] = { {event = "click" ,  method ="onUIGiveCard"    } }     },
    ["btn_gived_datas"]     = {    ["varname"] = "btn_gived_datas"  ,  ["events"] = { {event = "click" ,  method ="onUIGivedDatas"  } }     },
    ["btn_close"]           = {    ["varname"] = "btn_close"        ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },

    ["ctn_base_info"]       = {    ["varname"] = "ctn_base_info"             },
    ["ctn_give_card"]       = {    ["varname"] = "ctn_give_card"             },
    ["ctn_gived_datas"]     = {    ["varname"] = "ctn_gived_datas"           },

    --基础信息
    ["txt_id"]              = {    ["varname"] = "txt_id"                   },
    ["txt_cards"]           = {    ["varname"] = "txt_cards"                },
    ["txt_mymoney"]         = {    ["varname"] = "txt_mymoney"              },
    ["btn_buy_card"]        = {    ["varname"] = "btn_buy_card"           ,  ["events"] = { {event = "click" ,  method ="onBuyCard"         } }           },
    ["btn_exchange_card"]   = {    ["varname"] = "btn_exchange_card"      ,  ["events"] = { {event = "click" ,  method ="onExChangeCard"    } }           },

    --赠送房卡
    ["txt_id2"]             = {    ["varname"] = "txt_id2"                   },
    ["txt_cards2"]          = {    ["varname"] = "txt_cards2"                },
    ["editbox_id"]          = {    ["varname"] = "editbox_id"                },
    ["editbox_num"]         = {    ["varname"] = "editbox_num"               },
    ["btn_give"]            = {    ["varname"] = "btn_give"                ,  ["events"] = { {event = "click" ,  method ="onGive"         } }           },

    --查询
    ["editbox_start"]       = {    ["varname"] = "editbox_start"              },
    ["editbox_end"]         = {    ["varname"] = "editbox_end"                },
    ["txt_pageNum"]         = {    ["varname"] = "txt_pageNum"                },
    ["listview"]            = {    ["varname"] = "listview"                   },
    ["btn_search"]          = {    ["varname"] = "btn_search"              ,  ["events"] = { {event = "click" ,  method ="onSearch"         } }           },
    ["btn_uppage"]          = {    ["varname"] = "btn_uppage"              ,  ["events"] = { {event = "click" ,  method ="onUpPage"         } }           },
    ["btn_nextpage"]        = {    ["varname"] = "btn_nextpage"            ,  ["events"] = { {event = "click" ,  method ="onNextPage"       } }           }

}
UIDelegateCenter.PAGE_NUM = 7

function UIDelegateCenter:onCreate()
    dump("CREATE")
    self.num = 1
    self.infoData = nil
    self.giveHistory = nil
    self.page_index = 1
end

function UIDelegateCenter:onEnter()
    dump("ENTER")
    self:onSelect(self.num)
    self.txt_pageNum:setString("")

    -- CCXNotifyCenter:listen(self,function(obj,key,data)  self:onGiveCardResult(data)     end,"GiveCard_to_User")
    -- CCXNotifyCenter:listen(self,function(obj,key,data)  self:onGiveHistoryData(data)    end,"GiveCard_to_User_history_data")
    -- CCXNotifyCenter:listen(self,function(obj,key,data)  self:onExChangeResult(data)     end,"Exchange_card")
    -- CCXNotifyCenter:listen(self,function(obj,key,data)  self:delegateInfo(data)         end,"RequireDelegateCenter_data")
    -- self.editbox_start:setPlaceHolder("2017-01-01")
    -- self.editbox_end:setPlaceHolder("2017-01-02")

    eventMgr:registerEventListener("GiveCard_to_User"                ,handler(self,self.onGiveCardResult     ),"UIDelegateCenter")
    eventMgr:registerEventListener("GiveCard_to_User_history_data"   ,handler(self,self.onGiveHistoryData     ),"UIDelegateCenter")
    eventMgr:registerEventListener("Exchange_card"                   ,handler(self,self.onExChangeResult     ),"UIDelegateCenter")
    eventMgr:registerEventListener("RequireDelegateCenter_data"      ,handler(self,self.delegateInfo     ),"UIDelegateCenter")

    SellerShareMgr:requireDelegateCenter_data()
end

function UIDelegateCenter:onExit()
    dump("EXIT")
    eventMgr:removeEventListenerForTarget("UIDelegateCenter")
    -- CCXNotifyCenter:unListenByObj(self)
end

--设置代理信息
function UIDelegateCenter:delegateInfo(data)
    if data then 
        self.infoData = data
        print_r(self.infoData)
        -- 用户基础数据
        local uuid    = data.uuid
        local cardNum = data.cardNum
        local money   = data.money

        self.txt_id:setString(uuid)
        self.txt_cards:setString(cardNum)
        self.txt_mymoney:setString(money / 100)
        self.txt_id2:setString(uuid)
        self.txt_cards2:setString(cardNum)

    end    
end

function UIDelegateCenter:onGiveCardResult(data)
    if data then 
        local cards = data.cardNum
        --更新基础数据
        if self.infoData then 
            self.infoData.cardNum = cards 
            self:delegateInfo(self.infoData)--
        end
    end    
end

function UIDelegateCenter:onExChangeResult(data)
    print_r(" ** onExChangeResult ")
    print_r(data)
    if data then 
        local money   = data.money
        local cardNum = data.cardNum
        if self.infoData then
             self.infoData.money   = money
             self.infoData.cardNum = cardNum
             self:delegateInfo(self.infoData)--
        end    
    end
end
function UIDelegateCenter:onGiveHistoryData(data)
    if data then 
        self.giveHistory = data.res
        self.max_page   = data.total_pages
        self.page_size  = data.page_size
        self:setPage(self.page_index) 
    end
end

function UIDelegateCenter:setPage(page_index)
    if page_index > 0 then 
        self.page_index = page_index --

        self.listview:removeAllItems()
        local max_page = self.max_page--math.ceil(#self.giveHistory / UIDelegateCenter.PAGE_NUM)
        self.txt_pageNum:setString(string.format("%d/%d" ,self.page_index , max_page))

        -- local start_index = (page_index - 1) * UIDelegateCenter.PAGE_NUM  + 1
        -- local end_index   = math.min(page_index * UIDelegateCenter.PAGE_NUM ,  #self.giveHistory)
        -- for index =  start_index, end_index do
        --     dump(" ***** index ", index)

        --     local itemdata = self.giveHistory[index]
        --     local layer = ccui.Layout:create()
        --     layer:setContentSize(cc.size(700,34))

        --     local item = self:createItem(itemdata)
        --     layer:addChild(item)
        --     self.listview:pushBackCustomItem(layer)
        -- end

        for index= 1 , #self.giveHistory do 
            dump(" ***** index ", index)

            local itemdata = self.giveHistory[index]
            local layer = ccui.Layout:create()
            layer:setContentSize(cc.size(700,34))

            local item = self:createItem(itemdata)
            layer:addChild(item)
            self.listview:pushBackCustomItem(layer)
        end    
    end    
end

function UIDelegateCenter:createItem(item_data)
    local root = display.newCSNode("layout/SellerShare/item_senddata.csb")
    local txt_id            = self:getDescendantsByName(root , "txt_id")
    local txt_givecardnum   = self:getDescendantsByName(root , "txt_givecardnum")
    local txt_otUserCardNum = self:getDescendantsByName(root , "txt_otUserCardNum")
    local txt_myCardNum     = self:getDescendantsByName(root , "txt_myCardNum")
    local txt_time          = self:getDescendantsByName(root , "txt_time")

    txt_id:setString(item_data.receiver_uuid)
    txt_givecardnum:setString(item_data.give_num)
    txt_otUserCardNum:setString(item_data.receiver_cardNum)
    txt_myCardNum:setString(item_data.my_cardNum)
    txt_time:setString(item_data.send_time)

    return root
end

function UIDelegateCenter:onSelect(num)
    self.num = num
    self.btn_base_info:setEnabled(not (num == 1))
    self.btn_give_card:setEnabled(not (num == 2))
    self.btn_gived_datas:setEnabled(not (num == 3))

    self.ctn_base_info:setVisible(num == 1)
    self.ctn_give_card:setVisible(num == 2)
    self.ctn_gived_datas:setVisible(num == 3)
end

------ 按钮 -------
function UIDelegateCenter:onBaseInfo()
    self:onSelect(1)
end

function UIDelegateCenter:onUIGiveCard()
    self:onSelect(2)
end

function UIDelegateCenter:onUIGivedDatas()
    self:onSelect(3)
end    


--基础信息
function UIDelegateCenter:onBuyCard()
    dump(" --- onBuyCard ")
    if self.infoData and self.infoData.product_delegate then 
        local buycard = require("SellerShare.UIBuyCard").new()
        buycard:showBuy(self.infoData.product_delegate)
        buycard:addTo(self)
    else
        SellerShareMgr:showToast("未获取到商品信息")
    end    
end

function UIDelegateCenter:onExChangeCard()
    dump(" --- onExChangeCard ")
    local buycard = require("SellerShare.UIBuyCard").new()
    buycard:shwoExChange(self.infoData.product_delegate)
    buycard:addTo(self)
end

--赠送editbox_id , editbox_num
function UIDelegateCenter:onGive()
    dump("-------onExChange" , self.editbox_num:getStringValue() , self.editbox_id:getStringValue())
    local value_num = self.editbox_num:getStringValue()
    local value_id  = self.editbox_id:getStringValue()
    if value_num and string.len(value_num) > 0 and value_id and string.len(value_id) > 0 then 
        local n = tonumber(value_num)
        local i = tonumber(value_id)
        if n  and i then
            if n < 1 then 
                SellerShareMgr:showToast("房卡数量需大于0")
                return 
            end

            if i < 1 then 
                SellerShareMgr:showToast("无效的玩家ID")
                return 
            end    
            --
            dump(" ---- id ",i  , "    num ",n)
            SellerShareMgr:giveCard_to_User(i, n)

        else
            SellerShareMgr:showToast("请输入数字")
        end
    else
        SellerShareMgr:showToast("内容不能为空")
    end

end

--查询
function UIDelegateCenter:onSearch() 
    local value_s = self.editbox_start:getStringValue()
    local value_e = self.editbox_end:getStringValue()
    -- if value_s and string.len(value_s) > 0 and value_e and string.len(value_e) > 0 then 
    if value_s  and value_e  then     
        local f_s = string.find(value_s, "%d%d%d%d%-%d%d%-%d%d", 1)
        local f_e = string.find(value_e, "%d%d%d%d%-%d%d%-%d%d", 1)
        dump(" ** value_s " , f_s , "  " ,value_s)
        dump(" ** value_e " , f_e , "  " ,value_e)
        if f_s and f_e then 
            self.page_index = 1
            SellerShareMgr:giveCard_to_User_history_data(self.page_index , value_s , value_e)
        else
            SellerShareMgr:showToast("请按正确格式输入时间，例如：2017-01-02")
        end    
    else
        SellerShareMgr:showToast("请输入起始时间 和 结束时间")
    end   
end

function UIDelegateCenter:onUpPage() 
    -- if self.giveHistory and #self.giveHistory > 0 then 
    --     local new_page = math.max(self.page_index -1 , 1)
    --     if new_page ~= self.page_index then 
    --         dump(" ***** new_page ",new_page)
    --         self:setPage(new_page)
    --     end
    -- end  

    if self.page_index > 1 then 
        self.page_index = self.page_index -1

        local value_s = self.editbox_start:getStringValue()
        local value_e = self.editbox_end:getStringValue()

        SellerShareMgr:giveCard_to_User_history_data(self.page_index , value_s , value_e)
    end  
end

function UIDelegateCenter:onNextPage() 
    -- if self.giveHistory and #self.giveHistory > 0 then 
    --     local new_page = math.min(self.page_index +1 , math.ceil(#self.giveHistory / UIDelegateCenter.PAGE_NUM) )
    --     if new_page ~= self.page_index then 
    --         dump(" ***** new_page ",new_page)
    --         self:setPage(new_page)
    --     end 
    -- end    
    if self.page_index < self.max_page then 
        self.page_index = self.page_index + 1

        local value_s = self.editbox_start:getStringValue()
        local value_e = self.editbox_end:getStringValue()

        SellerShareMgr:giveCard_to_User_history_data(self.page_index , value_s , value_e)
    end 
end

function UIDelegateCenter:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

return UIDelegateCenter
