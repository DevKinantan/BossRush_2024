extends Area2D

@onready var particle = $CPUParticles2D


func _on_body_entered(body):
	particle.emitting = true
