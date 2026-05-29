extends Node

var tex = preload("res://tex_obj.tscn")

var first_genoms = []

var input_texture := preload("res://textures/Sprite-0004.png")

var current_gen_images: Array[Image] = []



func _ready() -> void:
	print(ProjectSettings.globalize_path("user://output_textures"))

	init()
	await start_proccess()
	spawn()
	
	await export_generation_images(tex, generations)

	for tex in get_tree().get_nodes_in_group("selectable"):
		var area = tex.get_node("Area2D")
		area.selected.connect(_on_tex_select)


func spawn():
	var x_spacing = 100
	var y_spacing = 100

	for gen_index in range(generations.size()):
		var gen = generations[gen_index]

		for i in range(gen.size()):
			var instance = tex.instantiate()

			var x = 100 + i * x_spacing
			var y = 100 + gen_index * y_spacing

			instance.position = Vector2(x, y)
			instance.scale = Vector2(4, 4)

			var g = gen[i]
			instance.set_meta("genome", g)
			instance.set_octaves(g.octaves)
			instance.set_amplitude(g.amplitude)
			instance.set_frequency(g.frequency)
			instance.set_warp_factor(g.warp_factor)
			#instance.apply_genome(g);

			add_child(instance)


func init():
	for i in range(10):
		var o: int = randi_range(1, 6)
		var a: float = randf_range(.5, 2.2)
		var f: float = randf_range(1.2,  2.0)
		var w: float = randf_range(2.0, 4.0)
		var g = Genome.new(o, a, f, w)
		first_genoms.append(g)

var generations = []


func start_proccess():
	var current_gen = first_genoms.duplicate()
	generations = []
	generations.append(current_gen)
	await  set_generation_images(tex, current_gen)
	var sizes = [8, 6, 4, 2]
	
	for gen_size in sizes:
		var parents = pick_parents_2(current_gen)
		
		var next_gen = []
		while next_gen.size() < gen_size:
			var p1 = parents[randi() % parents.size()]
			var p2 = parents[randi() % parents.size()]
			while p1 == p2:
				p2 = parents[randi() % parents.size()]
			var child = crossover(p1, p2)
			child = mutate(child)
			next_gen.append(child)
		current_gen = next_gen
		generations.append(current_gen)
		await set_generation_images(tex, current_gen)
		
	pass

func pick_parents_2(gen: Array, count := 4):
	var scored = []

	for i in range(gen.size()):
		var genome = gen[i]
		var img = current_gen_images[i]

		var fitness = compute_fitness(img)

		scored.append({
			"genome": genome,
			"fitness": fitness
		})

	scored.sort_custom(func(a, b):
		return a["fitness"] > b["fitness"]
	)

	var parents = []

	for i in range(min(count, scored.size())):
		parents.append(scored[i]["genome"])

	return parents
	
func pick_parents(gen: Array):
	var scored = []

	for i in range(gen.size()):
		var genome = gen[i]
		var img = current_gen_images[i]

		var fitness = compute_fitness(img)

		genome.fitness = fitness
		scored.append({
			"genome": genome,
			"fitness": fitness
		})

	scored.sort_custom(func(a, b):
		return a["fitness"] > b["fitness"]
	)

	return [
		scored[0]["genome"],
		scored[1]["genome"]
	]

func mutate(genome, mutation_rate := 0.1):
	if randf() < mutation_rate:
		genome.octaves += randi_range(-1, 1)
		genome.octaves = clamp(genome.octaves, 1, 6)

	if randf() < mutation_rate:
		genome.amplitude += randf_range(-0.3, 0.3)
		genome.amplitude = clamp(genome.amplitude, 1.2, 2.0)

	if randf() < mutation_rate:
		genome.frequency += randf_range(-1.0, 1.0)
		genome.frequency = clamp(genome.frequency, 2.0, 4.0)
		
	if randf() < mutation_rate:
		genome.warp_factor += randf_range(-1.0, 1.2)
		genome.warp_factor = clamp(genome.warp_factor, 2.0, 4.0)

	return genome


func crossover(parent1, parent2):
	var t_o = randf()
	var t_a = randf()
	var t_f = randf()
	var w_f = randf()

	var o = int(round(lerp(parent1.octaves, parent2.octaves, t_o)))
	var a = lerp(parent1.amplitude, parent2.amplitude, t_a)
	var f = lerp(parent1.frequency, parent2.frequency, t_f)
	var w = lerp(parent1.warp_factor, parent2.warp_factor, w_f)
	

	var child = Genome.new(o, a, f, w)
	child.parent1 = parent1
	child.parent2 = parent2
	
	return child


func _on_tex_select(node):
	var genome = node.get_meta("genome", null)

	if genome == null:
		print("No genome found on node")
		return
	print("+----------------- Selected:", node.name, "------------------+")
	
	print("Octaves:", genome.octaves)
	print("Amplitude:", genome.amplitude)
	print("Frequency:", genome.frequency)
	
	print("Fitness:", genome.fitness)

	if genome.parent1 and genome.parent2:
		print("Parents:")
		print("  Parent1 -> Octaves:", genome.parent1.octaves,
			  " Amp:", genome.parent1.amplitude,
			  " Freq:", genome.parent1.frequency,
			  " Fitness:", genome.parent1.fitness)

		print("  Parent2 -> Octaves:", genome.parent2.octaves,
			  " Amp:", genome.parent2.amplitude,
			  " Freq:", genome.parent2.frequency,
			  " Fitness:", genome.parent2.fitness)
	else:
		print("Parents: None (original generation)")
	print("+-------------------------------------------------------+")

func set_generation_images(tex_scene: PackedScene, gen: Array):
	current_gen_images.clear()
	
	var vp := SubViewport.new()
	vp.size = Vector2i(256, 256)
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.transparent_bg = true
	add_child(vp)
	
	for g in gen:
		for c in vp.get_children():
				c.queue_free()
		await get_tree().process_frame
		
		var instance = tex_scene.instantiate()
		vp.add_child(instance)
		
		instance.set_octaves(g.octaves)
		instance.set_amplitude(g.amplitude)
		instance.set_frequency(g.frequency)
		instance.set_warp_factor(g.warp_factor)
		
		instance.position = Vector2(128, 128)
		
		await get_tree().process_frame
		await get_tree().process_frame
		var img: Image = vp.get_texture().get_image()
		
		current_gen_images.append(img)
	
func export_generation_images(tex_scene: PackedScene, generations: Array) -> Array:
	var images: Array[Image] = []

	var vp := SubViewport.new()
	vp.size = Vector2i(256, 256)
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.transparent_bg = true
	add_child(vp)

	for gen_index in range(generations.size()):
		for i in range(generations[gen_index].size()):

			for c in vp.get_children():
				c.queue_free()

			await get_tree().process_frame

			var instance = tex_scene.instantiate()
			vp.add_child(instance)

			var g = generations[gen_index][i]
			instance.set_octaves(g.octaves)
			instance.set_amplitude(g.amplitude)
			instance.set_frequency(g.frequency)
			instance.set_warp_factor(g.warp_factor)

			instance.position = Vector2(128, 128)
			#instance.scale = Vector2(4, 4)
			
			await get_tree().process_frame
			await get_tree().process_frame
			
			var img: Image = vp.get_texture().get_image()
			images.append(img)

			img.save_png("user://gen_%d_%d.png" % [gen_index, i])

	vp.queue_free()
	return images




###----------------------------FITNESS----------------------------###

func compute_fitness(i: Image) -> float:
	var against = input_texture.get_image() 
	var h = histogram_similarity(against, i)
	var f = frequency_similarity(against, i)
	var e = edge_similarity(against, i)
	var p = pixel_similarity(against, i)
	#var fit = 0.5 * h + 0.1 * f + 0.4 * e
	var fit = 0.3 * h + 0.1 * f + 0.4 * e + 0.2 * p
	
	return fit
	
func edge_strength(img: Image, x: int, y: int) -> float:
	var w = img.get_width()
	var h = img.get_height()

	x = clamp(x, 1, w - 2)
	y = clamp(y, 1, h - 2)
	
	var gx = img.get_pixel(x + 1, y).r - img.get_pixel(x - 1, y).r

	var gy = img.get_pixel(x, y + 1).r - img.get_pixel(x, y - 1).r

	return sqrt(gx * gx + gy * gy)

func edge_similarity(img1: Image, img2: Image) -> float:
	var w = min(img1.get_width(), img2.get_width())
	var h = min(img1.get_height(), img2.get_height())

	var error = 0.0

	for x in range(1, w - 1):
		for y in range(1, h - 1):

			var e1 = edge_strength(img1, x, y)
			var e2 = edge_strength(img2, x, y)

			var diff = e1 - e2
			error += diff * diff

	return 1.0 / (1.0 + error)	

func compute_histogram(image: Image, bins := 64):
	var hist = []
	hist.resize(bins)

	for i in range(bins):
		hist[i] = 0.0

	var total = image.get_width() * image.get_height()

	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var v = image.get_pixel(x, y).r
			var idx = int(v * (bins - 1))
			hist[idx] += 1.0

	for i in range(bins):
		hist[i] /= total

	return hist



func histogram_similarity(img1: Image, img2: Image):
	var h1 = compute_histogram(img1)
	var h2 = compute_histogram(img2)

	var error = 0.0

	for i in range(h1.size()):
		var diff = h1[i] - h2[i]
		error += diff * diff

	return 1.0 / (1.0 + error)


func compute_frequency_signature(image: Image, step := 16) -> Array:
	var w = image.get_width()
	var h = image.get_height()

	var freq = []

	for x in range(0, w, step):
		for y in range(0, h, step):
			var v = image.get_pixel(x, y).r
			freq.append(v)

	return freq


func frequency_similarity(img1: Image, img2: Image) -> float:
	var f1 = compute_frequency_signature(img1)
	var f2 = compute_frequency_signature(img2)

	var size = min(f1.size(), f2.size())

	var error = 0.0

	for i in range(size):
		var diff = f1[i] - f2[i]
		error += diff * diff

	return 1.0 / (1.0 + error)


func pixel_similarity(img1, img2):
	var error = 0.0

	for x in range(img1.get_width()):
		for y in range(img1.get_height()):
			var a = img1.get_pixel(x, y).r
			var b = img2.get_pixel(x, y).r

			error += abs(a - b)

	return 1.0 / (1.0 + error)
