extends Node2D

signal is_coliding(direction)

@onready var down_raycast = $Down
@onready var left_raycast = $Left
@onready var right_raycast = $Right
@onready var up_raycast = $Up

@export var is_active = true


func set_is_active(val:bool):
	is_active = val
	set_physics_process(val)


func _ready():
	set_physics_process(is_active)


func _physics_process(_delta):
	if up_raycast.is_colliding():
		is_coliding.emit(Vector2.UP)
	
	elif left_raycast.is_colliding():
		is_coliding.emit(Vector2.LEFT)
	
	elif right_raycast.is_colliding():
		is_coliding.emit(Vector2.RIGHT)
	
	elif down_raycast.is_colliding():
		is_coliding.emit(Vector2.DOWN)
