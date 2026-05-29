extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("selectable")
	pass # Replace with function body.

func apply_genome(g: Genome):
	var mat = $Sprite2D.material as ShaderMaterial
	mat.set_shader_parameter("octaves", g.octaves)
	mat.set_shader_parameter("amplitude", g.amplitude)
	mat.set_shader_parameter("frequency", g.frequency)
	mat.set_shader_parameter("warp_factor", g.warp_factor)
	
func set_octaves(value: int):
	var rect = $Sprite2D
	rect.material = rect.material.duplicate()
	var mat = rect.material as ShaderMaterial
	mat.set_shader_parameter("octaves", value)
	
func set_amplitude(value: float):
	var rect = $Sprite2D
	rect.material = rect.material.duplicate()
	var mat = rect.material as ShaderMaterial
	mat.set_shader_parameter("amplitude", value)	

func set_frequency(value: float):
	var rect = $Sprite2D
	rect.material = rect.material.duplicate()
	var mat = rect.material as ShaderMaterial
	mat.set_shader_parameter("frequency", value)	


func set_warp_factor(value: float):
	var rect = $Sprite2D
	rect.material = rect.material.duplicate()
	var mat = rect.material as ShaderMaterial
	mat.set_shader_parameter("warp_factor", value)	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
