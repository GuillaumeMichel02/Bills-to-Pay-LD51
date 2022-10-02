extends StaticBody2D

@export var is_cut: bool = false
var entity_position_memory: Array
var health = 3

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)
signal has_brought_birdie(position)

	
func _on_countdown_restart():
	if randi()%16 == 0:
		if is_cut:
			emit_signal("has_brought_birdie", Vector2(position.x, position.y - 30))
			
func hit(item):
	if item == "Axe":
		health -= 1
		if health == 0:
			$/root/AudioManager.play_sound("broke")
			if is_cut:
				if randi()%2==0:
					emit_signal("player_got_something", 6, 1)
					
				emit_signal("has_been_destroyed", self)
			else:
				emit_signal("player_got_something", 6, randi()%3+1)
				is_cut = true
				$TreeTop.visible = false
				$TreeBase.animation = "Cut"
				health = 1
				
		$AnimationPlayer.play("hit")
		print(health)
		
func position_array():
	return [Vector2(position.x-32,position.y), Vector2(position.x+32,position.y)]
