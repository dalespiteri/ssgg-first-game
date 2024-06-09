extends Area2D
@onready var next_level = $"."
@onready var collision_shape_2d = $CollisionShape2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file.bind("res://scenes/menus/end_menu.tscn").call_deferred()
		
