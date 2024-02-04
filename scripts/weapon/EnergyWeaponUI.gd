extends CanvasLayer

@onready var energy_label := $WeaponStatus/Energy/Label


func update_energy_label(energy: float):
	energy_label.text = str(round(energy)) + "%"


func _on_blaster_energy_updated(current_energy):
	update_energy_label(current_energy)
