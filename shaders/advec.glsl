#ifdef GL_ES
  precision highp float;
#endif
varying vec2      	uv;
uniform sampler2D   source0;
uniform vec2    	pixelsize;

uniform float     dt;
uniform float     dampen;
uniform float     magnitude;
uniform float     angle;
uniform float     freq;
uniform float     time;
uniform float     flowtype;

vec2 forceSpiral(vec2 uv) {
  float theta = atan(uv.x, uv.y);
  float r = length(uv);
  return vec2(uv.y-uv.x, -uv.x - uv.y);
}

vec2 forceCircle(vec2 uv) {
  // float r = 3.1415;
  vec2 dir = -uv;
  dir *= sin(6. * length(uv));

  return dir;
}

vec2 forcePoint(vec2 uv) {
  // float r = 3.1415;
  vec2 point = vec2(sin(time/100.), cos(time/100.)) * 0.25;
  return vec2(uv - point);
}

vec2 forceGrid(vec2 uv) {
  return cos(uv * sin(time/100.) *50.+  freq);
}

void main()
{
  vec2 v =  texture2D(source0, uv ).xy * pixelsize ; 

  vec2 ff = vec2(0);

  if ( flowtype == 1.0 ) {
    ff = forceGrid(uv- 0.5) * pixelsize  * magnitude * 0.2;

  } else if (flowtype == 2.0 ) {
    ff = forceSpiral(uv- 0.5) * pixelsize  * magnitude * 0.2;

  } else if (flowtype == 3.0 ) {
    ff = forceCircle(uv - 0.5) * pixelsize * magnitude;

  } 

  mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
  ff *= rot;

  vec4 a = texture2D(source0, fract(uv - v + ff));
  a.xyz *= dampen;
  gl_FragColor =  a;
}