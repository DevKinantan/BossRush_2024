extends Sprite2D

@onready var animation_hit := $AnimationPlayer2
@onready var portal

var total_hit = 0


func _ready():
	portal = get_tree().current_scene.get_node("Portal")
	portal.visible = false


func _on_hurtbox_damage_registered(_damage, _type, _pos):
	animation_hit.play("Hit")
	total_hit += 1
	if total_hit >= 2:
		portal.visible = true
