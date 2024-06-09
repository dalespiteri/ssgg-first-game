extends CharacterBody2D

const SPEED = 175.0
const JUMP_VELOCITY = -250.0

var jumps_remaining = 2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#@onready var animated_sprite = $AnimatedSprite2D
@onready var a_p = $AnimationPlayer
@onready var sprite_2d = $Sprite2d

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		if is_on_floor():
			jumps_remaining = 1
		else:
			jumps_remaining = 0
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction < 0:
		sprite_2d.flip_h = true
	elif direction > 0:
		sprite_2d.flip_h = false
	
	if is_on_floor():
		jumps_remaining = 2
	
	move_and_slide()
	update_animations(direction)
	
func update_animations(direction: int):
	if is_on_floor():
		if direction == 0:
			a_p.play("idle")
		else:
			a_p.play("run")
	else:
		a_p.play("jump")
