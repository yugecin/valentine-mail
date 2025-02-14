#version 430
#define MAT_GRID 0
#define MAT_PAP 1
#define MAT_C 2
#define iTime f[0].x
layout (location=0) uniform vec4 f[2];
uniform sampler2D tex;

vec3 gHitPosition = vec3(0);
vec3 ro = vec3(-20, 1, -70);
vec3 at = vec3(-5, 0, 0);
vec2 threeduv = vec2(0);
int i;

mat2 rot2(float a){float s=sin(a),c=cos(a);return mat2(c,s,-s,c);}
float rand(vec2 p){return fract(sin(dot(p.xy,vec2(12.9898,78.233)))*43758.5453);}

float box(vec3 p, vec3 b)
{
	vec3 q = abs(p) - b;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float plane(vec3 p, vec3 n, float h)
{
	return dot(p,n) + h;
}

float prel(float a, float b, float x) { return (x - a) / (b - a); }
vec2 prel2(vec2 a, vec2 b, vec2 x) { return (x - a) / (b - a); }

vec2 map(vec3 q)
{
	float paper = plane(q, vec3(0.,0.,-1.), 1.);
	float env = box(q, vec3(30.,50.,.3)) - .1;
	if (env < paper) {
		return vec2(env, MAT_PAP);
	}
	return vec2(paper, MAT_GRID);
}

vec3 norm(vec3 p, float dist_to_p)
{
	vec2 e=vec2(.00035,-.00035);
	return normalize(e.xyy*map(p+e.xyy).x+e.yyx*map(p+e.yyx).x+e.yxy*map(p+e.yxy).x+e.xxx*map(p+e.xxx).x);
}

// x=hit y=dist_to_p z=dist_to_ro w=material(if hit)
vec4 march(vec3 ro, vec3 rd, int maxSteps)
{
	vec4 r = vec4(0);
	for (i = 0; i < maxSteps && r.z < 3000.; i++){
		gHitPosition = ro + rd * r.z;
		vec2 m = map(gHitPosition);
		float dist = m.x;
		if (dist < .0001) {
			r.x = float(i)/float(maxSteps);
			r.y = dist;
			r.w = m.y;
			break;
		}
		r.z += dist * .9;
	}
	return r;
}

vec3 colorHit(vec4 result, vec3 rd)
{
	vec3 shade = vec3(0., 1., 0.);

	switch (int(result.w)) {
	case MAT_GRID: {
		float x = mod(gHitPosition.x, 4.);
		float y = mod(gHitPosition.y, 4.);
		shade = (x < .2 || y < .2 ? vec3(.3685,.5114,.6592) : vec3(.5542,.7011,.8045)) - .07 * rand(gHitPosition.xy);
		break;
	}
	case MAT_PAP: shade = vec3(.4647,.325,.2348); break;
	//case MAT_PAP: shade = vec3(180.,153.,132.)/255.; break;
	case MAT_C: shade = vec3(1.,0.,0.); break;
	}

	vec3 normal = norm(gHitPosition, result.y);
	vec3 material = shade;
	float n = dot(normal,normalize(ro-gHitPosition));

	return material * (.3 + n * .7);
}

out vec4 c;
in vec2 v;
void main()
{
        vec3	cf = normalize(at-ro),
		cl = normalize(cross(cf,vec3(0,0,-1)));
	mat3 rdbase = mat3(cl,normalize(cross(cl,cf)),cf);

	vec3 resultcol = vec3(0.);
	bool hit = false;
	vec2 uv=v;uv.y/=1.77;
	vec2 uv01= vec2((v.x + 1.) / 2., (v.y + 1.) / 2.);
	vec3 rd = rdbase*normalize(vec3(uv,1));
	vec3 col = vec3(0.);

	vec4 result = march(ro, rd, 200);

	if (result.x > 0.) { // hit
		hit = true;
		col = colorHit(result, rd);
	}
	resultcol += col;
	resultcol += texture2D(tex, uv01).xyz;

	c = vec4(pow(resultcol, vec3(.4545)), 1.0); // 'gamma correction' that everyone else does for some good reason probably
}
