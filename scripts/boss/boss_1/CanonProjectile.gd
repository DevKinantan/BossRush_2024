extends CharacterBody2D

@export var speed := 200

var direction := Vector2(1, 1)

func _physics_process(_delta):
	velocity = speed * direction
	move_and_slide()


func _on_timer_timeout():
	queue_free()
