class_name Player extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_direction = Vector2(0, 1)


enum PlayerState {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
}


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
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/2)

	move_and_slide()


func _input(event):
	if event.is_action_pressed("ui_interact"):
		gravity_direction *= -1
		up_direction = gravity_direction * -1
		
		rotation_degrees = rad_to_deg(Vector2.ZERO.angle_to_point(gravity_direction)) - 90
