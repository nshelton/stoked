#ifdef GL_ES
  precision highp float;
#endif

varying vec2      uv;
uniform sampler2D   source0;
uniform sampler2D   source1;
uniform sampler2D   source2;

uniform sampler2D   audio_time;
uniform sampler2D   audio_freq;


uniform vec2    pixelsize;

uniform vec3    p_a;
uniform vec3    p_b;
uniform vec3    p_c;
uniform vec3    p_d;

uniform float   depth;
uniform float   p_scale;
uniform float   p_offs;

vec3 palette(float t) {
  t = t* p_scale + p_offs;
  return p_a + p_b * cos( 6.28318*(p_c*t+p_d ));
}

void main()
{
  vec4 val = texture2D(source0, uv);

  vec2 e = pixelsize;

  // 3D SHADINGGGGG 
  float p = texture2D(source0, uv).b;
  float u = p - texture2D(source0, uv - vec2(0.0, e.y)).b ;
  float r = p - texture2D(source0, uv - vec2(e.x, 0.0)).b;

  vec3 dy = normalize(vec3(0., e.y, u/7.));
  vec3 dx = normalize(vec3(e.x ,0., r/7.));

  vec3 n = cross(dx,dy);
  float shade = dot(n, normalize(vec3(0., 1., 1.)));
  vec3 specular = vec3(1.,1.,1.) * pow(shade, 10.);

  vec3 c = palette( val.b );

  vec3 color = depth * (specular + shade * c) + (1. - depth) * c; 
  


  gl_FragColor = vec4(color, 1.0);
  // gl_FragColor = texture2D(audio_freq, uv);
}