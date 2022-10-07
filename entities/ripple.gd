extends StaticBody2D


signal player_got_something(item_id, amount)
signal has_been_destroyed(body)



	
func _on_countdown_restart():
	emit_signal("has_been_destroyed", self)
		
func hit(item):
	if item == "Fishing Rod":
		var rand = randi()%20
		if rand < 3:
			$AnimationPlayer.play("Fishing Epic Success")
			emit_signal("player_got_something", 20, 1)
		elif rand < 15:
			$AnimationPlayer.play("Fishing Success")
			emit_signal("player_got_something", 13, 1)	
		else:
			$AnimationPlayer.play("Fishing Failure")
			
func get_interaction_cursor(item):
	if item == "Fishing Rod":
		$Cursor.animation = "white"
		$Cursor/AnimationPlayer.play("cursor")
		$Cursor.visible = true
	else:
		$Cursor.visible = false

func remove_interaction_cursor():
	$Cursor.visible = false

func position_array():
	return [position]


func _on_animation_player_animation_finished(_anim_name):
	emit_signal("has_been_destroyed", self)
