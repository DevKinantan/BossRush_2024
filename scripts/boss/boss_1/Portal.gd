class_name Portal extends Sprite2D

signal portal_opened()
signal portal_closed()

enum TeleportPortalType {
	IN,
	OUT
}

@onready var teleport_area = $TeleportArea
@onready var animation_player = $AnimationPlayer

@export var can_teleport: bool = false
@export var only_projectile: bool = false
@export var teleport_type: TeleportPortalType = TeleportPortalType.IN
@export var linked_portal: Portal
@export var queue_free_parent: bool = false
@export var specific_target_pos: Vector2


func open_portal_end():
	emit_signal("portal_opened")


func close_portal_end():
	emit_signal("portal_closed")
	if queue_free_parent:
		get_parent().queue_free()

	elif can_teleport:
		queue_free()


func close_portal():
	if animation_player:
		animation_player.play("Close")


func rotate_vec2(vec2:Vector2, angle:float):
	return Vector2((vec2.x * cos(angle)) - (vec2.y * sin(angle)), (vec2.x * sin(angle)) + (vec2.y * cos(angle)))


func _ready():
	teleport_area.monitoring = can_teleport


func _on_teleport_area_body_entered(body):
	if teleport_type == TeleportPortalType.IN and linked_portal:
		if body is Player and not only_projectile:
			body.global_position = linked_portal.global_position
			#print(body.global_position)
		
		elif body is Projectile:
			var angle = Vector2.RIGHT.angle()
			if specific_target_pos:
				var body_velocity = abs(body.velocity.x) + abs(body.velocity.y)
				var direction = linked_portal.global_position.direction_to(specific_target_pos)
				body.velocity = direction * body_velocity
			
			else:
				if linked_portal.get_parent() is Node2D:
					angle = linked_portal.get_parent().rotation
				angle += Vector2.RIGHT.angle()
				body.velocity = rotate_vec2(body.velocity, angle)# + Vector2.RIGHT.angle())

			body.global_position = linked_portal.global_position
			body.set_target(body.Target.PLAYER)
	
	elif teleport_type == TeleportPortalType.OUT:
		var angle = Vector2.RIGHT.angle()
		if get_parent() is Node2D:
			angle = get_parent().rotation
		angle -= Vector2.DOWN.angle()
		
		if body is Player and not only_projectile:
			body.have_external_velocity = true
			body.velocity = rotate_vec2(body.velocity, angle)
			if body.gravity_direction == Vector2.LEFT or body.gravity_direction == Vector2.RIGHT:
				body.velocity = rotate_vec2(body.velocity, body.gravity_direction.angle() + Vector2.DOWN.angle())
			else:
				body.velocity = rotate_vec2(body.velocity, body.gravity_direction.angle() - Vector2.DOWN.angle())
			close_portal()
			linked_portal.close_portal()
