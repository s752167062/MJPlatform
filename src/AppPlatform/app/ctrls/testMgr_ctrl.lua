--
-- Author: zhhf
-- Date: 2017-04-06 20:50:57
--
--------------------------------------
--[[
    调试代码
    TEST_MODEL@调试等级
    TEST_MODEL = 0 关闭所有调试功能
    TEST_MODEL = 1 开放程序出错弹框
    TEST_MODEL = 2 开放登陆服务器选着 开放用户ID输入框
    TEST_MODEL = 3 开放ESC唤出代码调试框 左Ctrl执行测试函数runTestCode中的代码
]]

local TEST_MODEL = 0
local SHOW_SERVERBTN = true
local testMgr = class("testMgr")
local ui = {}
local ui_index = {
	error_code = 1,
	sever_bg = 2,
	sever_label = 3,
	gm_edit = 4,
	username_edit = 5,
    clubid_edit = 6,
    userAccountID_edit = 7,
}
local s9bg = "AppPlatform/ui/image/test/s9bg.png"
local input_bg = "AppPlatform/ui/image/test/input_bg.png"
local btn_image = "AppPlatform/ui/image/test/btn_image.png"
local ttf_path = "AppPlatform/ui/font/LexusJianHei.TTF"

local color = {
	common = cc.c3b(139, 66, 20),
	gray = cc.c3b(127, 127, 127),
	white = cc.c3b(255,255,255)
}

--[[
	服务器配置表
	可以通过修改sever_index修改默认服务器
]]
local sever_index = 1
local sever_conf = {
    -- {name = "内部测试服",url = "http://120.76.220.130:18888/Login_youruiTest", wx = false},
    -- {name = "微信测试服",url =  "http://120.76.220.130:18888/Login", wx = true},
    {name = "吴达任",url     = "http://192.168.1.99:28888/Login_youruiTest", wx = false},
    {name = "测试服",url     = "http://120.78.255.24:8888/Login_youruiTest", wx = false},
    {name = "争强",url     = "http://192.168.1.251:8888/Login_youruiTest", wx = false},
    -- {name = "付谦",url       =  "http://192.168.1.68:8888/Login_youruiTest", wx = false},
    {name = "陈志望",url     =  "http://192.168.1.177:8889/Login_youruiTest", wx = false},
    -- {name = "李庆东",url     =  "http://192.168.1.230:8888/Login_youruiTest", wx = false},
    -- {name = "林培基",url     =  "http://192.168.1.66:8888/Login_youruiTest", wx = false},
    -- {name = "吴达任微信服",url =  "http://192.168.1.99:8888/Login", wx = true},
    -- {name = "林争强微信服",url =  "http://192.168.1.251:18888/Login", wx = true},
    -- {name = "马海仕",url     = "http://192.168.2.138:8888/Login_youruiTest", wx = false},
    -- {name = "廖坚聪",url     = "http://192.168.1.144:8888/Login_youruiTest", wx = false},
    -- {name = "军海81",url     = "http://ngrok.aikola.cn:10081/Login_youruiTest", wx = false},
    -- {name = "军海86",url     = "http://ngrok.aikola.cn:10086/Login_youruiTest", wx = false},
}
--错误信息
local Error_msg = ""
--初始化工作
function testMgr:ctor()
	--执行需要重写的方法
	testMgr:doOverwrite()
end

function testMgr:setSeverSelect()
    if sever_conf[sever_index].wx == true then
        gameConfMgr:setInfo("isWX", true)
        local loginURL = gameConfMgr:getInfo("loginURL")
        loginURL[GAME_NET_LINE.LINE_LIANTONG] = sever_conf[sever_index].url
        loginURL[GAME_NET_LINE.LINE_DIANXIN]  = sever_conf[sever_index].url
        loginURL[GAME_NET_LINE.LINE_YIDONG]   = sever_conf[sever_index].url
    else
        gameConfMgr:setInfo("isWX",false)
        gameConfMgr:setInfo("loginURL",{[0] = sever_conf[sever_index].url})
    end
end

--[[
	执行测试代码
]]
function testMgr:runTestCode()
	print("this is test code!")
end

--[[
	游戏中发生代码错误时 在公告中弹出
]]
function testMgr:ShowCodeError(msg)
	Error_msg = "#################CODE ERROR####################\n"..msg.."\n"
    local target = cc.Application:getInstance():getTargetPlatform()  
    if target == cc.PLATFORM_OS_ANDROID or target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
        local errorUI = display.getRunningScene():getChildByTag(404)
        if errorUI then
            errorUI.setText(Error_msg)
        else
            local ui = testMgr:createView()
            if ui then
                display.getRunningScene():addChild(ui,999,404)
                ui.setText(Error_msg)
            end
        end
    end
end

function testMgr:createView()
	local view = display.newSprite(s9bg,display.cx,display.cy,{scale9 = true})
	view:setContentSize(cc.size(900,500))

	view.ScrollView = ccui.ScrollView:create()
	view.ScrollView:setTouchEnabled(true)
	view.ScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	-- view.ScrollView:setClippingToBounds(true)
	view.ScrollView:setAnchorPoint(cc.p(0.5,0.5))
	view.ScrollView:setContentSize(860,440)
	view.ScrollView:setInnerContainerSize(cc.size(860,440))
	view.ScrollView:setPosition(460,250)
	view:addChild(view.ScrollView)


	view.text = cc.Label:createWithTTF("",ttf_path,23)
	view.text:setColor(cc.c3b(147,65,12))
    view.text:setAnchorPoint(cc.p(0,1))
    view.ScrollView:addChild(view.text,100)
	view.text:setWidth(880)

	view.scrollView_size = view.ScrollView:getContentSize()


	view.close_btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
	view.close_btn:setScale9Enabled(true)
	view.close_btn:setContentSize(cc.size(60,60))
	view.close_btn:setTitleText("X")
	view.close_btn:setTitleFontSize(28)
	view.close_btn:setTitleColor(color.common)
	view.close_btn:onClick(function()
		platformMgr:copy_To_Clipboard(view.text:getString())
		view:removeFromParent()
		end)
	view:addChild(view.close_btn)

	view.setText = function(msg)
		view.text:setString(msg)
	    local size = view.text:getContentSize()
	    local scrollView_size = view.ScrollView:getContentSize()
	    if size.height > view.scrollView_size.height then
	        view.ScrollView:setInnerContainerSize(cc.size(size.width,size.height))
	        view.text:setPosition(cc.p(0,size.height))
	    else
	    	view.ScrollView:setInnerContainerSize(cc.size(size.width,view.scrollView_size.height))
	        view.text:setPosition(cc.p(0,view.scrollView_size.height))
	    end
	end
	return view
end

function testMgr:doOverwrite()
	-- function audioMgr:playMusic()
	-- 	dump("audioMgr:playMusic Overwrite By testMgr","TEST_WARRING")
	-- end
end
--##############################全局函数重写##################################
if TEST_MODEL > 0 then
	__G__TRACKBACK__ = function(msg)
	    local msg = debug.traceback(msg, 3)
	    	print(msg)
	        testMgr:ShowCodeError(os.date("%c",os.time()).."\n"
            .."LUA ERROR: " .. tostring(msg) .. "\n"
            -- ..debug.traceback()
            )
	    return msg
	end
end

if TEST_MODEL > 2 then
	class = function(classname, ...)
	    local cls = {__cname = classname}

	    local supers = {...}
	    for _, super in ipairs(supers) do
	        local superType = type(super)
	        assert(superType == "nil" or superType == "table" or superType == "function",
	            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
	                classname, superType))

	        if superType == "function" then
	            assert(cls.__create == nil,
	                string.format("class() - create class \"%s\" with more than one creating function",
	                    classname));
	            -- if super is function, set it to __create
	            cls.__create = super
	        elseif superType == "table" then
	            if super[".isclass"] then
	                -- super is native class
	                assert(cls.__create == nil,
	                    string.format("class() - create class \"%s\" with more than one creating function or native class",
	                        classname));
	                cls.__create = function() return super:create() end
	            else
	                -- super is pure lua class
	                cls.__supers = cls.__supers or {}
	                cls.__supers[#cls.__supers + 1] = super
	                if not cls.super then
	                    -- set first super pure lua class as class.super
	                    cls.super = super
	                end
	            end
	        else
	            error(string.format("class() - create class \"%s\" with invalid super type",
	                        classname), 0)
	        end
	    end

	    cls.__index = cls
	    if not cls.__supers or #cls.__supers == 1 then
	        setmetatable(cls, {__index = cls.super})
	    else
	        setmetatable(cls, {__index = function(_, key)
	            local supers = cls.__supers
	            for i = 1, #supers do
	                local super = supers[i]
	                if super[key] then return super[key] end
	            end
	        end})
	    end

	    if not cls.ctor then
	        -- add default constructor
	        cls.ctor = function() end
	    end
	    cls.new = function(...)
	        local instance
	        if cls.__create then
	            instance = cls.__create(...)
	        else
	            instance = {}
	        end
	        setmetatableindex(instance, cls)
	        instance.class = cls
	        instance:ctor(...)
	        --注册全局变量
	        cc.exports[classname.."_G"] = instance
	        -- print("/////=========>>>>>>create global class "..classname.."_G")
	        return instance
	    end
	    cls.create = function(_, ...)
	        return cls.new(...)
	    end

	    return cls
	end
end
--##############################全局函数重写##################################
--[[
	显示服务器选着按钮
]]
function testMgr:ShowSeverButton(ui_root)
	local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
	--btn:setColor(display.COLOR_GREEN)
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setScale9Enabled(true)
	btn:setContentSize(cc.size(200,60))
	btn:setTitleText("服务器选择")
	btn:setTitleFontSize(28)
	btn:setTitleColor(color.common)
	--btn:setLocalZOrder(10)
	ui_root:addChild(btn,100)
	btn:setPosition(cc.p(display.left+185,display.bottom+570))
	btn:addClickEventListener(function()
		testMgr:onClickSeverBtn(ui_root)
		end)
	testMgr:showSeverName(ui_root)

    sever_index = 1
    testMgr:showSeverName()
    self:setSeverSelect()
end

function testMgr:showSeverName(root)
	if ui[ui_index.sever_label] then
		ui[ui_index.sever_label]:setString("当前服务器："..sever_conf[sever_index].name)
	else
		local label = cc.Label:createWithTTF("",ttf_path,28)
	    label:setColor(display.COLOR_BLUE)
	    label:setAnchorPoint(cc.p(0,0.5))
	    label:setPosition(cc.p(display.left+285,display.bottom+570))
	    root:addChild(label)
	    ui[ui_index.sever_label] = label
	    label:setString("当前服务器："..sever_conf[sever_index].name)
	end
end

function testMgr:onClickSeverBtn(ui_root)
	--local ui_root = display.getRunningScene()
	if ui[ui_index.sever_bg] then 
		ui[ui_index.sever_bg]:removeFromParent()
		ui[ui_index.sever_bg] = nil
		return
	end
	local layer = ccui.Layout:create()
	layer:setContentSize(cc.size(800,280))
	layer:setAnchorPoint(cc.p(0.5,0.5))
	layer:setSwallowTouches(true)
	layer:setTouchEnabled(true)
	layer:setBackGroundColor(display.COLOR_BLACK)
	layer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	layer:setBackGroundColorOpacity(100)
	layer:setPosition(cc.p(display.cx - 80,display.cy+70))
	ui_root:addChild(layer)
	-- layer:setContentSize(cc.size(800,600))

	testMgr:CreateSeverSelectBtn(layer)
	ui[ui_index.sever_bg] = layer
end

function testMgr:CreateSeverSelectBtn(root)
	local pos_x,pos_y = 150,250
	local offset_x,offset_y = 250,55
	for i = 1,#sever_conf do
		local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
		btn:setScale9Enabled(true)
		btn:setContentSize(cc.size(200,50))
		btn:setTitleColor(color.common)
		root:addChild(btn)
		btn:setTitleText(sever_conf[i].name)
		btn:setTitleFontSize(28)
		local my_x,my_y = 0,0

		btn:setPosition(cc.p(pos_x,pos_y))
		local function onClick()
			sever_index = i
			ui[ui_index.sever_bg]:removeFromParent()
			ui[ui_index.sever_bg] = nil
			testMgr:showSeverName()
			self:setSeverSelect()
		end
		btn:addClickEventListener(function()
			onClick()
			end)

		if i%3 == 0  then
	    	pos_x = 150
	    	pos_y = pos_y - offset_y
	    else
	    	pos_x = pos_x + offset_x
	    end
	end
end

function testMgr:addGMButton(ui_root)
	local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
	--btn:setColor(display.COLOR_GREEN)
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setScale9Enabled(true)
	btn:setContentSize(cc.size(120,80))
	btn:setTitleText("GM")
	btn:setTitleFontSize(28)
	--btn:setLocalZOrder(10)
	ui_root:addChild(btn,9999)
	btn:setPosition(cc.p(display.right-60,display.bottom+400))
	local prePos = cc.p(0,0)
	local startPos = nil

	btn:addTouchEventListener(function(touch,event)

		local pos = touch:getTouchMovePosition()
		if event == 0 then
			startPos = pos
		end

		if cc.pGetDistance(pos,prePos) > 10 then
			prePos = pos
			if pos.x >30 and pos.x < display.right - 30 and pos.y > 30 and pos.y < display.top - 30 then
				if event == 1 then --拖动
					touch:setPosition(pos)
				end
			end
		else
			if event == 2 and cc.pGetDistance(pos,startPos) < 10 then
				testMgr:addGMEditBox(ui_root)
			end
		end
	end)
end

function testMgr:addGMEditBox(layer)
	if ui[ui_index.gm_edit] then 
		ui[ui_index.gm_edit]:removeFromParent()
		ui[ui_index.gm_edit] = nil
		return
	end
	local edit = ccui.EditBox:create(cc.size(800,400),input_bg)
    layer:addChild(edit,9999)
    ui[ui_index.gm_edit] = edit
    edit:setPosition(cc.p(display.cx,display.cy))
    edit:setFontSize(28)
    edit:setFontColor(display.COLOR_GREEN)
    edit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    edit:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    edit:setPlaceHolder("局部变量可以通过classname+'_G'的形式访问到，例如CUIGame_G:onSet()\n在手机中打印数据使用方法testMgr:ShowCodeError(msg)")
    edit:setPlaceholderFontSize(28)
    local editBoxTextEventHandle = function(event,edit)
		if event == "began" then
         
        elseif event == "ended" then
            
        elseif event == "return" then
           local str = edit:getText()
           	print(str)
           	self:dostring(str)
            ui[ui_index.gm_edit]:removeFromParent()
			ui[ui_index.gm_edit] = nil
        elseif event == "changed" then

        end
	end
    edit:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

function testMgr:username_editbox(layer)
	print("add test ui","test_username_editbox")
	local edit = ccui.EditBox:create(cc.size(320,45),input_bg)
    layer:addChild(edit)
    ui[ui_index.username_edit] = edit
    edit:setPosition(cc.p(910,display.cy - 90))
    edit:setFontSize(32)
    edit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    edit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    edit:setMaxLength(20)
    edit:setPlaceHolder("输入用户名字")
    edit:setPlaceholderFontSize(32)

    local editBoxTextEventHandle = function(event,edit)
    	if event == "changed" then
    		gameConfMgr:setInfo("account",edit:getText())
    	end
	end
    edit:registerScriptEditBoxHandler(editBoxTextEventHandle)

    self:userAccountID_editbox(layer)
end

function testMgr:userAccountID_editbox(layer)
    print("add test ui","userAccountID_editbox")
    local edit = ccui.EditBox:create(cc.size(320,45),input_bg)
    layer:addChild(edit)
    ui[ui_index.userAccountID_edit] = edit
    edit:setPosition(cc.p(910,display.cy - 145))
    edit:setFontSize(32)
    edit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    edit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    edit:setMaxLength(20)
    edit:setPlaceHolder("微信的账号ID(技术用)")
    edit:setPlaceholderFontSize(32)

    local editBoxTextEventHandle = function(event,edit)
        if event == "changed" then
            gameConfMgr:setInfo("tmpUserAccountID",edit:getText())
        end
    end
    edit:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

--[[
	获得注册UI控件
]]
function testMgr:get_ui(index)
	if ui_index[index] and ui[ui_index[index]] then
		return ui[ui_index[index]]
	end
end

--[[
	用户名输入框
]]
function testMgr:get_username_text()
	local edit = ui[ui_index.username_edit]
	if edit then
		local text = edit:getText()
		text = string.trim(text)
		if string.len(text) > 5 then
			print("username:",text)
			return text
		end
	end
end

function testMgr:get_username_text()
    local edit = ui[ui_index.userAccountID_edit]
    if edit then
        local text = edit:getText()
        text = string.trim(text)
        if string.len(text) > 5 then
            print("username:",text)
            return text
        end
    end
end

--[[
	清理测试UI
]]
function testMgr:clean_all()
	for k,v in pairs(ui) do
		if v then
			print("remove test ui",k)
			v:removeFromParent()
		end
	end
	ui = {}
end

--[[
	按键监控
]]
function testMgr:setKeyBackListener(view)
    local function onKeyReleased(keyCode, event)
        local label = event:getCurrentTarget()
        --按下返回键
        if keyCode == cc.KeyCode.KEY_BACK then
        	if TEST_MODEL > 2 then 
            	self:addGMEditBox(view)
        	end
        end
        --按下左Ctrl
        if keyCode == cc.KeyCode.KEY_LEFT_CTRL then
        	if TEST_MODEL > 2 then 
            	self:runTestCode()
        	end
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = view:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,view)
end

function testMgr:dostring(s)
    local f, err = loadstring(s)
    if f then
        f()
    else
        print(err)
    end
end

function testMgr:addTest()
    -- if SHOW_SERVERBTN then
    	print("///////==============>>>>>>>addTest")
    	self:clean_all()
    	local scene = viewMgr:getScene()
    	local gameState = gameState:getState()
    	if scene  then
    		self:setKeyBackListener(scene)
    		if gameState == GAMESTATE.STATE_LOGIN then
    			self:ShowSeverButton(scene)
                self:username_editbox(scene)
                self:ddshareButton(scene)
                self:videoButton(scene)
                self:addMiniShareBtn(scene)
                self:addCleanTempFileBtn(scene)
            elseif gameState == GAMESTATE.STATE_HALL then
                --self:addQuickJoinClubBtn(scene)
    		end
    	end
    -- end
end

function testMgr:addQuickJoinClubBtn(ui_root)
    -- body
    local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
    --btn:setColor(display.COLOR_GREEN)
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(120,80))
    btn:setTitleText("GM")
    btn:setTitleFontSize(28)
    --btn:setLocalZOrder(10)
    ui_root:addChild(btn,9999)
    btn:setPosition(cc.p(display.right-60,display.bottom+400))
    local prePos = cc.p(0,0)
    local startPos = nil

    btn:addTouchEventListener(function(touch,event)

        local pos = touch:getTouchMovePosition()
        if event == 0 then
            startPos = pos
        end

        if cc.pGetDistance(pos,prePos) > 10 then
            prePos = pos
            if pos.x >30 and pos.x < display.right - 30 and pos.y > 30 and pos.y < display.top - 30 then
                if event == 1 then --拖动
                    touch:setPosition(pos)
                end
            end
        else
            if event == 2 and cc.pGetDistance(pos,startPos) < 10 then
                testMgr:onClickClubBtn(ui_root)
            end
        end
    end)
end

function testMgr:onClickClubBtn(ui_root)
    --local ui_root = display.getRunningScene()
    if ui[ui_index.clubid_edit] then 
        ui[ui_index.clubid_edit]:removeFromParent()
        ui[ui_index.clubid_edit] = nil
        return
    end
    testMgr:clubid_editbox(ui_root)
    ui[ui_index.sever_bg] = layer
end

function testMgr:clubid_editbox(layer)

    local panel = ccui.Layout:create()
    panel:setContentSize(cc.size(400,280))
    panel:setAnchorPoint(cc.p(0.5,0.5))
    panel:setSwallowTouches(true)
    panel:setTouchEnabled(true)
    panel:setBackGroundColor(display.COLOR_BLACK)
    panel:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    panel:setBackGroundColorOpacity(100)
    panel:setPosition(cc.p(display.cx,display.cy))
    layer:addChild(panel)
    ui[ui_index.clubid_edit] = panel


    print("add test ui","test_username_editbox")
    local edit = ccui.EditBox:create(cc.size(320,45),input_bg)
    panel:addChild(edit)
    
    edit:setText(gameConfMgr:getInfo("testClubID"))
    edit:setPosition(cc.p(200,140))
    edit:setFontSize(32)
    edit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    edit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    edit:setMaxLength(20)
    edit:setPlaceHolder("click to edit username")
    edit:setPlaceholderFontSize(32)
    local editBoxTextEventHandle = function(event,edit)
        if event == "changed" then
            gameConfMgr:setInfo("testClubID",edit:getText())
            gameConfMgr:writeOne("testClubID")
        end
    end
    edit:registerScriptEditBoxHandler(editBoxTextEventHandle)


    local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
    --btn:setColor(display.COLOR_GREEN)
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(200,60))
    btn:setTitleText("加入俱乐部")
    btn:setTitleFontSize(28)
    --btn:setTitleColor(color.common)
    --btn:setLocalZOrder(10)
    panel:addChild(btn)
    btn:setPosition(cc.p(200,80))
    btn:addClickEventListener(function()
       hallHandler:gotoJoinClub(gameConfMgr:getInfo("testClubID"))
        end)
end

function testMgr:ddshareButton(ui_root)
	local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
	--btn:setColor(display.COLOR_GREEN)
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setScale9Enabled(true)
	btn:setContentSize(cc.size(200,60))
	btn:setTitleText("钉钉Url分享")
	btn:setTitleFontSize(28)
	btn:setTitleColor(color.common)
	--btn:setLocalZOrder(10)
	ui_root:addChild(btn,100)
	btn:setPosition(cc.p(display.left+800,display.bottom+570))
	btn:addClickEventListener(function()
			-- if SDKMgr:ddClientExits() == true and SDKMgr:ddApiSupport() == true then 
   --              SDKMgr:ddsdkUrlShare("2222" , "qqqqqqqqq" , "www.jianshu.com", function( ... )
   --                  release_print("---- call dd sdkurl share" , ...)
   --              end)
   --          else
   --              platformMgr:open_APP_WebView("https://tms.dingtalk.com/markets/dingtalk/download?spm=a3140.8736650.2231602.9.75185c8ciA9Mkk&source=2202&lwfrom=2017120202092064209309201")
   --          end 
   				platformMgr:stop_audio() 
		end)
	testMgr:showSeverName(ui_root)


	local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
	--btn:setColor(display.COLOR_GREEN)
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setScale9Enabled(true)
	btn:setContentSize(cc.size(200,60))
	btn:setTitleText("钉钉图片分享")
	btn:setTitleFontSize(28)
	btn:setTitleColor(color.common)
	--btn:setLocalZOrder(10)
	ui_root:addChild(btn,100)
	btn:setPosition(cc.p(display.left+1000,display.bottom+570))
	btn:addClickEventListener(function()
			if SDKMgr:ddClientExits() == true and SDKMgr:ddApiSupport() == true then 
                comFunMgr:shareScreenShot("dddddtest.png" , SHARE_PLATFORM_TYPE.DD)  
            else
                platformMgr:open_APP_WebView("https://tms.dingtalk.com/markets/dingtalk/download?spm=a3140.8736650.2231602.9.75185c8ciA9Mkk&source=2202&lwfrom=2017120202092064209309201")
            end 
		end)
	testMgr:showSeverName(ui_root)
end

function testMgr:videoButton(ui_root)
	local uuid = 654123
	local other= 123654
	if gameConfMgr:getInfo("platform") == 1 then
		local temp = other
		other = uuid
		uuid  = temp
	end	
	local data = { "加入654321"  }--, "离开654321" , "开启音频" , "关闭音频" , "将自己静音" , "静音所有" , "静音"..other
	for k,v in pairs(data) do
		local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
	    btn:setEnabled(true)
	    btn:setTouchEnabled(true)
	    btn:setScale9Enabled(true)
		btn:setContentSize(cc.size(200,60))
		btn:setTitleText(v)
		btn:setTitleFontSize(28)
		btn:setTitleColor(color.common)
		--btn:setLocalZOrder(10)
		ui_root:addChild(btn,100)
		btn:setPosition(cc.p(display.left+800,display.bottom+570 -k*65))
		btn:addClickEventListener(function()
				if k ==1 then 
					cpp_joinChannel("654321",uuid,"111122233344!@")
				elseif k ==2 then
					cpp_leaveChannel()
				elseif k ==3 then 
					cpp_enableAudio()
				elseif k ==4 then 
					cpp_disableAudio()
				elseif k ==5 then 
					cpp_muteLocalAudioStream(true)
				elseif k ==6 then 
					cpp_muteAllRemoteAudioStreams(true)
				elseif k ==7 then 
					cpp_muteRemoteAudioStream(other,true)
				end	
			end)
		testMgr:showSeverName(ui_root)
	end
	if cpp_setSdkHandler then 
		cpp_setSdkHandler(200, 200 , function(...)
			release_print(" >>>>>>>>>>>>> " ,...)
		end)
		timerMgr:registerTask("testargore",timerMgr.TYPE_CALL_RE,function() cpp_poll() end,0.1)
	end	
end

function testMgr:addMiniShareBtn(ui_root)
	local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
    --btn:setColor(display.COLOR_GREEN)
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(120,50))
    btn:setTitleText("小程序分享")
    btn:setTitleFontSize(28)
    btn:setTitleColor(cc.c3b(255,0,0))
    ui_root:addChild(btn,9999)
    btn:setPosition(cc.p(display.right-100,display.bottom+440))
    btn:addClickEventListener(function()
        local data = {}
	    data.webUrl = "www.douban.com"    --下载地址
	    data.path = "pages/index/index"   --小程序的页面地址
	    data.parament = "?msg={\"roominfo\":\"湖南麻将默认玩法—辣椒玩法\",\"roomid\":\"654321\",\"roomtime\":\"2018-01-01 12:00:00\"}"
	    data.title = "湖南麻将"
	    data.desc  = "默认玩法—辣椒玩法"
	    data.image = cc.FileUtils:getInstance():fullPathForFilename("ui/image/chat/beijingluyin.png") --需要全路径地址
	    data.mergeData = {} --需要绘制到image的图片or文字 
	    data.mergeData[1] = {type = IMAGE_MERGE_TYPE.IMAGE , data = cc.FileUtils:getInstance():fullPathForFilename("ui/image/chat/btn_yeqian_yuyin1.png") , p_x = 20 , p_y = 20 , size_w = 50 , size_h = 50 , font_size = 30 , color_code = "#ff0000"}
	    data.mergeData[2] = {type = IMAGE_MERGE_TYPE.TXT   , data = "超级玩法" , p_x = 20 , p_y = 40 , size_w = 50 , size_h = 50 , font_size = 30 , color_code = "#ff0000"}
	    SDKMgr:sdkShareMiniProject(data,nil)
    end)

    SDKMgr:setWXLaunchCallBack(function( ... )
    	cclog(" >>>> 小程序分享回调 " , ...)
    end)
end

function testMgr:addCleanTempFileBtn(ui_root)
    local btn = ccui.Button:create(btn_image,btn_image,btn_image,0)
    --btn:setColor(display.COLOR_GREEN)
    btn:setEnabled(true)
    btn:setTouchEnabled(true)
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(120,50))
    btn:setTitleText("清理缓存")
    btn:setTitleFontSize(28)
    btn:setTitleColor(cc.c3b(255,0,0))
    ui_root:addChild(btn,9999)
    btn:setPosition(cc.p(display.right-100,display.bottom+500))
    btn:addClickEventListener(function()
        --self:removeUpdateFile()
        gameConfMgr:deleteValueForKey("lastLoginUserID")
        msgMgr:showToast("清除成功")
    end)
end

function testMgr:removeUpdateFile()
    local path = cc.FileUtils:getInstance():getWritablePath() .. "UDInfo.json"
    if cc.FileUtils:getInstance():isFileExist(path) then
        if cc.FileUtils:getInstance():removeFile(path) then
            print("UDInfo.json! success!")
        else
            print("UDInfo.json  fail!")
        end
    end

    local path = cc.FileUtils:getInstance():getWritablePath() .. "update/"
    print("storage_path = ",path)
    if cc.FileUtils:getInstance():isDirectoryExist(path) then
        if cc.FileUtils:getInstance():removeDirectory(path) then
            print("delete update success!")
        else
            print("delete update fail!")
        end
    end
end

return testMgr






