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
		health = randi()%5 + 1
func hit(item):
	if item == "Pickaxe":
		$/root/AudioManager.play_sound("mining")
		health -= 1
		if health == 0:
			if is_gold:
				is_gold = false
				$RockSprite.animation = "Default"
				health = 1
				emit_signal("player_got_something", 14, 1)
			else:
				$/root/AudioManager.play_sound("broke")
				emit_signal("player_got_something", 15, randi()%4)
				emit_signal("has_been_destroyed", self)
				
		$AnimationPlayer.play("hit")
		print(health)

func position_array():
	return [position]
