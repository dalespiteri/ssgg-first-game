extends CharacterBody2D

@export var speed:float
@export var JUMP_VELOCITY:float
@export var flip_node : Node2D
@export var ground_detector : Area2D
@export var jump_block : Area2D
@export var landing_detector : Area2D
@export var aggro_drop_detector : Area2D

@onready var jump_cooldown = $JumpCooldown
@onready var player = null
@onready var player_chase = false
@onready var sprite_2d = $Sprite2D
@onready var a_p = $AnimationPlayer
@onready var ray_cast = $DirectionFlip/RayCast

var direction = 1
var is_jump_on_cooldown = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	#move forward on patrol
	enemy_patrol()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	update_animations()
	move_and_slide()
	





#when the sprite is patrolling, it checks if a wall is in front of it and turns around
func enemy_patrol():
	#walks forwards
	if !player_chase:	
		velocity.x = direction * speed
	elif player_chase:
		#check the angle of the player vs the enemy.  if it is between an angle trigger the jump check, but only during aggro
		var rads = position.normalized().angle_to_point(player.position.normalized()) 
		
		if rads < -1 and rads > -1.4:
			jump()

		velocity.x = direction * speed * 2
		if (player.position.x - position.x)/direction < 0 and player.is_on_floor():
				#left is negative direction, im to his left so his x is higher making (player.x - enemy.x) negative. 
			turn_around()

		#	
	if is_on_floor():
		#check if its up against a solid wall
		if ground_detector.has_overlapping_bodies() and jump_block.has_overlapping_bodies() and ray_cast.is_colliding():
			turn_around()
		#check if there is no landing if it were to jump
		elif !ground_detector.has_overlapping_bodies() and is_jump_on_cooldown and !landing_detector.has_overlapping_bodies():
			turn_around() 
		else:
			#check if its up against a jumpable wall or theres a gap in the floor it can jump
			if !ground_detector.has_overlapping_bodies() or ray_cast.is_colliding():
				enemy_jump_check()
				#check if there is no landing for the jump
			elif !landing_detector.has_overlapping_bodies():
				turn_around()



	
#checks if the player has entered the detection zone
func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_chase = true
		

func _on_aggro_dropped_detector_body_exited(body):
	if body.is_in_group("Player"):
		player_chase = false

				
			
#updates animations for the sprite
func update_animations():
	if is_on_floor():
		a_p.play("run")
	else:
		if velocity.y < 0:
			a_p.play("jump")
		elif velocity.y > 0:
			a_p.play("fall")

func enemy_jump_check():
	if is_on_floor():
		#Check if there is no ground or if the character has reached a wall and can jump over it
		if !ground_detector.has_overlapping_bodies() or (ray_cast.is_colliding()):
			if !is_jump_on_cooldown: 
				if !jump_block.has_overlapping_bodies() and landing_detector.has_overlapping_bodies():
					jump()


func _on_jump_cooldown_timeout():
	is_jump_on_cooldown = false

func jump():
	if !is_jump_on_cooldown:
		velocity.y += JUMP_VELOCITY
		jump_cooldown.start()
		is_jump_on_cooldown = true
		
func turn_around():
	if is_on_floor():
		direction *= -1
		flip_node.scale.x *= -1
		sprite_2d.flip_h = !sprite_2d.flip_h
		









