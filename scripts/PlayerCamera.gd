extends Camera2D


@export var offset_power: float = 0.2
@export var zoom_step: float = 0.1
@export var zoom_max: float = 1.3
@export var zoom_min: float = 0.7

var player: Player


func _ready():
	player = get_parent()


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos_from_player = get_global_mouse_position() - player.global_position
		offset = mouse_pos_from_player * offset_power
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("ui_zoom_in"):
			if zoom.x < zoom_max:
				zoom += Vector2(zoom_step, zoom_step)
		elif event.is_action_pressed("ui_zoom_out"):
			if zoom.x > zoom_min:
				zoom -= Vector2(zoom_step, zoom_step)
