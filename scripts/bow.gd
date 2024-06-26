extends Sprite2D
@export var direction:float

func _physics_process(delta):
	const ARROW = preload("res://scenes/arrow.tscn")
	var new_arrow = ARROW.instantiate()
	new_arrow.direction = direction
	if Input.is_action_just_pressed("attack"):
		add_child(new_arrow)
