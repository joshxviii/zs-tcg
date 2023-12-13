shader_type canvas_item;

uniform float outline_width = 2.0;
uniform vec4 outline_color: source_color;
uniform float inside_alpha : hint_range(0,1) = 0;
uniform vec4 inside_color: source_color;


vec3 interpolate_vec3(vec3 start, vec3 end, float delta){
    return start + (end - start) * delta;
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float a;
	float maxa = col.a;
	float mina = col.a;

	vec4 new_c;

	new_c.rgb = interpolate_vec3(col.rgb, inside_color.rgb, inside_alpha);
	new_c.a = col.a;

	a = texture(TEXTURE, UV + vec2(0.0, -outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(0.0, outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(-outline_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(outline_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	COLOR = mix(new_c, outline_color, maxa - mina);
	
	
}
