extends Weapon


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $ChainAttackTimer

var chain_attack: bool = false 


func _process(_delta):
	if not attack_timer.is_stopped():
		if Input.is_action_just_pressed("ui_attack"):
			chain_attack = true
			attack_timer.stop()


func attack():
	if state == WeaponState.IDLE:
		state = WeaponState.ATTACK
		animation_player.play("Slash_1")


func end_slash_1():
	if chain_attack:
		animation_player.play("Slash_2")
	else:
		state = WeaponState.IDLE
		animation_player.play("Idle")


func end_slash_2():
	state = WeaponState.IDLE
	animation_player.play("Idle")
	chain_attack = false
