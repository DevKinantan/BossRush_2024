extends Node2D

@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var shoot_timer: Timer = $ShootTimer
@onready var laser = $BackBufferCopy/Limb/DeathbotLaser

enum AttackPattern {
	NOT_MOVING,
}
var attack_pattern = AttackPattern.NOT_MOVING


func hand_move_animation_end():
	match attack_pattern:
		AttackPattern.NOT_MOVING:
			laser.shoot_laser()


func _on_portal_portal_opened():
	animation_player.play("HandMove")


func _on_portal_portal_closed():
	queue_free()


func _on_shoot_timer_timeout():
	laser.stop_shoot_laser()


func _on_deathbot_laser_laser_start():
	shoot_timer.start()


func _on_deathbot_laser_laser_stop():
	animation_player.play("HandBack")
