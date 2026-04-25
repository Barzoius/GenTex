extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("selectable")
	pass # Replace with function body.

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
