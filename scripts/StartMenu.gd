extends Control

@onready var animation_player := $AnimationPlayer

var level_tutorial := "res://scenes/levels/tutorial.tscn"


func clicked_end():
	get_tree().change_scene_to_file(level_tutorial)


func _input(event):
	if event.is_action_pressed("ui_attack"):
		animation_player.play("Clicked")
