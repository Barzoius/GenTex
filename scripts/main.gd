extends Node

var tex = preload("res://tex_obj.tscn")

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

			add_child(instance)
		
		
var first_genoms = []

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
	var sizes = [8, 6, 4, 2]
	
	for gen_size in sizes:
		var parents = pick_parents(current_gen)
		
		var next_gen = []
		while next_gen.size() < gen_size:
			var p1 = parents[0]
			var p2 = parents[1]
			var child = crossover(p1, p2)
			child = mutate(child)
			next_gen.append(child)
		current_gen = next_gen
		generations.append(current_gen)
	pass

func pick_parents(gen: Array):
	var options = gen.duplicate()
	options.shuffle()
	return options.slice(0, 2)
	
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
		genome.warp_factor = clamp(genome.frequency, 2.0, 4.0)

	return genome


func crossover(parent1, parent2):
	var t_o = randf()
	var t_a = randf()
	var t_f = randf()
	var w_f = randf()

	var o = int(round(lerp(parent1.octaves, parent2.octaves, t_o)))
	var a = lerp(parent1.amplitude, parent2.amplitude, t_a)
	var f = lerp(parent1.frequency, parent2.frequency, t_f)
	var w = lerp(parent1.warp_factor, parent2.warp_factor, t_f)
	

	var child = Genome.new(o, a, f, w)
	child.parent1 = parent1
	child.parent2 = parent2
	
	return child


func _ready() -> void:
	init()
	start_proccess()
	spawn()
	for tex in get_tree().get_nodes_in_group("selectable"):
		var area = tex.get_node("Area2D")
		area.selected.connect(_on_tex_select)



func _on_tex_select(node):

	
	var genome = node.get_meta("genome", null)

	if genome == null:
		print("No genome found on node")
		return
	print("+----------------- Selected:", node.name, "------------------+")

	print("Octaves:", genome.octaves)
	print("Amplitude:", genome.amplitude)
	print("Frequency:", genome.frequency)

	if genome.parent1 and genome.parent2:
		print("Parents:")
		print("  Parent1 -> Octaves:", genome.parent1.octaves,
			  " Amp:", genome.parent1.amplitude,
			  " Freq:", genome.parent1.frequency)

		print("  Parent2 -> Octaves:", genome.parent2.octaves,
			  " Amp:", genome.parent2.amplitude,
			  " Freq:", genome.parent2.frequency)
	else:
		print("Parents: None (original generation)")
	print("+-------------------------------------------------------+")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
