--author longma
--desc text控件拓展
--date 2017-10-30


local Text = ccui.Text

--截取某个长度的字符
--str   输入的字符
--width 需要截取的像素长度
function Text:setStringByWidth(str,width)
    if str == nil then
        return
    end
	self:setString(str)
	local size = self:getContentSize()      --str的大小
	local strNum  = self:getStringLength()  --str的utf-8个数
	local len     = string.len(str)         --str的字符数
	local w = math.min(width,size.width)	    --防止写的长度超过原本长度
	local index   = math.floor(w / size.width * strNum) / strNum  * len  -- 计算截取到第几个字符
	local _str    = comFunMgr:cutUtfByLen(str,index)
	self:setString(_str)                    --将截取后的字符重新放回Text中
end 