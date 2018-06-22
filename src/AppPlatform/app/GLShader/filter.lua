--@渲染管线着色器基类
--@Author   sunfan
--@date     2017/07/27

local programCache = cc.GLProgramCache:getInstance()

local Filter = class("Filter")

function Filter:ctor(params, nomvp)
	if params.vsh then
		params.vsh = self:getShaderPath(params.vsh..".vsh")
	else
		params.vsh = self:getShaderPath(nomvp and "position_texture_color_nomvp.vsh" or "position_texture_color.vsh")
	end
	params.fsh = self:getShaderPath(params.fsh .. ".fsh")
	if nomvp then
		params.shaderName = params.shaderName .. "_NOMVP"
	end
	
	local program = programCache:getGLProgram(params.shaderName)
	if not program then
		program = cc.GLProgram:createWithFilenames(params.vsh, params.fsh)
		if not program then
			return
		end
		programCache:addGLProgram(program, params.shaderName)
	end
	
	self._shader = cc.GLProgramState:create(program)
	
	if params.uniforms then
		self:setUniforms(params.uniforms)
	end
end

function Filter:getShaderPath(path)
	return __platformHomeDir .. "shader/" .. path
end

function Filter:setUniforms(params)

end

function Filter:getShader()
	return self._shader
end

return Filter