class_name Level1 extends Node2D

@onready var boss_portal_location := $BossPortalLocation
@onready var teleport_portal_out := $TeleportPortalOut

var portal_scn := preload("res://scenes/levels/portal.tscn")

var teleport_portal_out_markers = []
var boss
var player: Player


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


func _ready():
	boss = get_node_or_null("Boss_1")
	if boss:
		for portal in boss_portal_location.get_children():
			boss.teleport_locations.append(portal.global_position)
	
	player = get_node_or_null("Player")
	
	for marker in teleport_portal_out.get_children():
		teleport_portal_out_markers.append(marker)
