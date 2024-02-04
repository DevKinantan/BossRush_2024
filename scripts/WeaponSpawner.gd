extends Marker2D

@export var weapon_spawn_scn_list = [
	preload("res://scenes/weapon/weapon_spawn/claymore_spawn.tscn"),
	preload("res://scenes/weapon/weapon_spawn/pistol_spawn.tscn"),
	preload("res://scenes/weapon/weapon_spawn/rapier_spawn.tscn"),
	preload("res://scenes/weapon/weapon_spawn/ka2075_spawn.tscn"),
]

@onready var spawn_timer := $SpawnTimer


func spawn_weapon():
	var weapon_spawn_scn = weapon_spawn_scn_list.pick_random()
	var weapon_spawn = weapon_spawn_scn.instantiate()
	add_child(weapon_spawn)
	weapon_spawn.connect("tree_exited", _on_weapon_spawn_exit_tree)


func _ready():
	spawn_weapon()


func _on_weapon_spawn_exit_tree():
	spawn_timer.start()


func _on_spawn_timer_timeout():
	spawn_weapon()
