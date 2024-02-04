extends CanvasLayer

@onready var durability_label := $WeaponStatus/Durability/Label


func update_durability_label(new_durability):
	durability_label.text = str(new_durability)+"%"


func _on_weapon_durability_changed(current_durability):
	update_durability_label(current_durability)
