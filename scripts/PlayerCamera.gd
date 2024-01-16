extends Camera2D


@export var offset_power:float = 0.2

var player: Player


func _ready():
	player = get_parent()


func _process(_delta):
	var mouse_pos_from_player = get_global_mouse_position() - player.global_position
	offset = mouse_pos_from_player * 0.2
