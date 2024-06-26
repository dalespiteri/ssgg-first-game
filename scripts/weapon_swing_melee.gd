extends Node2D


@onready var animation_player = $AnimationPlayer



func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		print("hit")

func _on_swing_detector_body_entered(body):
	if body.is_in_group("Player"):
		animation_player.play("swing")

func _on_swing_detector_body_exited(body):
	if body.is_in_group("Player"):
		animation_player.play("RESET")
