extends Area2D


func _on_body_entered(body):
	if body is Player:
		var tween = create_tween()
		tween.tween_property($PointLight2D, "energy" , 0.8, 0.5)


func _on_body_exited(body):
	if body is Player:
		var tween = create_tween()
		tween.tween_property($PointLight2D, "energy" , 0.0, 0.5)
