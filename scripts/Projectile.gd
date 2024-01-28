class_name Projectile extends CharacterBody2D

enum Target {
	ENEMY,
	PLAYER
}

@onready var sprite = $ProjectileSprite
@onready var timer = $Timer

@export var target: Target = Target.ENEMY
@export var damage: float = 1.0


func set_target(t:Target):
	target = t
	match t:
		Target.ENEMY:
			set_collision_mask_value(2, true)
			set_collision_layer_value(2, true)
			#set_collision_mask_value(3, true)
			set_collision_mask_value(5, true)
			set_collision_layer_value(5, true)

		Target.PLAYER:
			set_collision_mask_value(4, true)
			set_collision_layer_value(4, true)

			set_collision_layer_value(3, false)
			#set_collision_mask_value(3, false)
			set_collision_mask_value(5, false)
			set_collision_layer_value(5, false)

			timer.start()


func _ready():
	set_target(target)


func _physics_process(_delta):
	sprite.rotation = velocity.angle()
	move_and_slide()
	
	if (is_on_ceiling() or is_on_floor() or is_on_wall()) and target == Target.ENEMY:
		queue_free()


#func _on_body_entered(_body):
	##print(collision_mask)
	#queue_free()


func _on_timer_timeout():
	queue_free()
