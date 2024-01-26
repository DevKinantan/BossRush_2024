extends Node2D

signal laser_start
signal laser_stop

@onready var animation_player = $AnimationPlayer
@onready var laser = $Laser


func shoot_laser():
	animation_player.play("Preshoot")


func stop_shoot_laser():
	animation_player.play("Postshoot")


func preshoot_end():
	laser.set_is_casting(true)
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("Shoot")
	emit_signal("laser_start")


func postshoot_end():
	laser.set_is_casting(false)
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("Idle")
	emit_signal("laser_stop")
