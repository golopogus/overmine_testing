shader_type canvas_item;
uniform float dist = 0.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	float x;
	float y;

	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	if (UV.x < dist / aspect|| UV.x > 1.0 - dist / aspect){
		x = 1.0;
	}
	else {
		x = 0.0;
	}
	if (UV.y < dist || UV.y > 1.0 - dist){
		y = 1.0;
	}
	else {
		y = 0.0;
	}

	COLOR = vec4(0.0,0.0,0.0,x + y);
	}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
