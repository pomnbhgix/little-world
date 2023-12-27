shader_type spatial;

uniform vec4 WATER_COL:source_color =  vec4(0.04, 0.38, 0.88, 1.0);
uniform vec4 WATER2_COL:source_color =  vec4(0.04, 0.35, 0.78, 1.0);
uniform vec4 FOAM_COL:source_color = vec4(0.8125, 0.9609, 0.9648, 1.0);
uniform float distortion_speed = 2.0;
uniform vec2 tile = vec2(5.0, 5.0);
uniform float height = 2.0;
uniform vec2 wave_size = vec2(2.0, 2.0);
uniform float wave_speed = 1.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
