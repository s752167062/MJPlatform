--
-- Author: Your Name
-- Date: 2017-03-30 20:31:44
--
--[[
	富文本控件
	exp:
    local str = [size = 24,color = #FFBBCC,font = LexusJianHei]湖南麻将#br[size = 24,color = #06BBCC,font = LexusJianHei]桂林麻将#br
	local richtext= LLRichText:create(str,cc.size(300,300))
]]

local LLRichText = class("LLRichText", cc.Node)

function LLRichText:cotr()
    -- body
    self.size = nil
    self.fontSize = 22
    self.richText = nil
end


function LLRichText:setSize(size)
    -- body
    self.size = size
end

function LLRichText:setFontSize(fontSize)
    -- body
    self.fontSize = fontSize or 22
end

function LLRichText:setString(str)
    if self.richText then
        self.richText:removeFromParent()
    end
    local text_list = self:analyze(str)
    self.richText = self:createRichText(text_list)
    self.richText:addTo(self)
end

--解析数据
function LLRichText:analyze(str)
	local list = string.split(str,"#br")
	local text_list = {}
	for i = 1,#list do
		if string.trim(list[i]) ~= "" then
			local pattern = string.match(list[i],"%[(.+)%]")
			local text = string.gsub(list[i],"%[(.+)%]","")
			local t = {}
			local s = string.split(pattern,",")
			for i = 1,#s do
				local att = string.split(s[i],"=")
				local key = string.trim(att[1])
				local value = string.trim(att[2])
				if key then
					t[key] = value
				end
			end
			local item = {}
			item.format = t
			item.text = text
			text_list[#text_list+1] = item
		end
	end
	return text_list
end

--[[
	默认值：
	 size = 22,
	 font = LexusJianHei,
	 color = #FFFFFF
]]
function LLRichText:createRichText(text_list)
	local _richText = ccui.RichText:create()
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setContentSize(self.size)
    _richText:setPosition(cc.p(0,0))
    _richText:setAnchorPoint(cc.p(0,0.5))
    _richText:setLocalZOrder(100)
    for i = 1,#text_list do
    	local item = text_list[i]
    	local size = tonumber(item.format.size) or self.fontSize
    	local font = item.format.font or "font/LexusJianHei.ttf"
    	local color = item.format.color or "#FFFFFF"
    	color = self:HexToRGB(color)
    	local opacity = 255


    	-- local _text_list = string.split(item.text,"#nl")
    	-- if #_text_list > 1 then
	    -- 	for j = 1,#_text_list - 1 do
	    -- 		local re = ccui.RichElementText:create(i, color, opacity, _text_list[j], font, size)
	    -- 		local newLine = ccui.RichElementNewLine:create(0,cc.c3b(0,0,0),opacity)
	    -- 		_richText:pushBackElement(re)
	    -- 		_richText:pushBackElement(newLine)
	    -- 	end
    	-- else
    		local re = ccui.RichElementText:create(i, color, opacity, item.text, font, size)
	    	_richText:pushBackElement(re)
    	-- end
    end
    return _richText
end

function LLRichText:HexToRGB(color)
	local r,g,b = 255,255,255
	local color = string.gsub(color,"#","")
	r = "0x"..string.sub(color,1,2)
	g = "0x"..string.sub(color,3,4)
	b = "0x"..string.sub(color,5,6)

	r = string.format("%d",r)
	g = string.format("%d",g)
	b = string.format("%d",b)
	return cc.c3b(r,g,b)
end 

return LLRichText