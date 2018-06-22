local UISellerShare = class("UISellerShare", cc.load("mvc").ViewBase)

UISellerShare.RESOURCE_FILENAME = "layout/SellerShare/UISellerShare.csb"
UISellerShare.RESOURCE_BINDING = {
    ["btn_close"]           = {    ["varname"] = "btn_close"            ,  ["events"] = { {event = "click" ,  method ="onBack"          } }     },
    ["btn_getmoney"]        = {    ["varname"] = "btn_getmoney"         ,  ["events"] = { {event = "click" ,  method ="onGetMoney"      } }     },
    ["btn_getreward"]       = {    ["varname"] = "btn_getreward"        ,  ["events"] = { {event = "click" ,  method ="onReward"        } }     },
    ["btn_getsomething"]    = {    ["varname"] = "btn_getsomething"     ,  ["events"] = { {event = "click" ,  method ="onGetSomething"  } }     },
    ["btn_sure"]            = {    ["varname"] = "btn_sure"             ,  ["events"] = { {event = "click" ,  method ="onSure"          } }     },
    ["btn_wechat"]          = {    ["varname"] = "btn_wechat"           ,  ["events"] = { {event = "click" ,  method ="onWechar"        } }     },
    ["btn_face2face"]       = {    ["varname"] = "btn_face2face"        ,  ["events"] = { {event = "click" ,  method ="onFace2Face"           } }     },
    ["btn_wecaht_timeline"] = {    ["varname"] = "btn_wecaht_timeline"  ,  ["events"] = { {event = "click" ,  method ="onWecharTimeLine"            } }     },
    ["btn_to2code"]         = {    ["varname"] = "btn_to2code"          ,  ["events"] = { {event = "click" ,  method ="on2Code"         } }     },
    ["btn_checkget"]        = {    ["varname"] = "btn_checkget"         ,  ["events"] = { {event = "click" ,  method ="onCheckGet"      } }     },
    ["btn_friends"]         = {    ["varname"] = "btn_friends"          ,  ["events"] = { {event = "click" ,  method ="onFriends"       } }     },

    ["txt_invitecode"]          = {    ["varname"] = "txt_invitecode"       },
    ["txt_friendcount"]         = {    ["varname"] = "txt_friendcount"      },
    ["txt_money"]               = {    ["varname"] = "txt_money"            },
    ["editbox"]                 = {    ["varname"] = "editbox"              },
    ["img_head"]                = {    ["varname"] = "img_head"             }

}

function UISellerShare:onCreate()
    dump("CREATE")
    self.playerinfo = nil
    self.AppId      = nil
    self.info_data  = nil
end

function UISellerShare:onEnter()
    dump("ENTER")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:initData(data) end,"onUser_acquire_account")
    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:bindSupperior(data) end,"onUser_bind_superior_account")

    eventMgr:registerEventListener("onUser_acquire_account"             ,handler(self,self.initData     ),"UISellerShare")
    eventMgr:registerEventListener("onUser_bind_superior_account"       ,handler(self,self.bindSupperior     ),"UISellerShare")

    -- SellerShareMgr:User_acquire_account(SellerShareMgr._appId)
end

function UISellerShare:onExit()
    dump("EXIT")
    -- CCXNotifyCenter:unListenByObj(self)
    eventMgr:removeEventListenerForTarget("UISellerShare")    
end

--设置数据
function UISellerShare:initData(data)
    print_r(data)
    if data then 
        self.info_data = data

        self.txt_invitecode:setString(self.info_data.inviteCode) --邀请码
        self.txt_friendcount:setString(self.info_data.numOfJunior)
        self.txt_money:setString(self.info_data.wallet)
    end    
end

--绑定上级用户
function UISellerShare:bindSupperior(data)
    dump(" _ 绑定上级用户 ")
    print_r(data)
    if data then 
        if data.success then 
            if data.hasbind then
                self.info_data.superior_nickname = data.superior_nickname
                self.info_data.superior_iconUrl  = data.superior_iconUrl
                self.info_data.superior_id       = data.superior_id
                
                SellerShareMgr:showToast("绑定邀请码成功")
            else
                SellerShareMgr:showToast("您已使用过此邀请码!")
            end
        else
            SellerShareMgr:showToast("该邀请码无效，请输入正确的邀请码")
        end    
    end    
    print_r(self.info_data)
end    

function UISellerShare:initPlayerInfo(info)
    print_r(info)
    self.playerinfo = info
    if info then 
        dump(" //// 设置头像")
        local headimg = info.imgheadPath
        self:setHeadImg(headimg)
    end    
end

function UISellerShare:setAppId(appid)
    self.AppId = appid

    --请求信息
    if self.AppId then
        SellerShareMgr:User_acquire_account(self.AppId)
    end  
end

--设置头像
function UISellerShare:setHeadImg(headimg)
    cc.Director:getInstance():getTextureCache():reloadTexture(path); -- 重新加载纹理
    local sp = cc.Sprite:create(headimg)
    if sp then 
        local size   = self.img_head:getContentSize()
        local spsize = sp:getContentSize()

        sp:setScaleX(size.width / spsize.width)
        sp:setScaleY(size.height / spsize.height)
        sp:setAnchorPoint(cc.p(0,0))
        sp:addTo(self.img_head)    
    end    
end

------ 按钮 -------

function UISellerShare:webviewAction()
    local size       = cc.Director:getInstance():getVisibleSize()
    local action     = cc.MoveTo:create(0.3 , cc.p(0,0))
    return action
end
function UISellerShare:onBack()
    dump("-------onBack")
    self:removeFromParent()
end

function UISellerShare:onGetMoney()
    dump("-------onGetMoney")
    local web = require("SellerShare.UIWebView").new()
    web:initData(self.info_data.toCashUrl)
    web:setPosition(cc.p(0,cc.Director:getInstance():getVisibleSize().height))
    web:runAction(self:webviewAction())
    web:addTo(self)
end

function UISellerShare:onReward()
    dump("-------onReward")
    local web = require("SellerShare.UIWebView").new()
    web:initData("http://cn.bing.com")
    web:setPosition(cc.p(0,cc.Director:getInstance():getVisibleSize().height))
    web:runAction(self:webviewAction())
    web:addTo(self)
end

function UISellerShare:onGetSomething()
    dump("-------onGetSomething", self.info_data.convertUrl)
    local web = require("SellerShare.UIWebView").new()
    web:initData(self.info_data.convertUrl)
    web:setPosition(cc.p(0,cc.Director:getInstance():getVisibleSize().height))
    web:runAction(self:webviewAction())
    web:addTo(self)
end

function UISellerShare:onCheckGet()
    dump("-------onCheckGet")
    local web = require("SellerShare.UIWebView").new()
    web:initData(self.info_data.checkInComeUrl)
    web:setPosition(cc.p(0,cc.Director:getInstance():getVisibleSize().height))
    web:runAction(self:webviewAction())
    web:addTo(self)
end

function UISellerShare:onSure()
    dump("-------onSure" , self.editbox:getStringValue())
    if self.editbox:getStringValue() and string.len(self.editbox:getStringValue()) > 0 then
        SellerShareMgr:User_bind_superior_account(self.editbox:getStringValue())
    end    
end

function UISellerShare:onFace2Face()
    dump("-------onAdd")
    local ui2code = require("SellerShare.UI2Code").new()
    ui2code:openImg("ui/image/sellershare/SHARE_2CODE.png")
    ui2code:addTo(self)
end

function UISellerShare:onWechar()
    dump("-------onWechar")
    local url = gameConfMgr:getInfo("shareUrl")
    if string.find(url,"http",0,true) == nil then 
        url = "http://" .. url
    end
    
    local res = {"一把趣牌，好运自来！","邀请码：" .. self.info_data.inviteCode .." \n " .. self.playerinfo.name .. "在趣牌湖南麻将等你来玩！", url , 0}
    SDKMgr:sdkUrlShare("一把趣牌，好运自来！" , "邀请码：" .. self.info_data.inviteCode .." \n " .. self.playerinfo.name .. "在趣牌湖南麻将等你来玩！" , url , 0 , nil) 


end

function UISellerShare:onFriends()
    dump("-------onFriends")
    local info = {}
    info.superior_nickname = self.info_data.superior_nickname
    info.superior_iconUrl = self.info_data.superior_iconUrl
    info.superior_id = self.info_data.superior_id 

    local fui = require("SellerShare.UIShareFriends").new()
    fui:initPlayerInfo(info)
    fui:addTo(self) 
end

function UISellerShare:on2Code()
    dump("-------on2Code")
    if self.info_data == nil then return end
    local ui2code = require("SellerShare.UI2Code").new()
    ui2code:setURL(self.info_data.qrCodeUrl)
    ui2code:addTo(self)
end

function UISellerShare:onWecharTimeLine()
    dump("-------onWechar line")
    local url = gameConfMgr:getInfo("shareUrl")
    if string.find(url,"http",0,true) == nil then 
        url = "http://" .. url
    end
    
    local res = {"一把趣牌，好运自来！","邀请码：" .. self.info_data.inviteCode .." \n " .. self.playerinfo.name .. "在趣牌湖南麻将等你来玩！", url , 1}
    SDKMgr:sdkUrlShare("一把趣牌，好运自来！","邀请码："  .. self.info_data.inviteCode .." \n " .. self.playerinfo.name .. "在趣牌湖南麻将等你来玩！" , url ,  1 , nil) 
end


return UISellerShare