extends Weapon

signal bullets_updated(current_magazine, currnet_total_bullets)

@export var projectile_scn = preload("res://scenes/projectile/projectile_B.tscn")
@export var max_capacity:int = 12
@export var total_bullets: int = 36:
	set(new_value):
		bullets_updated.emit(magazine, new_value)
		total_bullets = new_value

@onready var animation_player = $AnimationPlayer
@onready var projectile_position = $ProjectilePosition
@onready var reload_timer = $ReloadTimer
@onready var reload_sound = $ReloadSound
@onready var push_magazine_audio = $PushMagazineAudio
@onready var empty_magazine_audio = $EmptyMagazineAudio

var projectile_velocity:float = 1000.0

var magazine: int = max_capacity:
	set(new_value):
		bullets_updated.emit(new_value, total_bullets)
		magazine = new_value

var screen_shake_magnitude:int = 100:
	set(new_value):
		screen_shake_magnitude = clamp(new_value, 150, 250)


func attack():
	
	if magazine != 0 and reload_timer.is_stopped():
		animation_player.play("Shoot")

	elif total_bullets == 0:
		empty_magazine_audio.play()


func shoot():
	var projectile = projectile_scn.instantiate()
	projectile.damage = damage
	projectile.global_position = projectile_position.global_position
	projectile.velocity = global_position.direction_to(get_global_mouse_position()) * projectile_velocity
	#projectile.rotation = get_parent().rotation - get_parent().get_parent().gravity_direction.angle()
	#projectile.rotation += Vector2.UP.angle() if get_parent().get_parent().gravity_direction.x else Vector2.DOWN.angle() 
	get_tree().get_root().get_child(0).add_child(projectile)
	magazine -= 1
#
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(screen_shake_magnitude, 0.1)
	screen_shake_magnitude += 50
		
	if magazine == 0:
		if animation_player.is_playing():
			animation_player.stop()
		animation_player.play("Idle")

		if total_bullets > 0:
			reload_timer.start()


func _ready():
	total_bullets = total_bullets
	magazine = max_capacity


func _input(event):
	if event.is_action_released("ui_attack"):
		animation_player.play("Idle")
		screen_shake_magnitude = 100
	
	elif event.is_action_pressed("ui_reload") and (magazine < max_capacity):
		reload_timer.start()


func _on_reload_timer_timeout():
	push_magazine_audio.play()


func _on_push_magazine_audio_finished():
	reload_sound.play()


func _on_reload_sound_finished():
	var leftover = magazine
	magazine = max_capacity if total_bullets >= (max_capacity - leftover) else total_bullets
	total_bullets -= (magazine - leftover)
