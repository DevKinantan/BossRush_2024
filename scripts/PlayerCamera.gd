extends Camera2D


@export var offset_power: float = 0.2
@export var zoom_step: float = 0.1
@export var zoom_max: float = 1.3
@export var zoom_min: float = 0.7

@onready var shake_timer: Timer = $ShakeTimer

var player: Player

var shaking: bool = false
var shake_magnitude = 0


func shake(magnitude: int = 1, duration: float = 0.5):
	shaking = true
	shake_magnitude = magnitude
	shake_timer.start(duration)


func _ready():
	player = get_parent()


func _process(delta):
	if shaking:
		offset += Vector2(randi_range(-shake_magnitude, shake_magnitude), randi_range(-shake_magnitude, shake_magnitude)) * delta


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
	
	if event.is_action_pressed("ui_interact"):
		shake(50, 0.2)


func _on_shake_timer_timeout():
	shaking = false
	var base_offset = (get_global_mouse_position() - player.global_position) * offset_power
	var tween = create_tween()
	tween.tween_property(self, "offset", base_offset, 0.1)
