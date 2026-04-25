extends Area2D

signal selected(node)

func _input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("click"):
		emit_signal("selected", get_parent())
		print("click")
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
