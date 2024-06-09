class_name EndMenu
extends Control

@onready var restart_button = $MarginContainer/HBoxContainer/VBoxContainer/Restart as Button

@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/Quit as Button
@onready var start_level = preload("res://scenes/game.tscn") as PackedScene

func _ready():
	restart_button.button_down.connect(on_restart_pressed)
	quit_button.button_down.connect(on_quit_pressed)

func on_restart_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
		
func on_quit_pressed() -> void:
	get_tree().quit()
