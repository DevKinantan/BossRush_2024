extends Node2D


@export var offset_power: float = 0.1

var half_content_scale_size: Vector2
var base_position: Vector2


func get_viewport_mouse_position():
	return get_viewport().get_mouse_position() - half_content_scale_size


func _ready():
	half_content_scale_size = (get_viewport().content_scale_size / 2)
	base_position = position


func _input(event):
	if event is InputEventMouseMotion:
		position = base_position + -(get_viewport_mouse_position() * offset_power)
