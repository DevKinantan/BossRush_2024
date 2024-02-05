class_name Player extends CharacterBody2D

signal gravity_direction_changed(gravity_direction)
signal hp_changed(current_hp, damaged)
signal mp_changed(current_mp)
signal player_dead

const DOUBLETAP_DELAY = 0.25
const SPEED = 250.0
const JUMP_VELOCITY = -350.0

@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var character_animation: AnimationPlayer = $CharacterAnimation
@onready var character_lighting: PointLight2D = $CharacterLighting
@onready var weapon_pivot = $WeaponPivot
@onready var shadow_timer: Timer = $ShadowTimer
@onready var koyori_timer: Timer = $KoyoriTimer
@onready var invincible_timer: Timer = $InvincibleTimer

@onready var landing_1 := $LandingSound/Landing_1
@onready var landing_2 := $LandingSound/Landing_2

@onready var lose_screen_ui := $LoseScreenUI
@onready var win_screen_ui := $WinScreenUI

@export var weapon: Weapon
@export var max_hp: int = 10
@export var max_mp: float = 100.0
@export var levitate_cost: float = 10.0
@export var mp_recovery: float = 30.0
@export var rotate_gravity_cost: float = 10.0
@export var velocity_to_stager: int = 200

var hp: int = max_hp:
	set(new_value):
		hp_changed.emit(new_value, (new_value < hp))
		hp = clamp(new_value, 0, max_hp)

var mp: float = max_mp:
	set(new_value):
		mp_changed.emit(new_value)
		mp = clamp(new_value, 0, max_mp)

var player_shadow_scn = preload("res://scenes/player/player_shadow.tscn")
var walk_dust_scn = preload("res://scenes/player/walk_dust.tscn")
var fall_dust_scn = preload("res://scenes/player/fall_dust.tscn")

var gravity_direction = Vector2(0, 1)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var have_external_velocity:bool = false
var doubletap_time = DOUBLETAP_DELAY
var last_keycode = 0
var last_velocity = Vector2.ZERO
var in_koyori_jump = false


enum PlayerState {
	IDLE,
	WALK,
	JUMP,
	LEVITATE,
	DAMAGED,
	DEAD,
	FALL,
}

var state := PlayerState.IDLE


func idle_state():
	character_animation.play("Idle")

	if not is_on_floor():
		character_animation.stop()
		state = PlayerState.JUMP
		in_koyori_jump = false

	elif is_on_floor() and velocity != Vector2.ZERO:
		character_animation.stop()
		state = PlayerState.WALK

	get_move_direction_input()
	get_jump_input()


func walk_state():
	if is_on_wall():
		character_animation.play("Idle")
	else:
		character_animation.play("Walk")

	get_move_direction_input()
	get_jump_input()

	if (is_on_floor() or in_koyori_jump) and velocity.is_equal_approx(Vector2.ZERO):
		character_animation.stop()
		state = PlayerState.IDLE
	
	elif not is_on_floor():
		if not in_koyori_jump:
			if not koyori_timer.is_stopped():
				koyori_timer.stop()
			koyori_timer.start()
			in_koyori_jump = true

		#if not koyori_timer.is_stopped():
			#get_jump_input()

		if koyori_timer.is_stopped(): 
			character_animation.stop()
			state = PlayerState.JUMP
			in_koyori_jump = false


func jump_state(delta):
	character_animation.play("Jump")
	get_move_direction_input()

	if not is_on_floor():
		velocity += (gravity * delta) * gravity_direction
	
	elif is_on_floor():
		character_animation.stop()
		state = PlayerState.IDLE
		var magnitude = (abs(last_velocity.x) + abs(last_velocity.y)) / 5
		shake_camera(magnitude, 0.3)
		if magnitude > velocity_to_stager:
			character_animation.play("Fall")
			state = PlayerState.FALL
			velocity = Vector2.ZERO
			spawn_fall_dust()
			landing_2.play()
		else :
			landing_1.play()

	if Input.is_action_just_pressed("ui_jump") and (mp > 0):
		velocity = Vector2.ZERO
		character_animation.stop()
		var tween = create_tween()
		tween.tween_property(character_lighting, "energy", 2, 0.2)
		state = PlayerState.LEVITATE


func levitate_state(delta):
	character_animation.play("Jump")

	if Input.is_action_just_released("ui_jump") or (mp <= 0):
		var tween = create_tween()
		tween.tween_property(character_lighting, "energy", 1.0, 0.2)
		state = PlayerState.JUMP
	
	if not is_on_floor() :
		velocity = (gravity * delta) * gravity_direction# * 0.5
	
	elif is_on_floor():
		character_animation.stop()
		var tween = create_tween()
		tween.tween_property(character_lighting, "energy", 1.0, 0.2)
		state = PlayerState.IDLE
		var magnitude = (abs(last_velocity.x) + abs(last_velocity.y)) / 5
		shake_camera(magnitude)
		landing_1.play()
	
	get_move_direction_input()


func damaged_state(delta):
	if not is_on_floor():
		velocity += (gravity * delta) * gravity_direction


func dead_state(delta):
	if not is_on_floor():
		velocity += (gravity * delta) * gravity_direction


func rotate_gravity(angle_degree:float):
	var current_gravity_angle =  Vector2.ZERO.angle_to_point(gravity_direction)
	current_gravity_angle += deg_to_rad(angle_degree)
	gravity_direction = Vector2(round(cos(current_gravity_angle)), round(sin(current_gravity_angle)))
	up_direction = gravity_direction * -1
	
	emit_signal("gravity_direction_changed", gravity_direction)
	in_koyori_jump = false
	#state = PlayerState.JUMP
	
	return current_gravity_angle


func rotate_character(angle_degree:float):
	#shadow_timer.start()
	var tween = create_tween()
	tween.tween_callback(shadow_timer.start)
	tween.tween_property(self, "rotation_degrees", angle_degree, 0.2)
	tween.tween_callback(shadow_timer.stop).set_delay(0.2)

	character_sprite.flip_h = not character_sprite.flip_h

	var offset_x = character_sprite.offset.x
	character_sprite.offset.x = abs(offset_x) if character_sprite.flip_h else -abs(offset_x)


func rotate_weapon(angle: float):
	weapon_pivot.rotation = angle

	if gravity_direction.y:
		weapon.flip_v = (gravity_direction.y != 1)
		if (cos(weapon_pivot.rotation) * gravity_direction.y) < 0:
			weapon.flip_v = not(weapon.flip_v)

	elif gravity_direction.x:
		weapon.flip_v = (gravity_direction.x != 1)
		if (cos(weapon_pivot.rotation) * gravity_direction.x) < 0:
			weapon.flip_v = not(weapon.flip_v)
	
	weapon.position.y = -abs(weapon.position.y) if weapon.flip_v else abs(weapon.position.y)


func flip_character():
	if gravity_direction.y:
		character_sprite.flip_h = (gravity_direction.y * velocity.x) < 0
	elif gravity_direction.x:
		character_sprite.flip_h = (gravity_direction.x * velocity.y) > 0
	
	var offset_x = character_sprite.offset.x
	character_sprite.offset.x = abs(offset_x) if character_sprite.flip_h else -abs(offset_x)


func get_move_direction_input():
	if not gravity_direction.x:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = move_toward(velocity.x, direction*SPEED, SPEED/4)
			flip_character()
			have_external_velocity = false
		else:
			if have_external_velocity:
				velocity.x = move_toward(velocity.x, 0, 10)
			else :
				velocity.x = move_toward(velocity.x, 0, SPEED)

	elif not gravity_direction.y:
		var direction = Input.get_axis("ui_up", "ui_down")
		if direction:
			velocity.y = move_toward(velocity.y, direction*SPEED, SPEED/4)
			flip_character()
			have_external_velocity = false
		else:
			if have_external_velocity:
				velocity.y = move_toward(velocity.y, 0, 10)
			else:
				velocity.y = move_toward(velocity.y, 0, SPEED)


func get_jump_input():
	if Input.is_action_just_pressed("ui_jump") and (is_on_floor() or in_koyori_jump):
		velocity = (JUMP_VELOCITY - 30 if in_koyori_jump else JUMP_VELOCITY) * gravity_direction
		state = PlayerState.JUMP
		in_koyori_jump = false


func shake_camera(magnitude:int, duration:float = 0.2):
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(magnitude, duration)


func is_mouse_distance_less_than(n:int):
	var distance = get_global_mouse_position().distance_to(global_position)
	return distance < n


func fall_end():
	state = PlayerState.IDLE


func spawn_dust():
	if is_on_floor():
		var walk_dust = walk_dust_scn.instantiate()
		walk_dust.flip_h = character_sprite.flip_h
		get_tree().current_scene.add_child(walk_dust)
		walk_dust.global_position = global_position
		walk_dust.rotation = rotation


func spawn_fall_dust():
	var fall_dust = fall_dust_scn.instantiate()
	fall_dust.flip_h = character_sprite.flip_h
	get_tree().current_scene.add_child(fall_dust)
	fall_dust.global_position = global_position
	fall_dust.rotation = rotation


func _ready():
	hp = max_hp
	mp = max_mp


func _process(delta):
	#print(state)
	#print(mp)
	doubletap_time -= delta
	
	#if Input.is_action_just_pressed("ui_swap_weapon"):
		#if weapon.name == "Claymore":
			#weapon = $WeaponPivot/Pistol
			#$WeaponPivot/Pistol.visible = true
			#$WeaponPivot/Claymore.visible = false
		#
		#elif weapon.name == "Pistol":
			#weapon = $WeaponPivot/Claymore
			#$WeaponPivot/Pistol.visible = false
			#$WeaponPivot/Claymore.visible = true


func _physics_process(delta):
	match state:
		PlayerState.IDLE:
			idle_state()
		
		PlayerState.WALK:
			walk_state()
		
		PlayerState.JUMP:
			jump_state(delta)
		
		PlayerState.LEVITATE:
			levitate_state(delta)
			mp -= (levitate_cost * delta)
		
		PlayerState.DAMAGED:
			damaged_state(delta)
		
		PlayerState.DEAD:
			dead_state(delta)
	
	if is_on_floor() and (mp < max_mp):
		mp += (mp_recovery * delta)
	
	if Input.is_action_pressed("ui_change_gravity") and state != PlayerState.DAMAGED and state != PlayerState.DEAD and state != PlayerState.FALL:
		if (mp >= rotate_gravity_cost):
			var target_gravity_degree = 0
			if Input.is_action_pressed("ui_up"):
				target_gravity_degree = rad_to_deg(gravity_direction.angle_to(Vector2.UP))
			elif Input.is_action_pressed("ui_left"):
				target_gravity_degree = rad_to_deg(gravity_direction.angle_to(Vector2.LEFT))
			elif Input.is_action_pressed("ui_down"):
				target_gravity_degree = rad_to_deg(gravity_direction.angle_to(Vector2.DOWN))
			elif Input.is_action_pressed("ui_right"):
				target_gravity_degree = rad_to_deg(gravity_direction.angle_to(Vector2.RIGHT))

			target_gravity_degree = round(target_gravity_degree)
			if target_gravity_degree:
				rotate_character(rad_to_deg(rotate_gravity(target_gravity_degree)) - 90)
				mp -= rotate_gravity_cost

	if weapon and weapon_pivot.get_child_count() != 0:
		if weapon.weapon_type == Weapon.WeaponType.RANGE:
			rotate_weapon(global_position.angle_to_point(get_global_mouse_position()) - rotation)
		
		elif weapon.weapon_type == Weapon.WeaponType.MELEE and weapon.state == Weapon.WeaponState.IDLE:
			if character_sprite.flip_h:
				rotate_weapon(Vector2.RIGHT.angle())
			else:
				rotate_weapon(Vector2.LEFT.angle())
			weapon.flip_v = not weapon.flip_v

	move_and_slide()
	
	if not is_on_floor():
		last_velocity = velocity


func _input(event):
	# Double tap AWSD to change gravity
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and state != PlayerState.DAMAGED and state != PlayerState.DEAD and state != PlayerState.FALL:
		if (last_keycode == event.keycode) and (doubletap_time >= 0) and (mp >= rotate_gravity_cost): 
			#print("DOUBLETAP: ", String.chr(event.keycode))
			var target_gravity_degree = 0
			if String.chr(event.keycode) == "W":
				target_gravity_degree = rad_to_deg(gravity_direction.angle_to(Vector2.UP))
			elif String.chr(event.keycode) == "A":
				target_gravity_degree = rad_to_deg(gravity_direction.angle_to(Vector2.LEFT))
			elif String.chr(event.keycode) == "S":
				target_gravity_degree = rad_to_deg(gravity_direction.angle_to(Vector2.DOWN))
			elif String.chr(event.keycode) == "D":
				target_gravity_degree = rad_to_deg(gravity_direction.angle_to(Vector2.RIGHT))

			target_gravity_degree = round(target_gravity_degree)
			if target_gravity_degree:
				rotate_character(rad_to_deg(rotate_gravity(target_gravity_degree)) - 90)
				mp -= rotate_gravity_cost

			last_keycode = 0

		else:
			last_keycode = event.keycode
		doubletap_time = DOUBLETAP_DELAY
		
	#if event is InputEventMouseMotion:
		#rotate_weapon()

	if event.is_action_pressed("ui_attack") and not event.is_echo() and state != PlayerState.DAMAGED and state != PlayerState.DEAD and state != PlayerState.FALL:
		if weapon and weapon_pivot.get_child_count() != 0:
			if weapon.weapon_type == Weapon.WeaponType.MELEE:
				rotate_weapon(global_position.angle_to_point(get_global_mouse_position()) - rotation)

			if not (weapon.weapon_type == Weapon.WeaponType.RANGE and is_mouse_distance_less_than(25)):
				weapon.attack()


func _on_shadow_timer_timeout():
	var player_shadow = player_shadow_scn.instantiate()
	player_shadow.position = position
	player_shadow.rotation = rotation
	player_shadow.flip_h = character_sprite.flip_h

	get_tree().current_scene.add_child(player_shadow)


func _on_hurtxox_damage_registered(_damage, _type, pos):
	if invincible_timer.is_stopped():
		hp -= 1
		shake_camera(300, 0.3)
		state = PlayerState.DAMAGED
		character_animation.play("Damaged")
		invincible_timer.start()

		velocity = global_position.direction_to(pos) * -SPEED


func _on_invincible_timer_timeout():
	if hp <= 0:
		player_dead.emit()
		state = PlayerState.DEAD
		if character_animation.is_playing():
			character_animation.stop()
		character_animation.play("Dead")
		velocity = Vector2.ZERO
	else:
		state = PlayerState.IDLE


func _on_player_dead():
	lose_screen_ui.visible = true


func _on_boss_1_boss_dead():
	var tween = create_tween()
	tween.tween_property(win_screen_ui, "visible", true, 0.1).set_delay(5.0)
	#win_screen_ui.visible = true
