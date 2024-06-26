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
		animation_player.play("RESET")
