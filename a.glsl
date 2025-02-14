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
	float env = box(q, vec3(30.,53.1,.3)) - .1;
	if (env < paper) {
		threeduv = (gHitPosition.yx + vec2(53.1,30.))/vec2(106.2,60.);
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

vec3 mb(vec2 mb)
{
	// mountainbytes logo, copied from my earlier "c-chord" exegfx..
	// x-4 is mid, height is 4 so x is -8 to 0
	float a = .03, b = .62;
	if (mb.x > .5) {
		b = .03;a = .62;
	}
	mb.x = abs(mb.x-.5)*2.;
	if (mb.y > .33) {
		float y = (mb.y-.33)/.66;
		if (mb.x < .715) {
			float x = mb.x/.715;
			if (x > .5 && (x-.5)*2. > 1.-y) {
				return vec3(1.)*b;
			} else if (x > 1.-y) {
				return vec3(1.)*a;
			}
		} else if ((mb.x-.715)/.285<y) {
			return vec3(1.)*b;
		}
	}
	if (mb.x < mb.y) {
		return vec3(1.)*b;
	}
	return vec3(0.);
}

vec4 stamp(vec2 uv)
{
	uv.y = ((uv.y - .5) / 1.4) + .5;
	vec2 huv = mod(uv-vec2(.03,.03), .07)+.05;
	if ((uv.x < .05 || uv.x > .95 || uv.y < .2 || uv.y > .8) && length(huv - vec2(.1)) < .02) {
		return vec4(0.);
	}
	vec3 s = vec3(.523,.505,.476);
	if (.06 < uv.x  && uv.x < .2 && .2 < uv.y && uv.y < .8) {
		vec4 r = vec4(.344,0.,0.,1.);
		r += texture2D(tex, uv*vec2(1.2,.7)*rot2(3.1415/2)-vec2(.17,.1));
		if (uv.y > .6) {
			vec2 nuv = vec2(prel(.06, .2, uv.x), prel(.6, .8, uv.y));
			r += texture2D(tex, mix(vec2(.56,.7),vec2(.61,.8),nuv.yx));
		}
		return r;
	}
	if (.23 < uv.x  && uv.x < .94 && .28 < uv.y && uv.y < .72) {
		vec3 m = mb(prel2(vec2(.23, .72), vec2(.94,.28), uv));
		if (m.x > .001) return vec4(m,1.);
	}
	return vec4(s,1.);
}

vec3 colorHit(vec4 result, vec3 rd)
{
	vec2 xy = mod(gHitPosition.xy-vec2(5.), 4.);
	vec3 shade = (xy.x < .2 || xy.y < .2 ? vec3(.3685,.5114,.6592) : vec3(.5542,.7011,.8045)) - .07 * rand(gHitPosition.xy);

	if (int(result.w) == MAT_PAP) {
		shade = vec3(.4647,.325,.2348);
		vec2 xx = prel2(vec2(.75,.68),vec2(.95,.92),threeduv);
		if (xx.x > 0. && xx.y > 0. && xx.x < 1. && xx.y < 1.) {
			// stamp
			vec4 st = stamp(xx);
			if (st.w < .5) {
				if (stamp(xx+vec2(-.001,.01)).w > .5) shade = vec3(0.);
			} else shade = st.xyz;
		} else {
			xx = prel2(vec2(.5,.15),vec2(.94,.55),threeduv);
			// macro opportunity?
			if (xx.x > 0. && xx.y > 0. && xx.x < 1. && xx.y < 1.) {
				// address
				shade *= 1.-texture2D(tex, mix(vec2(.5,.165),vec2(.77,.5),xx)).xyz;
			}
		}
	}

	vec3 normal = norm(gHitPosition, result.y);
	vec3 material = shade;
	float n = dot(normal,normalize(ro-gHitPosition)); // TODO: should this be ro-at?

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
	//resultcol += texture2D(tex, uv01).xyz;

	c = vec4(pow(resultcol, vec3(.4545)), 1.0); // 'gamma correction' that everyone else does for some good reason probably
}
