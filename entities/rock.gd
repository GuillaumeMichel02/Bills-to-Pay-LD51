extends StaticBody2D

@export var is_gold: bool = false
var entity_position_memory: Array
var health = 4

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)

	
func _on_countdown_restart():
	if randi()%10 == 0:
		is_gold = true
		$RockSprite.animation = "Gold"
		health = randi()%3 + 1
		

func hit(item):
	if item == "Pickaxe":
		$/root/AudioManager.play_sound("mining")
		health -= 1

		if health == 0:
			if is_gold:
				is_gold = false
				$RockSprite.animation = "Default"
				health = 1
				emit_signal("player_got_something", 14, 1 + randi()%3)
				$Cursor.animation = "red"
			else:
				$/root/AudioManager.play_sound("broke")
				emit_signal("player_got_something", 15, randi()%4)
				emit_signal("has_been_destroyed", self)
		$AnimationPlayer.play("hit")
		
	elif item == "Axe":
		$/root/AudioManager.play_sound("mining")
		var rand = randi()%30
		if rand <= 0 + int(is_gold)*2:
			emit_signal("player_got_something", 14, 1)
		elif rand < 10:
			emit_signal("player_got_something", 15, 1)
		$AnimationPlayer.play("hit")

func get_interaction_cursor(item):
	if item == "Pickaxe":
		if health == 1 and !is_gold:
			$Cursor.animation = "red"
		else:
			$Cursor.animation = "white"
		$Cursor/AnimationPlayer.play("cursor")
		$Cursor.visible = true
	elif item == "Axe":
		$Cursor.animation = "white"
		$Cursor/AnimationPlayer.play("cursor")
		$Cursor.visible = true
	else:
		$Cursor.visible = false

func remove_interaction_cursor():
	$Cursor.visible = false


func position_array():
	return [position]
