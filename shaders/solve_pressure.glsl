#ifdef GL_ES
  precision highp float;
#endif
varying vec2      uv;
uniform sampler2D   source0; // divergence
uniform sampler2D   source1; // pressure
uniform sampler2D   source2; // velocity
uniform vec2    pixelsize;

void main()
{
  float dx = pixelsize.x;
  float dy = pixelsize.y;

  vec4 C = texture2D(source1, uv);
  vec4 P = texture2D(source2, uv);

  vec4 U = texture2D(source1, fract(uv + vec2(0., dy)));
  vec4 D = texture2D(source1, fract(uv - vec2(0., dy)));
  vec4 L = texture2D(source1, fract(uv + vec2(dx, 0.)));
  vec4 R = texture2D(source1, fract(uv - vec2(dx, 0.)));

  vec4 div = texture2D(source0, uv);

  // Jacobi relaxation
  vec4 lapl = (U + D + L + R + div) * 0.25 + (C.b - C.a)/6000. ; 

  gl_FragColor = lapl;
}