extends Area2D

@export var speed:float
@export var direction:float
@export var damage:float
@export var range:float

var travelled_distance = 0

func _physics_process(delta):
	var arrow_direction
	if direction < 0:
		arrow_direction = Vector2.LEFT
	else:
		arrow_direction = Vector2.RIGHT
	global_position += speed * arrow_direction * delta
	travelled_distance += speed * delta
	if travelled_distance > range:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage(damage)
