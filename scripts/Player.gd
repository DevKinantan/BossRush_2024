class_name Player extends CharacterBody2D

signal gravity_direction_changed(gravity_direction)

const DOUBLETAP_DELAY = .25
const SPEED = 300.0
const JUMP_VELOCITY = -350.0

@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var character_animation: AnimationPlayer = $CharacterAnimation
@onready var character_lighting: PointLight2D = $CharacterLighting
@onready var weapon_pivot = $WeaponPivot

@export var weapon: Weapon

var gravity_direction = Vector2(0, 1)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var doubletap_time = DOUBLETAP_DELAY
var last_keycode = 0
var last_velocity = Vector2.ZERO


enum PlayerState {
	IDLE,
	WALK,
	JUMP,
	LEVITATE,
	ATTACK,
}

var state := PlayerState.IDLE


func idle_state():
	character_animation.play("Idle")

	get_move_direction_input()
	get_jump_input()

	if is_on_floor() and velocity != Vector2.ZERO:
		character_animation.stop()
		state = PlayerState.WALK
	
	elif not is_on_floor():
		character_animation.stop()
		state = PlayerState.JUMP


func walk_state():
	character_animation.play("Walk")

	get_move_direction_input()
	get_jump_input()
	
	if is_on_floor() and velocity.is_equal_approx(Vector2.ZERO):
		character_animation.stop()
		state = PlayerState.IDLE
	
	elif not is_on_floor():
		character_animation.stop()
		state = PlayerState.JUMP


func jump_state(delta):
	character_animation.play("Jump")

	get_move_direction_input()

	if not is_on_floor():
		velocity += (gravity * delta) * gravity_direction
	
	elif is_on_floor():
		character_animation.stop()
		state = PlayerState.IDLE
		var magnitude = (abs(last_velocity.x) + abs(last_velocity.y)) / 10
		shake_camera(magnitude)
	
	if Input.is_action_just_pressed("ui_jump"):
		velocity = Vector2.ZERO
		character_animation.stop()
		var tween = create_tween()
		tween.tween_property(character_lighting, "energy", 2, 0.2)
		state = PlayerState.LEVITATE


func levitate_state(delta):
	character_animation.play("Jump")

	if Input.is_action_just_released("ui_jump"):
		var tween = create_tween()
		tween.tween_property(character_lighting, "energy", 1, 0.2)
		state = PlayerState.JUMP
	
	if not is_on_floor() :
		velocity = (gravity * delta) * gravity_direction# * 0.5
	
	elif is_on_floor():
		character_animation.stop()
		var tween = create_tween()
		tween.tween_property(character_lighting, "energy", 1, 0.2)
		state = PlayerState.IDLE
		var magnitude = (abs(last_velocity.x) + abs(last_velocity.y)) / 10
		shake_camera(magnitude)
	
	get_move_direction_input()


func attack_state():
	pass


func rotate_gravity(angle_degree:float):
	var current_gravity_angle =  Vector2.ZERO.angle_to_point(gravity_direction)
	current_gravity_angle += deg_to_rad(angle_degree)
	gravity_direction = Vector2(round(cos(current_gravity_angle)), round(sin(current_gravity_angle)))
	up_direction = gravity_direction * -1
	
	emit_signal("gravity_direction_changed", gravity_direction)
	
	return current_gravity_angle


func rotate_character(angle_degree:float):
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", angle_degree, 0.2)


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
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	elif not gravity_direction.y:
		var direction = Input.get_axis("ui_up", "ui_down")
		if direction:
			velocity.y = move_toward(velocity.y, direction*SPEED, SPEED/4)
			flip_character()
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)


func get_jump_input():
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity = JUMP_VELOCITY * gravity_direction


func shake_camera(magnitude:int):
	var camera = get_viewport().get_camera_2d()
	if camera is PlayerCamera2D:
		camera.shake(magnitude, 0.2)


func _process(delta):
	doubletap_time -= delta


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
	
	if Input.is_action_pressed("ui_change_gravity"):
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

	if weapon:
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
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if last_keycode == event.keycode and doubletap_time >= 0: 
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

			last_keycode = 0

		else:
			last_keycode = event.keycode
		doubletap_time = DOUBLETAP_DELAY
		
	#if event is InputEventMouseMotion:
		#rotate_weapon()

	if event.is_action_pressed("ui_attack") and not event.is_echo():
		if weapon:
			if weapon.weapon_type == Weapon.WeaponType.MELEE:
				rotate_weapon(global_position.angle_to_point(get_global_mouse_position()) - rotation)

			weapon.attack()
