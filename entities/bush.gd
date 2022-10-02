extends StaticBody2D

@export var has_fruits: bool = false
@export var is_withered: bool = false
var entity_position_memory: Array
var health = 2

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)
signal monster_interacted(body, difficulty)

	
func _on_countdown_restart():
	var bush_children = get_children()
	for entity in bush_children:
		if entity.is_in_group("world_entities"):
			entity._on_countdown_restart()
	if is_withered:
		return
	if randi()%8 == 0:
		has_fruits = true
		$AnimatedSprite2d.animation = "Fruits"
		health = 4
	elif randi()%30 == 0:
		has_fruits = false
		is_withered = true
		$AnimatedSprite2d.animation = "Withered"
		health = 1


func hit(item):
	if item == "Monster Fertilizer":
		if is_withered:
			emit_signal("monster_interacted", self, 2)
		return
		
	if (item == "Sword" or item == "Axe") and !is_withered:
		$/root/AudioManager.play_sound("broke")
		if has_fruits:
			emit_signal("player_got_something", 7, randi()%3+2)
		has_fruits = false
		is_withered = true
		$AnimatedSprite2d.animation = "Withered"
		health = 1
		return
		
	if item != "Pickaxe" and item != "Hoe" and item != "Fishing Rod":
		health -= 1
		if health == 0:
			if has_fruits:
				emit_signal("player_got_something", 7, randi()%3+2)
				has_fruits = false
				$AnimatedSprite2d.animation = "Default"
				health = 2
			elif !is_withered:
				$/root/AudioManager.play_sound("broke")
				is_withered = true
				$AnimatedSprite2d.animation = "Withered"
				health = 1
			else:
				$/root/AudioManager.play_sound("broke")
				emit_signal("has_been_destroyed", self)
				
		$AnimationPlayer.play("hit")
		print(health, item)

func evolve():
	if is_withered:
		is_withered = false
		$AnimatedSprite2d.animation = "Default"
		health = 2

func position_array():
	return [position]
