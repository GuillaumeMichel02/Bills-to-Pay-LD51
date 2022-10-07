extends StaticBody2D

signal chest_opened()

signal item_sold()

var all_out = false


func hit(item):
	if item == "Nothing" and !all_out:
		emit_signal("chest_opened")
		return
	if item != "Nothing":
		emit_signal("item_sold")

func get_interaction_cursor(item):
	if all_out:
		$Cursor.animation = "red"
	if item == "Nothing":
		$Cursor.animation = "white"
	else:
		$Cursor.animation = "green"
	$Cursor/AnimationPlayer.play("cursor")
	$Cursor.visible = true

func remove_interaction_cursor():
	$Cursor.visible = false
