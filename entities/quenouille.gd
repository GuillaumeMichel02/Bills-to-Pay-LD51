extends StaticBody2D

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)
signal quenouille_multiplied

@export var item_id: int = 12
@export var amount: int = 3
var entity_position_memory: Array
var quenouille_test = true


	
func _on_countdown_restart():
	if randi()%8 == 0:
		emit_signal("quenouille_multiplied")
		
func hit(item):
	if item not in ["Sword", "Axe", "Pickaxe"]:
		emit_signal("player_got_something", item_id, amount)
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
