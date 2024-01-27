class_name Projectile extends RigidBody2D

enum Target {
	ENEMY,
	PLAYER
}

@onready var sprite = $ProjectileSprite

@export var target: Target = Target.ENEMY


func set_target(t:Target):
	pass


func _physics_process(_delta):
	sprite.rotation = linear_velocity.angle()


func _on_body_entered(body):
	print(collision_mask)
	queue_free()
