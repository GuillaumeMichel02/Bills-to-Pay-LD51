extends StaticBody2D


signal player_got_something(item_id, amount)
signal has_been_destroyed(body)

@export var item_id: int = 0

func set_information(pos, shell_id, shell_name):
	position = pos
	item_id = shell_id
	$ShellSprite.animation = shell_name

	
func _on_countdown_restart():
	pass
		
func hit(item):
	if item not in ["Sword", "Axe", "Pickaxe"]:
		emit_signal("player_got_something", item_id, 1)
	else:
		$/root/AudioManager.play_sound("broke")
	emit_signal("has_been_destroyed", self)

			
		
func position_array():
	return [position]

