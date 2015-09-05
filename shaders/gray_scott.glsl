
#ifdef GL_ES
precision highp float;
#endif
varying vec2      	uv;
uniform sampler2D   source0;
uniform vec2    	pixelsize;
uniform float    	f;
uniform float    	k;
uniform float    	dt;
uniform float    	wet;
uniform vec2    	scalefield;


void main()
{
	float dx = pixelsize.x * (length(uv - 0.5) * scalefield.x + scalefield.y);
	float dy = pixelsize.y * (length(uv - 0.5) * scalefield.x + scalefield.y);

	vec4 U = texture2D(source0, fract(uv + vec2(0., dy)));
	vec4 D = texture2D(source0, fract(uv - vec2(0., dy)));
	vec4 L = texture2D(source0, fract(uv + vec2(dx, 0.)));
	vec4 R = texture2D(source0, fract(uv - vec2(dx, 0.)));
	vec4 C = texture2D(source0, uv);

	vec4 lapl = (U + D + L + R - 4. * C) * 0.25;

	// GRAY SCOTT TIME !!
	float reaction = C.a * C.b * C.b;

	vec4 update = C;

	update.a += dt * (0.90 * lapl.a - reaction + f * (1. - C.a));
	update.b += dt * (0.45 * lapl.b + reaction - (k + f) * C.b );

	update.ab = max(vec2(0.0), min(vec2(1.0), update.ab) );
	gl_FragColor = update * wet + C * (1. - wet);	

} 