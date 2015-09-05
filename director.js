var PARAMS = {
  time : 0.0,
  frame : 0.0,
  diffuse_iterations: 1.0,
  pressure_iterations: 10.0,
  accumulator: 0.0,
  beats: 0.0,
  fluid: 0.0,
  raytrace: 1.0,
  dTheta : 10.0,
  beat_circles_enabled: false,
  render : {
    p_scale:      new GLOW.Float(),
    p_offs:       new GLOW.Float(),
    p_a:          new GLOW.Vector3(),
    p_b:          new GLOW.Vector3(),
    p_c:          new GLOW.Vector3(),
    p_d:          new GLOW.Vector3(),
    depth:        new GLOW.Float(),
  },
  gray_scott : {
    k:            new GLOW.Float(),
    f:            new GLOW.Float(),
    dt:           new GLOW.Float(),
    wet:          new GLOW.Float(),
    scalefield:   new GLOW.Vector2(),
  },
  force : {
    trail:        new GLOW.Vector3(),
    trail_force:  new GLOW.Vector2(),
    decorators:   new GLOW.Vector4(),
    audio_style:  new GLOW.Vector2(),
    time:         new GLOW.Float(),
  },
  advec : {
    dampen:       new GLOW.Float(),
    magnitude:    new GLOW.Float(),
    angle:        new GLOW.Float(),
    freq:         new GLOW.Float(),
    flowtype:     new GLOW.Float(),
    time:         new GLOW.Float(),

  },
  apply_vort : {
    vorticity:     new GLOW.Float()

  },
  diffuse : {
    viscosity:     new GLOW.Float()

  },
  raytracer : {
    time: new GLOW.Float(),
    type: new GLOW.Float(),
    acc: new GLOW.Float(),
    mod: new GLOW.Float(),
  },

  advance : function() {
    this.time += 0.1
    this.audio.update();
    this.animate();
  },

  set : function(params) {
    for (p in params) {

      if (!params.hasOwnProperty(p)){
          continue;
      }

      if (!this.hasOwnProperty(p)){
        console.log("tried to set unknown parameter " + p )
        continue;
      }
      if (typeof this[p] === 'number' || typeof this[p] === 'function' ) {  

        this[p] = params[p]

      } else {
        for(i in params[p]) {
          if (!params[p].hasOwnProperty(i)) {
              continue;
          }

          console.log("Set " + p + " " + i + " to " + params[p][i])
          if ( typeof params[p][i]  === "number" )
            this[p][i].set(params[p][i]);
          else
            this[p][i].set.apply(this[p][i], params[p][i] );


        }
      }
    }
  },
  toggle_rd : function() {
    if(this.gray_scott.wet.value[0] == 0){

        this.gray_scott.wet.set(1);
        this['render'].depth.set(0.5)
        this['render'].p_scale.set(-2)

        this['advec'].dampen.set(1)

      } else {
        // this['render'].p_scale.set(-0.2)
        this.gray_scott.wet.set(0);
        this.diffuse_iterations=1;
        this['render'].depth.set(0)
        this['render'].p_scale.set(1)
        this['advec'].dampen.set(0.99)
      }
  },
  animate : function() { }, //this gets overwritten
}