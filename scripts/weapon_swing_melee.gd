extends Node2D


@onready var animation_player = $AnimationPlayer
@export var damage:float


#do damage when HitCollision2D collider connects
func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(damage)
		
#start swinging when the player is in SwingCollision2D box
func _on_swing_detector_body_entered(body):
	if body.is_in_group("Player"):
		animation_player.play("swing")
		
#stop swinging when the player is out of SwingCollision2D box
func _on_swing_detector_body_exited(body):
	if body.is_in_group("Player"):
		#creates a timer with a length equal to the remaining time in the animation currently playing
		await get_tree().create_timer((animation_player.current_animation_length - animation_player.current_animation_position)).timeout
		animation_player.play("RESET")



