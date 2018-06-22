#ifdef GL_ES
precision mediump float;
#endif
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

uniform vec4 u_grayParam;

void main(void)
{
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	float grey = dot(texColor.rgba, u_grayParam);
	gl_FragColor = vec4(vec3(grey), texColor.a) * v_fragmentColor;
}
