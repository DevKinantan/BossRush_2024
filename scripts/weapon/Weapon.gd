class_name Weapon extends Sprite2D


enum WeaponType {
	MELEE,
	RANGE
}


@export var damage: int
@export var weapon_type: WeaponType


func attack():
	pass
