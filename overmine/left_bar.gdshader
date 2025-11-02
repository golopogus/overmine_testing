shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	texture(TEXTURE,UV);
	
	COLOR = vec4(0.0,0.0,0.0,(1.0-UV.x) * (1.0-UV.x) +  UV.y * UV.y - UV.y + (1.0-UV.x) * .5);
	
	
	
	//COLOR = vec4(UV,1,1);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
