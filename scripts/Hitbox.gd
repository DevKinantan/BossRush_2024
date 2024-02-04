class_name Hitbox extends Area2D


@export var damage: float = 1.0

func _ready():
	if "damage" in get_parent():
		damage = get_parent().damage
