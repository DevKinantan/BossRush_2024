extends Area2D

@onready var e_button = $E

var player_in_area = false
var level_1_scn := "res://scenes/levels/level1.tscn"


func _on_body_entered(body):
	if body is Player:
		e_button.visible = true
		player_in_area = true


func _on_body_exited(body):
	if body is Player:
		e_button.visible = false
		player_in_area = false


func _input(event):
	if event.is_action_pressed("ui_interact") and player_in_area:
		get_tree().change_scene_to_file(level_1_scn)
