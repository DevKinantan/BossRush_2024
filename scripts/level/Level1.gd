class_name Level1 extends Node2D

@onready var boss_portal_location := $BossPortalLocation
@onready var canon_projectile_location := $CanonProjectileLocation
@onready var teleport_portal_out := $TeleportPortalOut
@onready var attack_timer := $AttackTimer

@onready var canon := $FinalCanon/Canon
@onready var canon2 := $FinalCanon/Canon2
@onready var canon3 := $FinalCanon/Canon3
@onready var canon_timer := $FinalCanon/CanonTimer

@onready var music_phase_1 := $Music/Phase_1
@onready var music_phase_2 := $Music/Phase_2
@onready var music_phase_3 := $Music/Phase_3

@onready var scream_1 := $TransitionSFX/Scream_1
@onready var scream_2 := $TransitionSFX/Scream_2
@onready var scream_3 := $TransitionSFX/Scream_3

@export var num_of_attack:int = 0

var portal_scn := preload("res://scenes/levels/portal.tscn")
var claw_limb_scn := preload("res://scenes/boss/boss_1/claw_limb.tscn")
var laser_limb_scn := preload("res://scenes/boss/boss_1/laser_limb.tscn")
var canon_projectile_scn := preload("res://scenes/boss/boss_1/canon_projectile.tscn")

var boss_is_dead: bool = false
var player_is_dead: bool = false
var can_attack: bool = true
var can_bombard: bool = true
var teleport_portal_out_markers = []
var boss: Enemy
var player: Player

var phase := 1


func create_farthest_player_teleport_portal():
	var farthest_marker = teleport_portal_out_markers[0]
	var farthest_distance: float = 0.0

	for marker in teleport_portal_out_markers:
		var distance = player.global_position.distance_to(marker.global_position)
		if distance > farthest_distance:
			farthest_distance = distance
			farthest_marker = marker
	
	var portal = portal_scn.instantiate()
	portal.can_teleport = true
	portal.teleport_type = Portal.TeleportPortalType.OUT
	farthest_marker.add_child(portal)
	portal.global_position = farthest_marker.global_position

	return portal


func create_bullet_out_portal_near_player():
	var portal = portal_scn.instantiate()
	portal.can_teleport = true
	portal.only_projectile = true
	portal.teleport_type = Portal.TeleportPortalType.OUT
	portal.queue_free_parent = true

	var pivot_node := Node2D.new()
	add_child(pivot_node)
	pivot_node.global_position = player.global_position
	pivot_node.call_deferred("add_child", portal)
	#pivot_node.add_child(portal)
	
	if player.global_position.x < boss.global_position.x:
		pivot_node.rotation_degrees = randi_range(-90, 90)
	
	elif player.global_position.x > boss.global_position.x:
		pivot_node.rotation_degrees = randi_range(90, 360)

	portal.position.x = randi_range(-150, -100)

	return portal


func claw_attack_player():
	var pivot = Node2D.new()
	add_child(pivot)
	pivot.global_position = player.global_position
	pivot.rotation_degrees = randi_range(45, 315)
	
	var claw_limb = claw_limb_scn.instantiate()
	claw_limb.queue_free_parent = true
	claw_limb.wiggle = [true, false].pick_random()
	pivot.call_deferred("add_child", claw_limb)
	claw_limb.position.x = -220
	claw_limb.connect("tree_exited", _on_attack_finsihed)
	
	can_attack = false


func laser_attack_player():
	var pivot = Node2D.new()
	add_child(pivot)
	pivot.global_position = player.global_position
	pivot.rotation_degrees = randi_range(30, 150)
	
	var flip = randi_range(0, 1)
	if flip == 1:
		pivot.rotation_degrees *= -1
	
	var laser_limb = laser_limb_scn.instantiate()
	laser_limb.queue_free_parent = true
	pivot.call_deferred("add_child", laser_limb)
	laser_limb.position.x = -250
	laser_limb.connect("tree_exited", _on_attack_finsihed)
	
	can_attack = false


func fire_canons():
	var tween = create_tween()
	tween.tween_callback(canon.fire)
	tween.tween_callback(canon2.fire).set_delay(5.0)
	tween.tween_callback(canon3.fire).set_delay(5.0)


func spawn_canon_projectile():
	var spawn_location: Vector2 = canon_projectile_location.get_children().pick_random().global_position
	var canon_projectile := canon_projectile_scn.instantiate()
	
	get_tree().current_scene.add_child(canon_projectile)
	canon_projectile.global_position = spawn_location


func shake_camera(magnitude:int, duration:float = 0.2):
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(magnitude, duration)


func _ready():
	boss = get_node_or_null("Boss_1")
	if boss:
		for portal in boss_portal_location.get_children():
			boss.teleport_locations.append(portal.global_position)
	
	player = get_node_or_null("Player")
	
	for marker in teleport_portal_out.get_children():
		teleport_portal_out_markers.append(marker)


func _process(_delta):
	if can_attack and attack_timer.is_stopped() and boss != null and not boss_is_dead and player != null and not player_is_dead:
		for i in range(num_of_attack):
			var attack_type: int = randi_range(1, 2)
			match attack_type:
				1: claw_attack_player()
				2: laser_attack_player()


func _on_attack_finsihed():
	can_attack = true
	if attack_timer.is_inside_tree():
		attack_timer.start()


func _on_boss_1_boss_dead():
	boss = null
	boss_is_dead = true
	
	if music_phase_1.playing:
		var tween := create_tween()
		tween.tween_property(music_phase_1, "volume_db", -80.0, 1.0)
		tween.tween_callback(music_phase_1.stop)

	if music_phase_2.playing:
		var tween := create_tween()
		tween.tween_property(music_phase_2, "volume_db", -80.0, 1.0)
		tween.tween_callback(music_phase_2.stop)
	
	if music_phase_3.playing:
		var tween := create_tween()
		tween.tween_property(music_phase_3, "volume_db", -80.0, 1.0)
		tween.tween_callback(music_phase_3.stop)


func _on_boss_1_boss_damaged(current_hp):
	if current_hp <= 20.0 and can_bombard:
		fire_canons()
		can_bombard = false
		phase = 3

	elif current_hp <= 50.0:
		num_of_attack = 2
		phase = 2

	elif current_hp <= 80.0:
		num_of_attack = 1
	
	if phase == 1 and not music_phase_1.playing:
		scream_1.play()
		shake_camera(400, 2.0)
		var tween := create_tween()
		tween.tween_callback(music_phase_1.play)
		tween.tween_property(music_phase_1, "volume_db", -14.0, 2.0)
	
	elif phase == 2 and not music_phase_2.playing:
		scream_2.play()
		shake_camera(400, 2.0)
		var tween := create_tween()
		tween.tween_callback(music_phase_2.play)
		tween.tween_property(music_phase_1, "volume_db", -80.0, 1.0)
		tween.tween_callback(music_phase_1.stop)
		tween.tween_property(music_phase_2, "volume_db", -15.0, 2.0)
	
	elif phase == 3 and not music_phase_3.playing:
		scream_3.play()
		shake_camera(400, 2.0)
		var tween := create_tween()
		tween.tween_callback(music_phase_3.play)
		tween.tween_property(music_phase_2, "volume_db", -80.0, 1.0)
		tween.tween_callback(music_phase_2.stop)
		tween.tween_property(music_phase_3, "volume_db", -18.0, 2.0)


func _on_player_player_dead():
	player = null
	player_is_dead = true

	if music_phase_1.playing:
		var tween := create_tween()
		tween.tween_property(music_phase_1, "volume_db", -80.0, 1.0)
		tween.tween_callback(music_phase_1.stop)

	if music_phase_2.playing:
		var tween := create_tween()
		tween.tween_property(music_phase_2, "volume_db", -80.0, 1.0)
		tween.tween_callback(music_phase_2.stop)
	
	if music_phase_3.playing:
		var tween := create_tween()
		tween.tween_property(music_phase_3, "volume_db", -80.0, 1.0)
		tween.tween_callback(music_phase_3.stop)


func _on_canon_3_canon_move_back():
	canon_timer.start()


func _on_canon_timer_timeout():
	if boss != null and not boss_is_dead and player != null and not player_is_dead:
		fire_canons()


func _on_canon_canon_fired():
	var tween := create_tween()
	tween.tween_callback(spawn_canon_projectile).set_delay(5.0)


#func _input(event):
	#if event.is_action_pressed("ui_swap_weapon"):
		#fire_canons()
