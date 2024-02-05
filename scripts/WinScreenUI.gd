extends CanvasLayer

@onready var eye_close := $Control/TextureButton/EyeClose
@onready var eye_open := $Control/TextureButton/EyeOpen

var main_menu_scn := "res://scenes/start_menu.tscn"


func _on_texture_button_mouse_entered():
	eye_close.visible = false
	eye_open.visible = true


func _on_texture_button_mouse_exited():
	eye_close.visible = true
	eye_open.visible = false


func _on_texture_button_pressed():
	get_tree().change_scene_to_file(main_menu_scn)
