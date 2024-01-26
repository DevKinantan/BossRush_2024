extends RayCast2D

@onready var line = $Line2D
@onready var collision_particle = $CollisionParticle
@onready var beam_particle = $BeamParticle

var is_casting := false


func _ready():
	set_physics_process(false)
	line.points[1] = Vector2.ZERO


#func _input(event):
	#if event.is_action_pressed("ui_attack"):
		#set_is_casting(true)
	#else :
		#set_is_casting(false)


func _physics_process(_delta):
	var cast_point := target_position
	force_raycast_update()

	if is_colliding():
		var area = get_collider()
		if area is Hurtbox:
			cast_point = to_local(get_collision_point())
			collision_particle.position = cast_point
			collision_particle.emitting = is_casting
		else:
			add_exception(area)

	line.points[1] = cast_point
	beam_particle.position = cast_point * 0.5
	beam_particle.emission_rect_extents.y = cast_point.length() * 0.5


func set_is_casting(cast: bool):
	is_casting = cast
	beam_particle.emitting = is_casting

	if is_casting:
		appear()
	else:
		disappear()

	set_physics_process(is_casting)


func appear():
	var tween = create_tween()
	tween.tween_property(line, "width", 10, 0.2)


func disappear():
	collision_particle.emitting = false

	var tween = create_tween()
	tween.tween_property(line, "width", 0, 0.1)
