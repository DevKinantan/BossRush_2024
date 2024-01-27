extends Sprite2D


func _ready():
	var tween := create_tween()
	tween.tween_property(self, "self_modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)


func _on_timer_timeout():
	queue_free()
