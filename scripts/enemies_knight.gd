extends CharacterBody2D

var player = null
var player_chase = false

@export var SPEED:float = 300.0
@export var JUMP_VELOCITY:float = -400.0
@onready var sprite_2d = $Sprite2D
@onready var a_p = $AnimationPlayer
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var direction = 0
	if player_chase:
		position += (player.position - position)/SPEED*3
		if (player.position.x - position.x) > 0:
			direction = 1
			sprite_2d.flip_h = false
		else:
			direction = -1
			sprite_2d.flip_h = true
	else:
		direction = 0

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
	update_animations(direction)


func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		player_chase = false
		
func update_animations(player_chase):
	if is_on_floor():
		if player_chase:
			a_p.play("run")
		else:
			a_p.play("idle")
	else:
		if velocity.y < 0:
			a_p.play("jump")
		elif velocity.y > 0:
			a_p.play("fall")
