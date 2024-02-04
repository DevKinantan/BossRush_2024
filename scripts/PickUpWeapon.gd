extends Node2D

@onready var label = $Label

@export var weapon_scn = preload("res://scenes/weapon/claymore.tscn")

var player: Player


func _ready():
	label.visible = false


func _input(event):
	if event.is_action_pressed("ui_interact") and player and weapon_scn:
		var player_weapon_pivot = player.get_node("WeaponPivot")
		for player_weapon in player_weapon_pivot.get_children():
			player_weapon.queue_free()

		var weapon = weapon_scn.instantiate()
		player_weapon_pivot.add_child(weapon)
		player.weapon = weapon

		queue_free()


func _on_area_2d_body_entered(body):
	if body is Player: 
		player = body
		label.visible = true


func _on_area_2d_body_exited(body):
	if body is Player: 
		player = null
		label.visible = false
