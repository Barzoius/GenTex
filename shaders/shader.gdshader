shader_type canvas_item;

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

//vec2 random(vec2 uv) {
	//return vec2(fract(sin(dot(uv.xy,
		//vec2(12.9898,78.233))) * 43758.5453123));
//}

float frandom(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
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

float worley(vec2 uv, float columns, float rows) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1.0;

	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);

			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}

	return minimum_dist;
}

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
	//float n = worley(UV * 2.0, 3.0, 5.0);
	vec2 warp = vec2(
    fbm(UV * warp_factor),
    fbm(UV * warp_factor + vec2(5.2))
	);
	float f = fbm(UV + 0.5 * warp);
	//float f = fbm(UV);
	//float combined = mix(f, n, 0.2);
	COLOR = vec4(vec3(f), 1.0);
	//COLOR = vec4(vec3(f), 1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
