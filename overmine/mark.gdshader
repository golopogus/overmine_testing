shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec4 input = texture(TEXTURE,UV);
	if (input.x > .4) {
		float red = .75 * pow(sin(2.0 * TIME),2.0) + .25;
		COLOR = vec4(red,0.0,0.0,1.0);
	}
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
