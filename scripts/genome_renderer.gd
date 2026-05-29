extends Node
class_name GenomeRenderer

func fract(v: Vector2) -> Vector2:
	return v - Vector2(floor(v.x), floor(v.y))
	
func random(v: Vector2) -> Vector2:
	var dot1 = v.dot(Vector2(127.1, 311.7))
	var dot2 = v.dot(Vector2(269.5, 183.3))

	var r = Vector2(
		sin(dot1),
		sin(dot2)
	) * 43758.5453
	return r - Vector2(floor(r.x), floor(r.y))
	

func noise(uv: Vector2) -> float:
	var uv_index = Vector2(floor(uv.x), floor(uv.y))
	var uv_fract = uv - uv_index

	var blur = Vector2(
		smoothstep(0.0, 1.0, uv_fract.x),
		smoothstep(0.0, 1.0, uv_fract.y)
	)

	var a = random(uv_index + Vector2(0,0)).dot(uv_fract - Vector2(0,0))
	var b = random(uv_index + Vector2(1,0)).dot(uv_fract - Vector2(1,0))
	var c = random(uv_index + Vector2(0,1)).dot(uv_fract - Vector2(0,1))
	var d = random(uv_index + Vector2(1,1)).dot(uv_fract - Vector2(1,1))

	var i1 = lerp(a, b, blur.x)
	var i2 = lerp(c, d, blur.x)

	return lerp(i1, i2, blur.y) + 0.5

func fbm(genome: Genome, uv: Vector2) -> float:
	var amp = genome.amplitude
	var freq = genome.frequency

	var value = 0.0
	var amp_sum = 0.0

	for i in range(genome.octaves):
		value += amp * noise(uv * freq)
		amp_sum += amp

		amp *= 0.5
		freq *= 2.0

	return value / max(amp_sum, 0.0001)
	
	
func render_genome_to_image(genome: Genome, size := 256) -> Image:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in range(size):
		for x in range(size):
			var uv = Vector2(x, y) / float(size)

			var warp = Vector2(
				fbm(genome, uv * genome.warp_factor),
				fbm(genome, uv * genome.warp_factor + Vector2(5.2, 0.0))
			)

			var f = fbm(genome, uv + 0.5 * warp)

			img.set_pixel(x, y, Color(f, f, f, 1.0))

	return img
