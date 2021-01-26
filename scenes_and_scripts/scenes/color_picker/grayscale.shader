shader_type canvas_item;


void fragment() {
	vec3 tex = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	COLOR.rgb = vec3(tex.r*2.0 + tex.g * 3.0 + tex.b) / 6.0;
}