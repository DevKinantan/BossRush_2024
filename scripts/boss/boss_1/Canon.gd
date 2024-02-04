extends Node2D

signal canon_ready
signal canon_fired
signal canon_move_back


@onready var animation_player := $AnimationPlayer
@onready var cooldown_timer := $Timer

@export var fire_per_cycle := 2

var total_fired := 0


func shake_camera(magnitude:int = 800, duration:float = 0.5):
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(magnitude, duration)


func fire():
	animation_player.play("MoveUp")


func move_up_end():
	canon_ready.emit()


func fire_end():
	canon_fired.emit()

	total_fired += 1
	if total_fired < fire_per_cycle:
		cooldown_timer.start()
	
	elif total_fired >= fire_per_cycle:
		animation_player.play("MoveBack")


func move_back_end():
	canon_move_back.emit()
	total_fired = 0


func _on_canon_ready():
	animation_player.play("Fire")
