shader_type spatial;
render_mode blend_mix, diffuse_toon, specular_disabled, shadows_disabled, ambient_light_disabled;

instance uniform vec4 colour : source_color;

void fragment() {
	ALBEDO = colour.rgb;
	ALPHA = colour.a;
}
