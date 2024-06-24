extends CanvasLayer

@onready var title = %Title

func set_title(new_title:String):
	title.text = new_title

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_quit_pressed():
	get_tree().quit()
