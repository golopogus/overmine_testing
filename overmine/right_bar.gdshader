shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	texture(TEXTURE,UV);
	
	COLOR = vec4(0.0,0.0,0.0,UV.x * UV.x + UV.y * UV.y - UV.y + UV.x * .5);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
