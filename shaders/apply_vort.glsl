#ifdef GL_ES
  precision highp float;
#endif
varying vec2      uv;

uniform sampler2D   source0; // vorticity in
uniform sampler2D   source1; // FBO (velocity) in

uniform vec2    pixelsize;

uniform vec2    mouse;
uniform float     dt;
uniform float     vorticity;

void main()
{
  float dx = pixelsize.x;
  float dy = pixelsize.y;

  // get vorts
  vec4 U = texture2D(source0, fract(uv + vec2(0., dy)));
  vec4 D = texture2D(source0, fract(uv - vec2(0., dy)));
  vec4 R = texture2D(source0, fract(uv + vec2(dx, 0.)));
  vec4 L = texture2D(source0, fract(uv - vec2(dx, 0.)));    
  vec4 C = texture2D(source0, uv);    

  vec2 force_dir = vec2((R.x - L.x), (U.x - D.x));

  // float dxscale = 0.1;
    // force_dir *=  dxscale * C.x * vec2(1.,-1.);

  vec4 fluid = texture2D(source1, uv); // to the velocity

  fluid.xy += vorticity * force_dir;

  gl_FragColor = fluid;
}