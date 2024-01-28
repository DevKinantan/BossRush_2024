extends Enemy

signal player_enter_boss_area
signal player_exit_boss_area

@export var attack_offset: int = 140
@export var speed: int = 50

@onready var attack_pivot := $AttackPivot
@onready var portal_pivot := $BackBufferCopy/PortalPivot
@onready var animation_player := $AnimationPlayer
@onready var border_detector := $BorderDetector
@onready var cooldown_timer:Timer = $CooldownTimer

@onready var claw_limb_scn = preload("res://scenes/boss/boss_1/claw_limb.tscn")
@onready var laser_limb_scn = preload("res://scenes/boss/boss_1/laser_limb.tscn")

@export var can_attack:bool = false
var player_nearby:Player
var teleport_locations = []


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


func get_farthest_teleport_positions():
	var farthest_teleport_positions = teleport_locations.duplicate()
	var shortest_position = teleport_locations[0]
	var shortest_distance = global_position.distance_to(teleport_locations[0])
	for pos in teleport_locations:
		var pos_distance = global_position.distance_to(pos)
		if pos_distance < shortest_distance:
			shortest_distance = pos_distance
			shortest_position = pos

	farthest_teleport_positions.erase(shortest_position)
	return farthest_teleport_positions


func teleport(portal_direction: Vector2):
	velocity = Vector2.ZERO
	portal_pivot.rotation = portal_direction.angle()
	animation_player.play("EnterPortal")
	can_attack = false
	border_detector.set_is_active(false)


func enter_portal_end():
	global_position = get_farthest_teleport_positions().pick_random()
	animation_player.play("ExitPortal")


func exit_portal_end():
	animation_player.play("NoPortal")
	can_attack = true
	border_detector.set_is_active(true)


func _ready():
	teleport_locations.append(global_position)


func _process(_delta):
	if player_nearby and can_attack and cooldown_timer.is_stopped() and not animation_player.is_playing():
		attack_near_player()
	
	#velocity = Vector2(0, 50)
	#move_and_slide()


func _physics_process(delta):
	if player_nearby:
		var direction = global_position.direction_to(player_nearby.global_position).normalized() * -1
		velocity.x = move_toward(velocity.x, direction.x * speed, 1)
		velocity.y = move_toward(velocity.y, direction.y * speed, 1)
	
	else:
		velocity.x = move_toward(velocity.x, 0, 1)
		velocity.y = move_toward(velocity.y, 0, 1)
	
	move_and_slide()


func _on_detection_area_body_entered(body):
	if body is Player:
		player_nearby = body


func _on_detection_area_body_exited(body):
	if body is Player:
		player_nearby = null


func _on_attack_tree_exited():
	can_attack = true
	cooldown_timer.start()


func _on_border_detector_is_coliding(direction):
	#print(direction)
	teleport(direction * -1)
