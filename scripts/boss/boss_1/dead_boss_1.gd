extends RigidBody2D


func _on_body_entered(_body):
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(400, 0.5)
