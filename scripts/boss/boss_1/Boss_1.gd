extends Enemy

signal player_enter_boss_area
signal player_exit_boss_area

@export var attack_offset:int = 140

@onready var attack_pivot := $AttackPivot
@onready var cooldown_timer:Timer = $CooldownTimer

var claw_limb_scn = preload("res://scenes/boss/boss_1/claw_limb.tscn")
var laser_limb_scn = preload("res://scenes/boss/boss_1/laser_limb.tscn")

var can_attack:bool = true
var player_nearby:Player


func defensive_claw_attack(wiggle:bool):
	var claw_limb = claw_limb_scn.instantiate()
	claw_limb.wiggle = wiggle
	claw_limb.connect("tree_exited", _on_attack_tree_exited)
	attack_pivot.add_child(claw_limb)
	claw_limb.position.x = attack_offset
	
	can_attack = false


func defensive_laser_attack():
	var laser_limb = laser_limb_scn.instantiate()
	laser_limb.connect("tree_exited", _on_attack_tree_exited)
	attack_pivot.add_child(laser_limb)
	laser_limb.position.x = attack_offset
	
	can_attack = false


func defensive_portal_attack():
	pass


func attack_near_player():
	attack_pivot.rotation = get_angle_to(player_nearby.global_position)# + body.velocity)
	
	var attack_variance:int = randi_range(1, 3)
	match attack_variance:
		1: defensive_claw_attack(false)
		2: defensive_claw_attack(true)
		3: defensive_laser_attack()


func _process(_delta):
	if player_nearby and can_attack and cooldown_timer.is_stopped():
		attack_near_player()


func _on_detection_area_body_entered(body):
	if body is Player:
		player_nearby = body


func _on_detection_area_body_exited(body):
	if body is Player:
		player_nearby = null


func _on_attack_tree_exited():
	can_attack = true
	cooldown_timer.start()
