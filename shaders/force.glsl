#ifdef GL_ES
  precision highp float;
#endif


varying vec2        uv;
uniform sampler2D   source0;
uniform vec2        pixelsize;

uniform sampler2D   audio_time;
uniform sampler2D   audio_freq;

uniform vec3        trail;
uniform vec2        trail_force;

uniform vec4       decorators;
uniform vec2        audio_style;

uniform vec4        beat_vals;
uniform float        time;

vec4 texture2DInterpolate(sampler2D s, vec2 uv) {
  float index = (uv.x * 512.);
  float low = floor(index) / 512.;
  float hi = (floor(index) + 1.) / 512.;

  vec4 l = texture2D(s, vec2(low, 0.5));
  vec4 h = texture2D(s, vec2(hi, 0.5));

  float a = fract(index);
  return h * a + (1. - a) * l;
}

// audio_style x : 0 is radial  1 is flat
//             y : 0 is time    1 is FFT
vec4 audioOverlay(vec2 uv, vec2 audio_style, vec4 result) {
  if ( audio_style.x == 0.0 ) {
    if ( audio_style.y == 1.0 ) {   

      //////////////////
      // Radial FFT
      vec2 c = uv - 0.5;
      vec2 texpos = vec2(atan(c.x, c.y)/6.4, 0.0);
      float f = texture2D(audio_freq, texpos).a;
      float r = length(c);
      if(r > 0.45 && r < 0.5) {
        result.z = f ;
        result.xy = -f * 100. *  (uv - 0.5);
      }

    } else {       

      //////////////////
      // Radial Scope
      float theta = atan(uv.x - 0.5, uv.y - 0.5);
      vec2 texpos = vec2(theta, 0.0);
      float s = texture2D(audio_time, texpos).a/2. + 0.1 ;

      float r = length(uv - 0.5);
      if ( abs(r - s) < 0.01) {
        result.z = 1.;
        float mag = -50. * s;

        result.y = mag * (uv.y - 0.5);
        result.x = mag * (uv.x - 0.5);

      } 
      //////////////////
      // Radial FFT
      // float angle = atan(uv.x-0.5, uv.y-0.5)/( 6.26);
      // if(angle < 0.)
      //   angle += 0.5;
      // vec2 texpos = vec2(angle, 0.0);
      // // float s = texture2DInterpolate(audio_freq, texpos).a;
      // float s = log(texture2DInterpolate(audio_freq, texpos).a * 100.)/30.;
      // // if (length(uv - 0.5) < 0.35 + s/5. && length(uv - 0.5) > 0.3 +s/5.  ) {
      // if (uv.x < 0.1 || uv.y < 0.1 || uv.y > 0.9 || uv.x > 0.9) {
      //   result.z = s ;
      //     result.xy = 3. * s * (uv - 0.5);
      // }

    }
  } else if (audio_style.x == 1.0) {
    if ( audio_style.y == 1.0 ) {   
      //////////////////
      // Flat FFT
      vec2 texpos = vec2(uv.x- 0.02, 0.0);
      float s = log(texture2DInterpolate(audio_freq, texpos).a * 10.)/10.;
      if (abs(uv.y - 0.5 ) < s/2. ) {
        result.z = s;
        result.xy = 15. * vec2(0., s * sign(uv.y - 0.5));
      }
    } else {
      //////////////////
      // Flat Scope
      float s = texture2DInterpolate(audio_time, uv).a/2. + 0.25  ;

      if ( abs(uv.y - s) < 0.02) {
        result.z = (0.8 - abs(uv.y - s) );
        result.y -= 400. * (uv.y - s);
      }
    }
  } 


  return result;
}

vec4 circles(vec2 uv, vec3 pos, vec4 result) {
        // ROTATING CIRLES
    vec2 p = pos.xy - 0.5;
    float t_p = 1.25;
    mat2 pentagon = mat2(cos(t_p), sin(t_p), -sin(t_p), cos(t_p));
    float size = pos.z * pixelsize.x;
     if ((length(p - (uv- 0.5)) < size  ||
      length(pentagon * p - (uv- 0.5)) < size  ||
      length(pentagon * pentagon * p - (uv- 0.5)) < size ||
      length(pentagon * pentagon * pentagon * p - (uv- 0.5)) < size )) {

      result.z = pos.z / 100.;
      result.a = 0.0;
      result.xy = -10. * (uv - 0.5);
    }  
    return result;
}


void main()
{
  vec4 result   =  texture2D(source0, uv);



  // if we want to show audio data --
  if (decorators.r == 1.0)
    result = audioOverlay(uv, audio_style, result);
  // if we want circles
  if (decorators.g == 1.0) 
    result = circles(uv, trail, result);

  


  gl_FragColor =  result;
}