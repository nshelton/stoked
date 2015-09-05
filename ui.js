  var index = 0;

function setupClickUI(shader) {
  // var drag = false;
  // $("canvas").mousedown(function(event) {
  //   drag = true;
  //   shader.mouse.set(
  //     event.pageX / window.innerWidth,
  //     1.0 - event.pageY /window.innerHeight);
  // });

  // $("canvas").mouseup(function(event) {drag = false});

  // $("canvas").mousemove(function(event) {
  //   if(drag)
  //     shader.mouse.set(
  //        event.pageX / window.innerWidth,
  //        1.0 - event.pageY /window.innerHeight);
  // });

  // $("canvas").mouseup(function(event) {
  //   shader.mouse.set(-1,-1);
  // });



  $('body').keypress(function(e){

    e.preventDefault()
    
    // DECORATORS
    if(e.keyCode == 49){
      var s = PARAMS.force.audio_style;
      s.set(s.value[0] == 0 ? 1: 0, s.value[1])
    }

    if(e.keyCode == 50){
      var s = PARAMS.force.audio_style;
      s.set(s.value[0], s.value[1] == 0 ? 1: 0)
    }

    if(e.keyCode == 51){
      PARAMS.toggle_rd()
    }

    if(e.keyCode == 52){
      PARAMS.beat_circles_enabled =! PARAMS.beat_circles_enabled
    }



    // FLOW TYPE
    if(e.keyCode == 113){
      PARAMS.advec.flowtype.add(1)
      PARAMS.advec.magnitude.set(25)
      PARAMS.advec.flowtype.modulo(4)
    }
    if(e.keyCode == 119){
      PARAMS.dTheta = PARAMS.dTheta > 0 ? 0 : 10;
    }
    if(e.keyCode == 101){
      PARAMS.advec.dampen.multiply(1.04)
      var v = PARAMS.advec.dampen.value[0];

      if (v > 1.0) 
        PARAMS.advec.dampen.set(0.9)

    }

    // Color scheme  
    if(e.keyCode == 122){
      index = (index + 1) % presets.length;
      PARAMS.set(presets[index])
    }

    // Raycast
    if(e.keyCode == 97){
      PARAMS.raytrace = !PARAMS.raytrace
      PARAMS.fluid = !PARAMS.fluid

      // if (PARAMS.raytrace) {
      //   PARAMS.render.p_scale.set(0.2)
      // }
    }
    if(e.keyCode == 115){
      PARAMS.raytracer.type.add(1)
      PARAMS.raytracer.type.modulo(2)
    }

    console.log(e.keyCode)

    if(e.keyCode == 32){
         running = !running;
     }
  });

}

function autoStepper() {

  var x = Math.floor(Math.random() * 16)

  // if(PARAMS.raytrace  && Math.random() > 0.25)
    // x = 11

  switch ( x ) {
    case 0:
      index = (index + 1) % palettes.length;
      PARAMS.set({"render": palettes[index]})
      break
      // decorator type
    case 1:
      var s = PARAMS.force.audio_style.set(0, 0)
      break
    case 2:
      var s = PARAMS.force.audio_style.set(1, 1)
      break
    case 3:
      var s = PARAMS.force.audio_style.set(1, 0)
      break
    case 4:
      var s = PARAMS.force.audio_style.set(0, 1)
      break
    case 5:
      PARAMS.beat_circles_enabled =! PARAMS.beat_circles_enabled
      break

    // FLOWTYPE
    case 6:
      PARAMS.advec.flowtype.set(1)
      break
    case 7:
      PARAMS.advec.flowtype.set(2)
      break
    case 8:
      PARAMS.advec.flowtype.set(3)
      break
    case 9:
      PARAMS.advec.flowtype.set(0)
      break
    case 10: 
      PARAMS.dTheta = PARAMS.dTheta > 0 ? 0 : 10;
      break;
      // raytracer
    case 11: 
      PARAMS.raytrace = !PARAMS.raytrace
      PARAMS.fluid = !PARAMS.fluid
      PARAMS.raytracer.type.set(1)
      PARAMS.render.p_scale.set(PARAMS.raytrace ? 0.7 : 1.0)
      PARAMS.render.depth.set(0)
      break
    case 12:
      PARAMS.raytrace = !PARAMS.raytrace
      PARAMS.fluid = !PARAMS.fluid
      PARAMS.raytracer.type.set(0)
      PARAMS.render.p_scale.set(PARAMS.raytrace == 1 ? 0.7 : 1.0)
      PARAMS.render.depth.set(0)
      break
    case 13:
      PARAMS.advec.magnitude.set(Math.random() * 10)
      break
    case 14:
      PARAMS.advec.magnitude.multiply(-1)
      break
    case 15:
      if (!PARAMS.raytrace)
        PARAMS.toggle_rd()
      break
    case 16:
      PARAMS.render.p_scale.set(Math.random()+ 0.5)


  }



}
