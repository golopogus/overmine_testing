shader_type canvas_item;
uniform float radius = 1.1;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	texture(TEXTURE,UV);
	//float radius = .2;
	float a;

	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 center = vec2(.5 * aspect,.5);
	vec2 new_pos = vec2(UV.x * aspect, UV.y);
	if (distance(new_pos,center) > radius) {
		a = 1.0 ;
		
	} else {
		
		a = 0.0;
	}

	
	
	COLOR = vec4(0.0,0.0,0.0,a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
