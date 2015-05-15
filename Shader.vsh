attribute vec2 a_position;
  
 varying highp float sc;
 varying highp vec2 vPos;
 uniform mat4 mvp_matrix;
uniform float u_sc;
 
void main()
{

    gl_Position  = mvp_matrix*vec4(a_position.xy, -3.4 ,1.0);
        vPos=a_position.xy;
            sc= u_sc;
      
}




