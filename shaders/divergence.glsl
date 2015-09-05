#ifdef GL_ES
  precision highp float;
#endif
varying vec2      uv;
uniform sampler2D   source0;
uniform vec2    pixelsize;

void main()
{
  float dx = pixelsize.x;
  float dy = pixelsize.y;

  float U = texture2D(source0, fract(uv + vec2(0., dy))).y;
  float D = texture2D(source0, fract(uv - vec2(0., dy))).y;
  float L = texture2D(source0, fract(uv + vec2(dx, 0.))).x;
  float R = texture2D(source0, fract(uv - vec2(dx, 0.))).x;

  float d = - 0.5 * ((U - D) + (L - R));
  gl_FragColor = vec4(d, d, d, 1.0);
}