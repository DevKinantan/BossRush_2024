class_name Hitbox extends Area2D


@export var damage: float = 1.0

func _ready():
	damage = get_parent().damage