      #ifdef GL_ES
        precision highp float;
      #endif
      varying vec2      uv;
      uniform sampler2D   source0;
      uniform vec2    pixelsize;

      uniform float viscosity;

      void main()
      {
        // float radialscale = (sin(uv.x* 10.) * sin(uv.y * 10.) * 0.5 + 0.5) + 0.5;
        // float radialscale -
        float dx = pixelsize.x ; 
        float dy = pixelsize.y ;

        vec4 U = texture2D(source0, fract(uv + vec2(0., dy)));
        vec4 D = texture2D(source0, fract(uv - vec2(0., dy)));
        vec4 L = texture2D(source0, fract(uv + vec2(dx, 0.)));
        vec4 R = texture2D(source0, fract(uv - vec2(dx, 0.)));
        vec4 C = texture2D(source0, uv);

        vec4 lapl = (U + D + L + R - 4. * C) * 0.25;

        C.xy += lapl.xy * viscosity;
        // C += lapl;

        gl_FragColor = C;
      }