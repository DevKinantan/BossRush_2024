extends Camera2D


const Y_OFFSET = 100
const X_OFFSET = 100


func _on_player_gravity_direction_changed(gravity_direction):
	#return
	var tween = create_tween()
	if gravity_direction == Vector2.DOWN or gravity_direction == Vector2.UP:
		tween.tween_property(self, "offset", Vector2(0, Y_OFFSET * -gravity_direction.y), 0.5)
	
	if gravity_direction == Vector2.LEFT or gravity_direction == Vector2.RIGHT:
		tween.tween_property(self, "offset", Vector2(X_OFFSET * -gravity_direction.x, 0), 0.5)
