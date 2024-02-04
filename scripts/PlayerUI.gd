extends CanvasLayer

@onready var hp_bar := $PlayerStatus/HP/HP_Bar
@onready var mp_bar := $PlayerStatus/MP/MP_Bar
@onready var face_normal := $PlayerStatus/Face/Face_Normal
@onready var face_damaged := $PlayerStatus/Face/Face_Damaged
@onready var damaged_timer := $DamagedTimer

const HP_MAX_SIZE = 70.0
const MP_MAX_SIZE = 60.0


func _on_player_hp_changed(current_hp, damaged):
	var tween := create_tween()
	tween.tween_property(hp_bar, "size:x", (HP_MAX_SIZE / 10) * current_hp, 0.2)
	#hp_bar.size.x = (HP_MAX_SIZE / 10) * current_hp
	
	if damaged:
		face_normal.visible = false
		face_damaged.visible = true
		damaged_timer.start()


func _on_player_mp_changed(current_mp):
	mp_bar.size.x = (MP_MAX_SIZE / 100) * current_mp


func _on_damaged_timer_timeout():
	face_normal.visible = true
	face_damaged.visible = false
