class_name Weapon extends Sprite2D


enum WeaponType {
	MELEE,
	RANGE
}

enum WeaponState {
	IDLE,
	ATTACK
}


@export var damage: int
@export var weapon_type: WeaponType
var state = WeaponState.IDLE

func attack():
	pass
