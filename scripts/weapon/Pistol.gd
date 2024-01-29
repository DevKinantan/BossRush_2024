extends Weapon

@export var projectile_scn = preload("res://scenes/projectile/projectile_A.tscn")
var max_capacity:int = 6
var magazine: int = 6
@export var total_bullets: int = 15

@onready var animation_player = $AnimationPlayer
@onready var reload_timer = $ReloadTimer
@onready var reload_sounds = $ReloadSounds
@onready var push_magazine_audio = $PushMagazineAudio
@onready var empty_magazine_audio = $EmptyMagazineAudio

var projectile_velocity:float = 1000.0


func attack():
	if magazine != 0 and reload_timer.is_stopped():
		if not animation_player.is_playing():
			animation_player.play("Shoot")
	
	elif magazine == 0 and total_bullets > 0:
		reload_sounds.play_random_audio()
		reload_timer.start()

	elif total_bullets == 0:
		empty_magazine_audio.play()


func shoot():
	var projectile = projectile_scn.instantiate()
	projectile.damage = damage
	projectile.global_position = global_position
	projectile.velocity = global_position.direction_to(get_global_mouse_position()) * projectile_velocity
	#projectile.rotation = get_parent().rotation - get_parent().get_parent().gravity_direction.angle()
	#projectile.rotation += Vector2.UP.angle() if get_parent().get_parent().gravity_direction.x else Vector2.DOWN.angle() 
	get_tree().get_root().get_child(0).add_child(projectile)
	magazine -= 1

	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(200, 0.1)
		
	if magazine == 0 and total_bullets > 0:
		reload_sounds.play_random_audio()
		reload_timer.start()


func _on_reload_timer_timeout():
	magazine += 1
	total_bullets -= 1
	
	if (magazine < max_capacity) and (total_bullets > 0):
		reload_sounds.play_random_audio()
		reload_timer.start()
	
	elif (magazine == max_capacity) or (total_bullets == 0):
		push_magazine_audio.play()
