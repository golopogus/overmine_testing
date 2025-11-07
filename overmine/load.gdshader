shader_type canvas_item;
uniform float time;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 input = texture(TEXTURE,UV);
	float vis = sin(UV.y) + cos(UV.x);
	float x = cos(TIME / 2.0) + 1.0;
	float y = .5;
	float y2 = 0.0;
	float time_value = time;
	vec2 center = vec2(.5,.5);
	vec2 pos = UV - center;
	float dist = distance(UV,center);
	float angle = atan(pos.y,pos.x);
	angle = (angle + PI) / (2.0 * PI);
	float progress = clamp(TIME - time_value - .5,0.0,1.0);
	
	if (dist < .15 && dist > .075 && angle < progress){
		COLOR = vec4(1.0,1.0,1.0,1.0);
	} 
	else {
		COLOR.a = 0.0;
		}
	}