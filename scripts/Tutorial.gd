extends CanvasLayer

@onready var tutorial_sprite = $Tutorial

var tutorial = [
	preload("res://assets/UI/tutorial1.png"),
	preload("res://assets/UI/tutorial2.png"),
	preload("res://assets/UI/tutorial3.png")
]
var idx = 0


func _ready():
	get_tree().paused = true


func _input(event):
	if event.is_action_pressed("ui_attack"):
		idx += 1
		if idx > 2:
			get_tree().paused = false
			queue_free()
		
		else:
			tutorial_sprite.texture = tutorial[idx]
