
var FLUID = function(){};

FLUID.prototype = {
  loadExtension : function(extension_name) {
    if( !this.context.enableExtension(extension_name)) {
      alert( "No support for " + extension_name + "!" );
      return;
    }
  },
  init: function(scale, shaders, params) {
    var buildShader = function (frag_id, textures, shared_uniforms) {
      var base_uniforms = {
        vertices: GLOW.Geometry.Plane.vertices(),
        uvs: GLOW.Geometry.Plane.uvs()
      };
      for( var i = 0; i < textures.length; i ++) {
        base_uniforms["source"+i] = textures[i];
      }

      $.extend(base_uniforms, shared_uniforms);
      $.extend(base_uniforms, params[frag_id]);

      return new GLOW.Shader({
        data : base_uniforms,
        indices: GLOW.Geometry.Plane.indices(),
        vertexShader:  shaders.vertex.shader,
        fragmentShader: shaders[frag_id].shader
      });

    };
    var emptyTexture = function(w) {
      return new GLOW.Texture( { 
        data: new Uint8Array(w),
        format: GL.ALPHA,       
        internalFormat: GL.ALPHA,
        autoUpdate: true,
        width: w,
        height: 1
      });
    }

    var buildFBO = function(w, h) {
      return new GLOW.FBO( { 
        width: w, height: h,
          depth: false,
          data: new Float32Array( w * h * 4 ),
          type: GL.FLOAT,
        // minFilter: GL.NEAREST, 
        // magFilter: GL.NEAREST
      });
    };

    this.params = params;
    this.context = new GLOW.Context();
    this.container = document.getElementById( 'container' );

    this.loadExtension("OES_texture_float" );
    this.loadExtension("OES_texture_float_linear");

    this.container.appendChild(this.context.domElement );
    var w = Math.round(this.container.clientWidth / scale);
    var h = Math.round(this.container.clientHeight / scale);
    
    // swap buffers of fluid & velocty
    this.FBO_A        = buildFBO(w, h);
    this.FBO_B        = buildFBO(w, h);

    // another buffer to hold pressure / divergence 
    this.FBO_div      = buildFBO(w, h);
    this.FBO_pressA   = buildFBO(w, h);
    this.FBO_pressB   = buildFBO(w, h);

    ////////////////////////////////////////////////////////////
    // SHADERS
    // this area just sets up the render graph

    var shared_uniforms = {
      pixelsize: new GLOW.Vector2(1 / w , 1/ h ),
      time: new GLOW.Float(1.),
      audio_time : emptyTexture(512),
      audio_freq : emptyTexture(512),
    }


    shared_uniforms.audio_time.data = params.audio.data.time;
    shared_uniforms.audio_freq.data = params.audio.data.freq;

    this.renderer       = buildShader('render', [this.FBO_A, this.FBO_div, this.FBO_pressA], shared_uniforms);
    this.gray_scott     = buildShader('gray_scott', [this.FBO_B], shared_uniforms);
    this.applyForce   = buildShader('force', [this.FBO_A], shared_uniforms);

    // Boring shaders
    this.clearFBO   = buildShader('clear', [], shared_uniforms);
    this.diffuse_a_to_b = buildShader('diffuse', [this.FBO_A], shared_uniforms);
    this.diffuse_b_to_a = buildShader('diffuse', [this.FBO_B], shared_uniforms);
    this.solveP_a_to_b  = buildShader('solve_pressure', [this.FBO_div, this.FBO_pressA, this.FBO_A], shared_uniforms);
    this.solveP_b_to_a  = buildShader('solve_pressure', [this.FBO_div, this.FBO_pressB, this.FBO_B], shared_uniforms);
    this.projectField   = buildShader('sub_grad', [this.FBO_A, this.FBO_pressA], shared_uniforms);
    this.calcDivergence = buildShader('divergence', [this.FBO_A], shared_uniforms);
    this.calc_vort    = buildShader('vort', [this.FBO_B], shared_uniforms);
    this.apply_vort     = buildShader('apply_vort', [this.FBO_div, this.FBO_B], shared_uniforms);
    this.advection    = buildShader('advec', [this.FBO_B], shared_uniforms);
    this.raytracer    = buildShader('raytracer', [], shared_uniforms);

    setupClickUI(this.applyForce);
  },
  shaderPass: function(shader, tgt) {
    this.context.cache.clear();
    tgt.bind();
    shader.draw();
    tgt.unbind();
  },
  renderFluid : function() {

    this.shaderPass(this.applyForce, this.FBO_B);
    this.shaderPass(this.advection, this.FBO_A);

    for ( var i = 0; i < this.params.diffuse_iterations; i ++ ) {
      this.shaderPass(this.diffuse_a_to_b, this.FBO_B);
      // this.shaderPass(this.diffuse_b_to_a, this.FBO_A);
      this.shaderPass(this.gray_scott, this.FBO_A);
    }

    this.shaderPass(this.calcDivergence, this.FBO_div);
    this.shaderPass(this.clearFBO, this.FBO_pressA); 
    for ( var i = 0; i <  this.params.pressure_iterations; i ++ ) {
      this.shaderPass(this.solveP_a_to_b, this.FBO_pressB);
      this.shaderPass(this.solveP_b_to_a, this.FBO_pressA);
    }

    this.shaderPass(this.projectField, this.FBO_B);
  //this.shaderPass(this.diffuse_b_to_a, this.FBO_A);
     this.shaderPass(this.calc_vort, this.FBO_div);
     this.shaderPass(this.apply_vort, this.FBO_A);

    this.renderer.draw();
  },
  renderRaytrace : function() {
     this.shaderPass(this.raytracer, this.FBO_A);
    this.renderer.draw();
    
  }
};