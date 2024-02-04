extends CanvasLayer

@onready var ammo_label := $WeaponStatus/Ammo/Label

func update_ammo_label(new_magazine:int, new_total_bullets:int):
	var new_magazine_str := str(new_magazine)
	if new_magazine < 10:
		new_magazine_str = "0"+new_magazine_str
	
	var new_total_bullets_str := str(new_total_bullets)
	if new_total_bullets < 10:
		new_total_bullets_str = "0"+new_total_bullets_str
	
	ammo_label.text = "%s | %s" % [new_magazine_str, new_total_bullets_str]


func _on_pistol_bullets_updated(current_magazine, current_total_bullets):
	update_ammo_label(current_magazine, current_total_bullets)
