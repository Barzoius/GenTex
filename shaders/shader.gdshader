shader_type canvas_item;

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

uniform int octaves;
uniform float amplitude;
uniform float frequency;

uniform float warp_factor;


float fbm(vec2 uv) {
    float amp = amplitude;
    float freq = frequency;
    float value = 0.0;
    float amp_sum = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amp * noise(freq * uv);
        amp_sum += amp;

        amp *= 0.5;
        freq *= 2.0;
    }

    return value / amp_sum;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	vec2 warp = vec2(
    fbm(uv * warp_factor),
    fbm(uv * warp_factor + vec2(5.2))
	);
	float f = fbm(uv + 0.5 * warp);

	COLOR = vec4(vec3(f), 1.0);

}

