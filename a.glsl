#version 430
layout (location=0) uniform vec4 f[2];
layout (location=4) uniform sampler2D tex;

out vec4 c;
in vec2 v;
void main()
{
	vec3 col = vec3((v+1.)/2., 0.);
	c = vec4(pow(col, vec3(.4545)), 1.0); // 'gamma correction' that everyone else does for some good reason probably
}
