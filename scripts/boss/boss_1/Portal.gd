extends Sprite2D

signal portal_opened()
signal portal_closed()


func open_portal_end():
	emit_signal("portal_opened")


func close_portal_end():
	emit_signal("portal_closed")
