extends StaticBody2D

@export var has_fruits: bool = false
@export var is_withered: bool = false
var entity_position_memory: Array
var health = 2
var got_monster = false

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)
signal monster_interacted(body, difficulty)
signal bush_evolved(body)

func _ready():
	var rand = randi()%32
	if rand == 0:
		has_fruits = false
		is_withered = true
		$AnimatedSprite2d.animation = "Withered"
		health = 1
	elif rand < 5:
		has_fruits = true
		$AnimatedSprite2d.animation = "Fruits"
		health = 3

	
func _on_countdown_restart():
	var bush_children = get_children()
	for entity in bush_children:
		if entity.is_in_group("world_entities"):
			entity._on_countdown_restart()
	if is_withered:
		return
	var rand = randi()%32
	if rand == 0:
		has_fruits = false
		is_withered = true
		$AnimatedSprite2d.animation = "Withered"
		health = 1
	elif rand < 5:
		has_fruits = true
		$AnimatedSprite2d.animation = "Fruits"
		health = 3


func hit(item):
	if item == "Monster Fertilizer" and is_withered and !got_monster:
		emit_signal("monster_interacted", self, 1)
		got_monster = true
		return
		
	if (item == "Sword" or item == "Axe") and !is_withered:
		$/root/AudioManager.play_sound("broke")
		if has_fruits:
			emit_signal("player_got_something", 7, randi()%3+4)
		has_fruits = false
		is_withered = true
		$AnimatedSprite2d.animation = "Withered"
		health = 1
		return
		
	if item != "Pickaxe" and item != "Hoe" and item != "Fishing Rod":
		health -= 1
		if has_fruits:
			emit_signal("player_got_something", 7, 1+randi()%2)
		if health == 0:
			if has_fruits:
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
		
func get_interaction_cursor(item):
	if item == "Monster Fertilizer" and is_withered:
		$Cursor.animation = "green"
		$Cursor/AnimationPlayer.play("cursor")
		$Cursor.visible = true
	elif item != "Pickaxe" and item != "Hoe" and item != "Fishing Rod":
		if is_withered:
			$Cursor.animation = "red"
		else:
			$Cursor.animation = "white"
		$Cursor/AnimationPlayer.play("cursor")
		$Cursor.visible = true
	else:
		$Cursor.visible = false

func remove_interaction_cursor():
	$Cursor.visible = false
		
func evolve():
	emit_signal("bush_evolved", self)
	emit_signal("has_been_destroyed", self)

func position_array():
	return [position]
