--@渲染管线置灰着色器
--@Author   sunfan
--@date     2017/07/27

local Filter = import(".filter")

local GrayFilter = class("GrayFilter", Filter)

function GrayFilter:ctor(nomvp, r, g, b, a)
	local params = {
		shaderName = "FILTER_GRAY",
		fsh = "gray",
		uniforms = cc.vec4(r, g, b, a),
	}
	GrayFilter.super.ctor(self, params, nomvp)
end

function GrayFilter:setUniforms(params)
	self._shader:setUniformVec4("u_grayParam", params)
end

return GrayFilter