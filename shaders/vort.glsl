      #ifdef GL_ES
        precision highp float;
      #endif
      varying vec2      uv;
      uniform sampler2D   source0; // velocity in
      uniform vec2    pixelsize;

      uniform vec2    mouse;
      uniform float     dt;

      void main()
      {

        float dx = pixelsize.x;
        float dy = pixelsize.y;

        float U = texture2D(source0, fract(uv + vec2(0., dy))).x;
        float D = texture2D(source0, fract(uv - vec2(0., dy))).x;
        float L = texture2D(source0, fract(uv + vec2(dx, 0.))).y;
        float R = texture2D(source0, fract(uv - vec2(dx, 0.))).y;

        float curl = 0.5 * ((R - L) - (U - D));

        gl_FragColor = vec4(abs(curl));
      }