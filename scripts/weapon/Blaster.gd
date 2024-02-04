extends Weapon

signal energy_updated(current_energy)

@export var projectile_scn = preload("res://scenes/projectile/projectile_A.tscn")

@onready var animation_player := $AnimationPlayer
@onready var reload_timer := $ReloadTimer
@onready var projectile_exit := $ProjectileExit

var projectile_velocity:float = 1000.0
var max_energy := 15.0
var energy := max_energy:
	set(new_value):
		var energy_percentage = (new_value / max_energy) * 100
		energy_updated.emit(energy_percentage)
		energy = clamp(new_value, 0, max_energy)


func attack():
	if energy >= max_energy and reload_timer.is_stopped():
		animation_player.play("Shoot")


func shoot():
	var projectile = projectile_scn.instantiate()
	projectile.damage = damage
	projectile.global_position = projectile_exit.global_position
	projectile.velocity = global_position.direction_to(get_global_mouse_position()) * projectile_velocity
	get_tree().current_scene.add_child(projectile)

	energy = 0
	animation_player.play("Recharge")
	reload_timer.start()


func _on_reload_timer_timeout():
	energy += 1
	if energy < max_energy:
		reload_timer.start()
