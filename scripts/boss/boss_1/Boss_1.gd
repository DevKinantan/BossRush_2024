extends Enemy

signal player_enter_boss_area
signal player_exit_boss_area

@export var attack_offset: int = 140
@export var speed: int = 50

@onready var attack_pivot := $AttackPivot
@onready var portal_pivot := $BackBufferCopy/PortalPivot
@onready var animation_player := $AnimationPlayer
@onready var hit_animation_player := $HitAnimationPlayer
@onready var border_detector := $BorderDetector
@onready var cooldown_timer:Timer = $CooldownTimer
@onready var invincible_timer:Timer = $InvincibleTimer

var claw_limb_scn = preload("res://scenes/boss/boss_1/claw_limb.tscn")
var laser_limb_scn = preload("res://scenes/boss/boss_1/laser_limb.tscn")
var dead_body_scn = preload("res://scenes/boss/boss_1/dead_boss_1.tscn")
var portal_scn = preload("res://scenes/levels/portal.tscn")

@export var can_attack:bool = false
@export var max_hp:float = 100.0
@export var damage_to_teleport: float = 10.0
@export var projectile_damage_to_create_portal: float = 2.0

var hp := max_hp
var is_invicible: bool = false
var player_nearby:Player
var teleport_locations = []
var damage_accumulation:float = 0.0
var projectile_damage_accumulation:float = 0.0

enum BossState {
	ALIVE,
	TELEPORT,
	DEAD
}

var level_controller: Level1
var state = BossState.ALIVE


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
	if not level_controller:
		return
	
	var portal_out = level_controller.create_farthest_player_teleport_portal()
	var portal_in = portal_scn.instantiate()
	portal_in.can_teleport = true
	portal_in.connect("tree_exited", _on_attack_tree_exited)

	portal_in.linked_portal = portal_out
	portal_out.linked_portal = portal_in
	
	attack_pivot.add_child(portal_in)
	portal_in.position.x = attack_offset
	portal_in.scale = Vector2(2, 2)
	
	var tween = create_tween()
	tween.tween_property(portal_in, "position", Vector2(300 + attack_offset, 0), 1.0).set_delay(0.7)
	tween.tween_callback(portal_in.close_portal)
	tween.tween_callback(portal_out.close_portal)
	
	can_attack = false


func create_portal_shield(angle: float):
	if not level_controller:
		return

	var portal_out = level_controller.create_bullet_out_portal_near_player()
	var portal_in = portal_scn.instantiate()
	portal_in.can_teleport = true
	portal_in.only_projectile = true
	portal_in.queue_free_parent = true
	portal_in.specific_target_pos = level_controller.player.global_position

	portal_in.linked_portal = portal_out
	portal_out.linked_portal = portal_in

	var defense_pivot := Node2D.new()
	add_child(defense_pivot)
	defense_pivot.scale = Vector2(0.3, 0.3)
	defense_pivot.global_position = global_position
	defense_pivot.rotation = angle
	defense_pivot.call_deferred("add_child", portal_in)
	#portal_pivot.add_child(portal_in)
	portal_in.position.x = attack_offset + 50
	portal_in.scale = Vector2(2.0, 2.0)

	var tween = create_tween()
	tween.tween_callback(portal_in.close_portal).set_delay(3.0)
	tween.tween_callback(portal_out.close_portal)


func attack_near_player():
	attack_pivot.rotation = get_angle_to(player_nearby.global_position)# + body.velocity)
	
	var attack_variance:int = randi_range(1, 4)
	match attack_variance:
		1: defensive_claw_attack(false)
		2: defensive_claw_attack(true)
		3: defensive_laser_attack()
		4: defensive_portal_attack()


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
	damage_accumulation = 0.0


func enter_portal_end():
	global_position = get_farthest_teleport_positions().pick_random()
	animation_player.play("ExitPortal")


func exit_portal_end():
	animation_player.play("NoPortal")
	can_attack = true
	border_detector.set_is_active(true)
	state = BossState.ALIVE


func dead_end():
	var dead_body = dead_body_scn.instantiate()
	get_tree().current_scene.add_child(dead_body)
	dead_body.global_position = global_position
	queue_free()


func alive_state():
	if player_nearby:
		var direction = global_position.direction_to(player_nearby.global_position).normalized() * -1
		velocity.x = move_toward(velocity.x, direction.x * speed, 1)
		velocity.y = move_toward(velocity.y, direction.y * speed, 1)
	
	else:
		velocity.x = move_toward(velocity.x, 0, 1)
		velocity.y = move_toward(velocity.y, 0, 1)


func _ready():
	teleport_locations.append(global_position)
	defensive_claw_attack(false)
	
	if get_parent() is Level1:
		level_controller = get_parent()


func _process(_delta):
	pass
	
	#velocity = Vector2(0, 50)
	#move_and_slide()


func _physics_process(_delta):
	match state:
		BossState.ALIVE:
			alive_state()
	
	if player_nearby and can_attack and cooldown_timer.is_stopped() and not animation_player.is_playing() and state == BossState.ALIVE:
		attack_near_player()
	
	move_and_slide()


func _on_detection_area_body_entered(body):
	if body is Player:
		player_nearby = body


func _on_detection_area_body_exited(body):
	if body is Player:
		player_nearby = null


func _on_attack_tree_exited():
	can_attack = true
	if not cooldown_timer.is_stopped():
		cooldown_timer.stop()
	
	if hp > 0:
		cooldown_timer.start()


func _on_border_detector_is_coliding(direction):
	#print(direction)
	teleport(direction * -1)
	state = BossState.TELEPORT


func _on_hurtbox_damage_registered(damage, type, pos):
	if not is_invicible:
		invincible_timer.start()
		is_invicible = true
		hit_animation_player.play("BodyHit")
		damage_accumulation += damage
		hp -= damage

		if type == Hurtbox.HitType.PROJECTILE:
			projectile_damage_accumulation += damage

		if hp <= 0:
			state = BossState.DEAD
			velocity = Vector2.ZERO
			can_attack = false
			is_invicible = true
			animation_player.play("Dead")

		elif damage_accumulation >= damage_to_teleport:
			teleport(pos)

		elif projectile_damage_accumulation >= projectile_damage_to_create_portal:
			projectile_damage_accumulation = 0
			var player_pos = level_controller.player.global_position
			create_portal_shield(get_angle_to(player_pos))


func _on_critical_hurt_box_damage_registered(damage, type, pos):
	if not is_invicible:
		invincible_timer.start()
		is_invicible = true
		hit_animation_player.play("HeadHit")
		damage_accumulation += damage
		hp -= damage
		
		if type == Hurtbox.HitType.PROJECTILE:
			projectile_damage_accumulation += damage

		if hp <= 0:
			state = BossState.DEAD
			velocity = Vector2.ZERO
			can_attack = false
			is_invicible = true
			animation_player.play("Dead")

		elif damage_accumulation >= damage_to_teleport:
			teleport(pos)
		
		elif projectile_damage_accumulation >= projectile_damage_to_create_portal:
			projectile_damage_accumulation = 0
			var player_pos = level_controller.player.global_position
			create_portal_shield(get_angle_to(player_pos))


func _on_invincible_timer_timeout():
	is_invicible = false
