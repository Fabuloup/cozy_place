shader_type spatial;

uniform sampler2D polka_texture;
uniform vec4 color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float opacity : hint_range(0.01, 1.0) = 0.1;
uniform float dot_size : hint_range(0.001, 1.0) = 0.2;

varying vec4 NODE_POSITION_CLIP;

void vertex() {
	 NODE_POSITION_CLIP = (PROJECTION_MATRIX * vec4(NODE_POSITION_VIEW, 1.0));
}

void fragment() {
	vec2 local_uv = (SCREEN_UV * 2.0 - 1.0) - NODE_POSITION_CLIP.xy / NODE_POSITION_CLIP.w;
	// Adjust for aspect ratio and FOV
	local_uv.y *= VIEWPORT_SIZE.y / VIEWPORT_SIZE.x;

	// Sample the texture
    vec4 tex_color = texture(polka_texture, UV);
    ALBEDO.rgb = tex_color.rgb;
	ROUGHNESS = 0.8;

	// Create a grid of dots
    vec2 uv = local_uv.xy / vec2(1024, 1024) / (dot_size/1000.0);
    vec2 gv = fract(uv) - 0.5;

    // Circular mask for polka dot
    float dist = length(gv);
    float mask = step(dist, opacity * 0.8);

    // Apply alpha mask
    if (mask < 0.5) {
        discard;
    }

}
