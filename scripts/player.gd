extends CharacterBody2D

var current_size = 1
const BASE_SPEED = 175.0
const BASE_JUMP_VELOCITY = -250.0
const DASH_SPEED = 4.0
var current_speed = BASE_SPEED * current_size
var current_jump_velocity = BASE_JUMP_VELOCITY * current_size
var is_dashing = false
var dash_direction = 1
var is_dash_on_cooldown = false

var jumps_remaining = 2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var a_p = $AnimationPlayer
@onready var sprite_2d = $Sprite2d
@onready var coyote_time = $CoyoteTime
@onready var collision_shape_2d = $CollisionShape2D
@onready var shrink = $SFX/Shrink
@onready var grow = $SFX/Grow
@onready var dash_timer = $"../Timers/DashTimer"
@onready var cooldown_timer = $"../Timers/CooldownTimer"
@onready var cooldown_bar = $CooldownBar

signal spike_death
signal pause_pressed

func _physics_process(delta):
	
	if Input.is_action_just_pressed("toggle_size"):
		toggle_size()
		
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
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
	
	if direction != 0:
		dash_direction = direction
	
	if Input.is_action_just_pressed("dash") && not is_dash_on_cooldown:
		cooldown_bar.visible = true
		var tween = get_tree().create_tween()
		tween.tween_property(cooldown_bar.get_node('Bar'), 'size', Vector2(0, 1), 2)
		tween.connect("finished", on_cooldown_finished)
		dash_timer.start()
		cooldown_timer.start()
		is_dashing = true
		is_dash_on_cooldown = true
	
	if is_dashing:
		velocity.x = dash_direction * current_speed * DASH_SPEED
	else:
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
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		coyote_time.start()
		
	update_animations(direction)
	
	#detect if the player has collided with a hazard
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.is_in_group("Hazard"):
			spike_death.emit()
			
	if Input.is_action_just_pressed("pause"):
		pause_pressed.emit()
			

func toggle_size():
	var colShape = CapsuleShape2D.new()
	colShape.radius = 2.0 if current_size == 1 else 4.0
	colShape.height = 7.5 if current_size == 1 else 15.0
	collision_shape_2d.set_shape(colShape)
	collision_shape_2d.position = Vector2(0, -10) if current_size == 1 else Vector2(0, -8)
	var tween = create_tween()
	if current_size == 1:
		shrink.play()
		tween.tween_property(sprite_2d, "scale", Vector2(0.5, 0.5), 0.1)
	else:
		grow.play()
		tween.tween_property(sprite_2d, "scale", Vector2(1, 1), 0.1)
	tween.connect("finished", on_tween_finished)

func on_tween_finished():
	if current_size == 1:
		current_size = 0.75
	else:
		current_size = 1
	set_current_movement()

func set_current_movement():
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

func _on_dash_timer_timeout():
	print('dash complete')
	is_dashing = false

func _on_cooldown_timer_timeout():
	is_dash_on_cooldown = false
	cooldown_bar.visible = false
	
func on_cooldown_finished():
	cooldown_bar.get_node('Bar').size = Vector2(14, 1)
	
