
var defaults = {
  time :          0,
  frame :         0,
  diffuse_iterations: 1,
  pressure_iterations: 10,
  accumulator:    0,
  beats:          0,
  fluid:          1,
  raytrace:       0,
  dTheta :        0.,
  beat_circles_enabled: false,

  render : {
    p_scale:      1,
    p_offs:       1.5,
    p_a:          [0.5, 0.5, 0.5],
    p_b:          [0.5, 0.5, 0.5],
    p_c:          [1.0, 1.0, 1.0],
    p_d:          [0.0, 0.1, 0.2],
    depth:        0

  },
  gray_scott  : {
    k:            0.055,
    f:            0.023,
    dt:           1,
    wet:          0,
    scalefield:   [3, .5]
  },
  force : {
    trail:        [-1.0, -1.0, 20],
    trail_force:  [0.5,0.5],
    decorators:   [1, 1, 0, 0], // AUDIO, CIRCLES, ? , ? 
    audio_style:  [1, 1], //[radial/flat, time/fft]
  },
  advec : {
    dampen:       1,
    magnitude:    0,
    angle:        7,
    freq:         100,
    flowtype:     0,

  },
  apply_vort : {
    vorticity:      0

  },
  diffuse : {
    viscosity:      0.1

  },
  raytracer : {
    time:           1,
    type:           0,
    acc:            0,
    mod:            0,
  },

  animate : function() {
    this.accumulator += this.audio.data.levels.direct[1];

    var b = this.audio.data.beat

    // reverse flow on 8th beat
    if (this.beat_circles_enabled && b.is) {
      var tx = Math.sin(this.time * 5000 )/3 + 0.5
      var ty = Math.cos(this.time * 5000 )/3 + 0.5

      this.force.trail.set(tx, ty, b.is * 50 * b.confidence)

    } else {
      this.force.trail.set(-1, -1, 1)

    }

    if ( b.is ) {
      this.beats += 1;
        // var mag =  Math.floor(4 * this.audio.data.levels.direct[0]);
        // for ( var i = 0; i < mag; i ++)
          // autoStepper()

      if ( this.beats % 8 == 0){



        this.advec.magnitude.set(b.confidence * 50);
       }
    } 

    this.render.p_offs.set(this.accumulator/200.);

    this.advec.angle.set((this.time * this.dTheta)/100.);
    this.advec.freq.set(500);

    this.advec.time.set(this.time)
    this.advec.freq.set(10 * Math.sin(this.accumulator/100.));


    if (this.gray_scott.wet.value[0] == 1.0) {
      this.diffuse_iterations = this.audio.data.levels.smooth[0] * 40;
      this.gray_scott.scalefield.set(-3, -1.5 + Math.sin(this.accumulator/30.))
      this.gray_scott.f.set(0.023 + Math.sin(this.time/100.) /100.);
      this.gray_scott.k.set(0.050 + Math.sin(this.time/100.) /80.);
      this.render.depth.set(0.5);
    }

    // this["force"].trail_force.set(b.confidence, b.confidence)

    this["raytracer"].acc.set(this.accumulator/50.)
    this["raytracer"].mod.set(this.audio.data.levels.smooth[1]/3.)
    this["raytracer"].time.set(this.time/50.)
    this["force"].time.set(this.time/20.)


  },


}