#version 430
layout (location=0) uniform vec4 f;
uniform sampler2D tex;

vec3 px(vec2 uv, vec2 off) {
	return texture2D(tex, (f.yz * uv + off) / f.yz).xyz;
}

out vec4 c;
in vec2 v;
void main()
{
	vec2 uv= vec2((v.x + 1.) / 2., (v.y + 1.) / 2.);
	vec3 col;
	if (f.x == .0) {
		col = texture2D(tex, uv).xyz;
	} else {
		vec3 dir = vec3(-1.,0.,1.),
		a = px(uv, dir.xx),
		//b = px(uv, dir.yx),
		c = px(uv, dir.zx),
		//d = px(uv, dir.xy),
		e = px(uv, dir.yy),
		//f = px(uv, dir.zy),
		g = px(uv, dir.xz),
		//h = px(uv, dir.yz),
		i = px(uv, dir.zz);

		col = e*.5+(a+c+g+i)/4.*.5;
	}
	c = vec4(col, 1.);
}
