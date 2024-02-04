extends RigidBody2D

@onready var fall_sound := $FallSound


func _on_body_entered(_body):
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(400, 0.5)

	if not fall_sound.playing:
		fall_sound.play()
