extends Node2D

@onready var animation_player:AnimationPlayer = $AnimationPlayer

var queue_free_parent:bool = false
var wiggle:bool = true


func hand_move_animation_end():
	if wiggle:
		animation_player.play("HandWiggle")
	else:
		animation_player.play("HandBack")


func _on_portal_portal_opened():
	animation_player.play("HandMove")


func _on_portal_portal_closed():
	if queue_free_parent:
		get_parent().queue_free()
	else :
		queue_free()
