extends Weapon

@export var projectile_scn = preload("res://scenes/projectile/projectile_A.tscn")
@onready var animation_player = $AnimationPlayer
var projectile_velocity:float = 1000.0


func attack():
	if not animation_player.is_playing():
		animation_player.play("Shoot")


func shoot():
	var projectile = projectile_scn.instantiate()
	projectile.global_position = global_position
	projectile.linear_velocity = global_position.direction_to(get_global_mouse_position()) * projectile_velocity
	projectile.rotation = get_parent().rotation - get_parent().get_parent().gravity_direction.angle()
	projectile.rotation += Vector2.UP.angle() if get_parent().get_parent().gravity_direction.x else Vector2.DOWN.angle() 
	get_tree().get_root().get_child(0).add_child(projectile)
	
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(200, 0.1)
