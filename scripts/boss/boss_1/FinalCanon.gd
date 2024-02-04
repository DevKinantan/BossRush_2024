extends CanvasLayer


func shake_camera(magnitude:int = 500, duration:float = 0.2):
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(magnitude, duration)
