class_name Player extends CharacterBody2D

signal gravity_direction_changed(gravity_direction)


const SPEED = 500.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var gravity_direction = Vector2(0, 1)


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


func _jump_state():
	pass


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += (gravity * delta) * gravity_direction

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity = JUMP_VELOCITY * gravity_direction

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#print(round(gravity_direction.x), " ", round(gravity_direction.y))
	if not gravity_direction.x:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	elif not gravity_direction.y:
		var direction = Input.get_axis("ui_up", "ui_down")
		if direction:
			velocity.y = direction * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()


func _input(event):
	if event.is_action_pressed("ui_rotate_gravity_90"):
		rotation_degrees = rad_to_deg(rotate_gravity(-90)) - 90
	
	elif event.is_action_pressed("ui_rotate_gravity_-90"):
		rotation_degrees = rad_to_deg(rotate_gravity(90)) - 90
