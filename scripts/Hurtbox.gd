class_name Hurtbox extends Area2D

signal damage_registered(damage, type, pos)

enum HitType {
	MELEE,
	PROJECTILE,
	LASER
}

@export var damage_multiplier: float = 1.0


func _ready():
	#connect("area_entered", _on_area_entered)
	#connect("body_entered", _on_body_entered)
	pass


func trigger_hurtbox(damage, hit_type, pos):
	damage_registered.emit(damage * damage_multiplier, hit_type, pos)


func _on_area_entered(area):
	if area is Hitbox:
		damage_registered.emit(area.damage * damage_multiplier, HitType.MELEE, area.global_position)
		#print(area.damage  * damage_multiplier)


func _on_body_entered(body):
	if body is Projectile:
		damage_registered.emit(body.damage * damage_multiplier, HitType.PROJECTILE, body.global_position)
		body.queue_free()
		#print(body.damage  * damage_multiplier)
