extends CanvasLayer

@onready var menu = $Menu
var paused = false

func _on_next_level_body_entered(body):
	get_tree().paused = true
	menu.set_title('YOU FUCKING WON BITCH')
	menu.visible = true


func _on_player_spike_death():
	get_tree().paused = true
	menu.set_title('YOU FUCKING LOST BITCH')
	menu.visible = true

func _on_player_pause_pressed():
	paused = !paused
	get_tree().paused = paused
	if paused:
		menu.set_title('YOU FUCKING PAUSED BITCH')
		menu.visible = true
	else:
		menu.visible = false
