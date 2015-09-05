#ifdef GL_ES
  precision highp float;
#endif
varying vec2      uv;
uniform sampler2D   source0;  // velocity
uniform sampler2D   source1;  // pressure
uniform vec2    pixelsize;

void main()
{
  float dx = pixelsize.x;
  float dy = pixelsize.y;
  // pressure gradient
  float U = texture2D(source1, fract(uv + vec2(0., dy))).x;
  float D = texture2D(source1, fract(uv - vec2(0., dy))).x;
  float L = texture2D(source1, fract(uv - vec2(dx, 0.))).x;
  float R = texture2D(source1, fract(uv + vec2(dx, 0.))).x;


  vec4 V = texture2D(source0, uv);
  V.xy -= 0.5 * vec2((R - L), (U - D));

  gl_FragColor = V;
}