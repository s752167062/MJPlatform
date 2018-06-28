

local UI_ClubXiugaijieshao = class("UI_ClubXiugaijieshao", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubXiugaijieshao:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubXiugaijieshao.csb")
    self.root:addTo(self)

	UI_ClubXiugaijieshao.super.ctor(self)
	_w = self._childW
  
    self.callBack = data.callBack
    self.txt = data.txt

    self.inputLimit = 140

    self:initUI()
    self:setMainUI()
end

function UI_ClubXiugaijieshao:initUI()
	-- body
    self.txt_content = _w["txt_content"]
    self.txt_curNum = _w["txt_curNum"]

    self.txt_content:setString(self.txt)
    local content = self.txt_content:getString()
    local count = self:utf8len(content)
    self.txt_curNum:setString(count.."/"..self.inputLimit)

    self.txt_content:addEventListenerTextField(
        function(_sender, _type)
           if _type == 2 or _type == 3 then   --输入字符状态/删除状态
                local content = self.txt_content:getString()
                local count = self:utf8len(content)
                if count <= self.inputLimit then
                    self.txt_curNum:setString(count.."/"..self.inputLimit)
                    -- self.txt_curNum:setTextColor(cc.c3b(139, 105, 20))
                else
                    -- self.txt_curNum:setString(count.."/"..self.inputLimit.."(超过限制字数)")
                    self.txt_curNum:setString(count.."/"..self.inputLimit)
                    self.txt_curNum:setTextColor(cc.c3b(255, 0, 0))
                end
           end
        end)
end

--主设置
function UI_ClubXiugaijieshao:setMainUI()
	
	
end

function UI_ClubXiugaijieshao:onUIClose()
    self:removeFromParent()
end

function UI_ClubXiugaijieshao:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
		self:onUIClose()
	elseif name == "btn_sure" then	--确定
		--发送修改内容
	   if self.callBack then
            local content = self.txt_content:getString()
            --判断是否超140字
            local count = self:utf8len(content)
            cclog("字符数 count:"..count)
            cclog("content = ",content)
            if count > self.inputLimit then
                GlobalFun:showToast(string.format("超过%d个字的限定字数,请重新输入!", self.inputLimit), 2)
                return
            end
            self.callBack(content)
        end
        self:onUIClose()
	end
end

return UI_ClubXiugaijieshao
