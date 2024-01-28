extends Node2D

@onready var boss_portal_location := $BossPortalLocation


func _ready():
	var boss = get_node_or_null("Boss_1")
	if boss:
		for portal in boss_portal_location.get_children():
			boss.teleport_locations.append(portal.global_position)
