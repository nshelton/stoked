#ifdef GL_ES
	precision highp float;
#endif

mat3 rotationMatrix(vec3 axis, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

uniform sampler2D   audio_time;
uniform sampler2D   audio_freq;
varying	vec2  		uv;

uniform	float 		time;
uniform	float 		acc;
uniform	float 		type;
uniform	float 		mod;

uniform	vec2 		pixelsize;

#define MAX_ITER 20.

float mandel(vec3 pos) {

	float Power = 6.;
	float Bailout = 1.5;

	vec3 z = rotationMatrix(vec3(0., 1., 0.), time/10.) *  ((1. + mod) * pos);
	float dr = 1.0;
	float r = 0.0;
	float iter;
	for (float i = 0.; i < MAX_ITER; i++) {
		r = length(z);
		if (r>Bailout) break;
		
		// convert to polar coordinates
		float theta = acos(z.z/r) + acc;
		float phi = atan(z.y,z.x);
		dr =  pow( r, Power-1.0 )*Power*dr + 1.0;
		
		// scale and rotate the point
		float zr = pow( r,Power);
		theta = theta*Power;
		phi = phi*Power;
		
		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=pos;
		iter++;
	}
	return 0.5*log(r)*r/dr;
}

// spherical thing
float DE(vec3 z)
{
	if ( type == 0. ) {
		return mandel(z);
	} else {
		z = rotationMatrix(normalize(vec3(1., sin( acc ), 0.)), acc) * z;
	    float r;

	    float s = 2. + sin(time)/2. + (texture2D(audio_time, vec2(length(z)/3., 0.0)).a - 0.5)/2.;
	    int iter = 0;

	    for( int n = 0 ; n < 10; n ++ ) { 
	       if(z.x+z.y<0.) z.xy = -z.yx; // fold 1
	       if(z.x+z.z<0.) z.xz = -z.zx; // fold 2
	       if(z.y+z.z<0.) z.zy = -z.yz; // fold 3	
	       z = z*s - 1.*(s-1.0);
	       iter++;
	    }

	    return (length(z) ) * pow(s, -float(iter));
	}
}

vec3 gradient(vec3 p) {
	vec2 e = vec2(0., 0.4);

	return normalize( 
		vec3(
			DE(p+e.yxx) - DE(p-e.yxx),
			DE(p+e.xyx) - DE(p-e.xyx),
			DE(p+e.xxy) - DE(p-e.xxy)
		)
	);
}					


#define PI 3.1415

void main() {
    //raymarcher!
    vec3 camera = vec3(0.,0.,-2.);
    vec3 point;
    bool hit = false;

    float thresh = 0.01;
    // if ( type == 0.)
    	// thresh = abs(sin(time) * 0.1);
 	vec3 ray = normalize( vec3(uv - 0.5, 1.0) );

 	// raycasting parameter
 	float t = 0.;
 	float iter = 0.;

    for(float i = 0.; i < MAX_ITER; i++) {

        point = camera + ray * t;
        float dist = DE(point);

        if (abs(dist) < thresh)
			break;
        
    	t += dist;
        iter ++;
    }
    
    // float shade = dot(gradient(point - ray* 0.01), ray);

	vec3 color = vec3(1., 0., 1.) ;//* shade;
	// // vignette
	color *= (1. - length(uv-0.5));
	color *= exp(1. - (abs(point.z - camera.z)));
	color *= exp(iter/MAX_ITER);

	vec3 d_col = vec3( 1. / (abs(point.z - camera.z) ));

	// float scanline = pow(sin(uv.y/pixelsize.y) + 1., .2)  ;
	// color *= scanline;

	gl_FragColor = vec4( 0., 0., iter/MAX_ITER, 0.0) ;


}