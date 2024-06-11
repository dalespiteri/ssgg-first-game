extends CharacterBody2D

const BASE_SPEED = 175.0
const BASE_JUMP_VELOCITY = -250.0
const DASH_SPEED = 800
const DASH_COOLDOWN = 2
const BASE_SIZE = 1
const SHRINK_SIZE = 0.5
var current_size = 1
var current_speed = BASE_SPEED * current_size
var current_jump_velocity = BASE_JUMP_VELOCITY * current_size

var jumps_remaining = 2
var dash_available = true
var is_dashing = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var a_p = $AnimationPlayer
@onready var sprite_2d = $Sprite2d
@onready var coyote_time = $Timers/CoyoteTime
@onready var collision_shape_2d = $CollisionShape2D
@onready var shrink = $SFX/Shrink
@onready var grow = $SFX/Grow
@onready var dash = $Timers/Dash
@onready var dash_cooldown = $Timers/DashCooldown
@onready var cooldown_bar = $CooldownBar

func _physics_process(delta):
	
	if Input.is_action_just_pressed("toggle_size"):
		toggle_size()
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	var was_on_floor = is_on_floor()
	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		if (is_on_floor() || !coyote_time.is_stopped()):
			jumps_remaining = 1
		else:
			jumps_remaining = 0
		velocity.y = current_jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
	
	if direction < 0:
		sprite_2d.flip_h = true
	elif direction > 0:
		sprite_2d.flip_h = false
	
	if is_on_floor():
		jumps_remaining = 2
	
	if Input.is_action_just_pressed("dash") && dash_available && direction != 0:
		trigger_dash()
		
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		coyote_time.start()
		
	update_animations(direction)

func toggle_size():
	var colShape = CapsuleShape2D.new()
	colShape.radius = 2.0 if current_size == 1 else 4.0
	colShape.height = 7.5 if current_size == 1 else 15.0
	collision_shape_2d.set_shape(colShape)
	collision_shape_2d.position = Vector2(0, -10) if current_size == 1 else Vector2(0, -8)
	var tween = create_tween()
	if current_size == 1:
		shrink.play()
		tween.tween_property(sprite_2d, "scale", Vector2(SHRINK_SIZE, SHRINK_SIZE), 0.1)
	else:
		grow.play()
		tween.tween_property(sprite_2d, "scale", Vector2(BASE_SIZE, BASE_SIZE), 0.1)
	tween.connect("finished", on_tween_finished)

func on_tween_finished():
	if current_size == BASE_SIZE:
		current_size = SHRINK_SIZE
	else:
		current_size = BASE_SIZE
	set_speed_based_on_size()

func set_speed_based_on_size():
	current_speed = BASE_SPEED * current_size
	current_jump_velocity = BASE_JUMP_VELOCITY * current_size

func update_animations(direction: int):
	if is_on_floor():
		if direction == 0:
			a_p.play("idle")
		else:
			a_p.play("run")
	else:
		if velocity.y < 0:
			a_p.play("jump")
		elif velocity.y > 0:
			a_p.play("fall")

func trigger_dash():
	dash.start()
	current_speed = DASH_SPEED
	is_dashing = true
	dash_available = false
	dash_cooldown.start()
	cooldown_bar.visible = true
	var tween = create_tween()
	tween.tween_property(cooldown_bar.get_node("Meter"), "size", Vector2(0, 1), DASH_COOLDOWN)
	tween.connect("finished", reset_cooldown_bar)

func _on_dash_timeout():
	set_speed_based_on_size()
	is_dashing = false

func _on_dash_cooldown_timeout():
	dash_available = true
	cooldown_bar.visible = false
	cooldown_bar.get_node("Meter").size = Vector2(10, 1)
	
func reset_cooldown_bar():
	cooldown_bar.get_node("Meter").size = Vector2(10, 1)
