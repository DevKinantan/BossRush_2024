extends Weapon

signal durability_changed(current_durability)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $ChainAttackTimer

@export var max_durability: int = 100
@export var durability_reduction: int = 5

var durabitily: int = max_durability:
	set(new_value):
		durabitily = clamp(new_value, 0, max_durability)
		durability_changed.emit(durabitily)

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
		chain_attack = false
		animation_player.play("Slash_2")
	else:
		state = WeaponState.IDLE
		animation_player.play("Idle")


func end_slash_2():
	state = WeaponState.IDLE
	animation_player.play("Idle")


func _on_hitbox_area_entered(area):
	if area is Hurtbox:
		var camera = get_viewport().get_camera_2d()
		if camera is PlayerCamera2D:
			camera.shake(300, 0.2)
		
		durabitily -= durability_reduction
		if durabitily <= 0:
			queue_free()
