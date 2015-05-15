uniform highp vec2 resolution ;
varying highp float sc;
 varying highp vec2 vPos;
uniform highp float u_time ;
precision mediump float;
 
 

void main()
{ 

vec2 pos=vPos;


	vec2 light_pos = ((pos/sc)-(pos/u_time))   ;
	/* The radius of the light */
	float radius = light_pos.y ;
	/* Intensity range: 0.0 - 1.0 */

	/* Distance between the fragment and the light */
	float dist = distance( light_pos,pos)  ;
	float intensity = sc*sc;
float alpha = atan(dist);
	/* Basic light color, change it to your likings */
	vec3 light_color = vec3(dist  ,0,0);
	/* Alpha value of the fragment calculated based on intensity and distance */
	

	/* The final color, calculated by multiplying the light color with the alpha value */
	vec4 final_color = vec4( light_color ,  1.0)*vec4(alpha, alpha, alpha, 1.0);
	
	 final_color.rgb *=  cos(dist )  + sin(dist  )     ;
	  final_color.rgb *=2.0;
	  //final_color.rgb *= atan(dist)+cos(dist);
 
 

	gl_FragColor =  final_color ;
 

    
} 


