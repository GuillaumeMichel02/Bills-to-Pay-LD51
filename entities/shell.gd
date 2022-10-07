extends StaticBody2D


signal player_got_something(item_id, amount)
signal has_been_destroyed(body)

@export var item_id: int = 0
var aimed_by_player = false

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

func get_interaction_cursor(item):
	if item not in ["Sword", "Axe", "Pickaxe"]:
		$Cursor.animation = "white"
	else:
		$Cursor.animation = "red"
	$Cursor/AnimationPlayer.play("cursor")
	$Cursor.visible = true

func remove_interaction_cursor():
	$Cursor.visible = false
		
func position_array():
	return [position]

