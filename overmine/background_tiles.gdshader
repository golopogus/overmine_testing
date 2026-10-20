shader_type canvas_item;

uniform vec2 position = vec2(0.0,0.0);
uniform vec2 camera = vec2(1.0,1.0);
uniform vec2 offset = vec2(0,0);
varying vec2 world_pos;
uniform vec4 color1 : source_color = vec4(.373,.404,.490,1.0);
uniform vec4 color2 : source_color = vec4(.592,.616,.675,1.0);



void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	
	vec2 size = vec2(32.0,32.0)*camera;
	vec2 square = floor((world_pos+position*camera - offset) / size);
	float checker = mod(square.x + square.y, 2.0);
	COLOR = mix(color1,color2,checker);
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
