class_name Player extends CharacterBody2D

signal gravity_direction_changed(gravity_direction)

const DOUBLETAP_DELAY = .25
const SPEED = 300.0
const JUMP_VELOCITY = -350.0

@onready var character_sprite: Sprite2D = $Sprite2D
@onready var weapon_pivot = $WeaponPivot

var gravity_direction = Vector2(0, 1)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var doubletap_time = DOUBLETAP_DELAY
var last_keycode = 0


enum PlayerState {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
}


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
	#rotation_degrees = angle_degree


func rotate_weapon():
	var weapon = weapon_pivot.get_children()
	if weapon:
		weapon_pivot.rotation = global_position.angle_to_point(get_global_mouse_position()) - rotation

		if gravity_direction.y:
			weapon[0].flip_v = (gravity_direction.y != 1)
			if (cos(weapon_pivot.rotation) * gravity_direction.y) < 0:
				weapon[0].flip_v = not(weapon[0].flip_v)

		elif gravity_direction.x:
			weapon[0].flip_v = (gravity_direction.x != 1)
			if (cos(weapon_pivot.rotation) * gravity_direction.x) < 0:
				weapon[0].flip_v = not(weapon[0].flip_v)


func flip_character():
	if gravity_direction.y:
		character_sprite.flip_h = (gravity_direction.y * velocity.x) < 0
	elif gravity_direction.x:
		character_sprite.flip_h = (gravity_direction.x * velocity.y) > 0
	
	var offset_x = character_sprite.offset.x
	character_sprite.offset.x = abs(offset_x) if character_sprite.flip_h else -abs(offset_x)


func _jump_state():
	pass


func _process(delta):
	doubletap_time -= delta


func _physics_process(delta):
	if not is_on_floor():
		velocity += (gravity * delta) * gravity_direction

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity = JUMP_VELOCITY * gravity_direction

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
			velocity.y = direction * SPEED
			flip_character()
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

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

	move_and_slide()


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
		
	if event is InputEventMouseMotion:
		rotate_weapon()
	

