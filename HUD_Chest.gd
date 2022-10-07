extends Control

signal give_item_current()
signal chest_quit()
signal chestbar_left_signal()
signal chestbar_right_signal()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	#Player wants to do an action and isn't already doing it
	if !get_tree().paused or !self.visible:
		return
	if event.is_pressed() and event.is_action("action"):
		emit_signal("give_item_current")
		emit_signal("chest_quit")
		
	if event.is_pressed() and event.is_action("hotbar_left"):
		emit_signal("chestbar_left_signal")
		
	if event.is_pressed() and event.is_action("hotbar_right"):
		emit_signal("chestbar_right_signal")
