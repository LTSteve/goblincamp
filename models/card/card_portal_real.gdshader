shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float brightness = 2.2;
uniform float contrast = 1.0;
uniform float saturation = 0.9;

void fragment() {
	
	vec2 n_out2p0;
	// UVPolarCoord:2
	vec2 n_in2p1 = vec2(0.50000, 0.50000);
	float n_in2p2 = 1.00000;
	float n_in2p3 = 1.00000;
	{
		vec2 __dir = UV - n_in2p1;
		float __radius = length(__dir) * 2.0;
		float __angle = atan(__dir.y, __dir.x) * 1.0 / (PI * 2.0);
		n_out2p0 = vec2(__radius * n_in2p2, __angle * n_in2p3);
	}


	// FloatFunc:3
	float n_out3p0 = 1.0 - n_out2p0.x;


	// FloatOp:5
	float n_in5p1 = 1.80000;
	float n_out5p0 = n_out3p0 * n_in5p1;


	// Compare:6
	float n_in6p1 = 1.00000;
	bool n_out6p0 = n_out5p0 > n_in6p1;


	float n_out7p0;
	// Switch:7
	float n_in7p1 = 0.00000;
	n_out7p0 = mix(n_out5p0, n_in7p1, float(n_out6p0));


	// Output:0
	ALPHA = 1.0;
	
	
	
	vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	c.rgb = mix(vec3(0.0), c.rgb, brightness);
	c.rgb = mix(vec3(0.5), c.rgb, contrast);
	c.rgb = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, saturation);
	
	ALBEDO = c;
}
