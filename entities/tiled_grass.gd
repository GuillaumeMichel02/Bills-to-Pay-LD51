extends StaticBody2D

signal has_been_destroyed(body)
signal spawn_flower(body, item_id,amount)
signal monster_interacted(body, difficulty)
signal item_used()
var got_gold = false
var health = 2


func _on_countdown_restart():
	var tiled_children = get_children()
	for entity in tiled_children:
		if entity.is_in_group("world_entities"):
			entity._on_countdown_restart()
	if randi()%10==0:
		var rand = randi()%20
		var flower_id = 0
		var amount
		if got_gold or rand == 0:
			flower_id = 9
			amount = 1
		elif rand < 6:
			flower_id = 11
			amount = 2
		elif rand < 13:
			flower_id = 8
			amount = 2
		elif rand < 19:
			flower_id = 10
			amount = 3
		else:
			emit_signal("has_been_destroyed", self)
			return
		emit_signal("spawn_flower",self,flower_id,amount)
		emit_signal("has_been_destroyed", self)	

func _on_destruction_collision_body_entered(_body):
	health -= 1
	if health == 0:
		$/root/AudioManager.play_sound("broke")
		emit_signal("has_been_destroyed", self)
	
func evolve():
	var rand = randi()%20
	var flower_id = 0
	var amount
	if got_gold or rand == 0:
		flower_id = 9
		amount = 2
	elif rand < 6:
		flower_id = 11
		amount = 4
	elif rand < 13:
		flower_id = 8
		amount = 4
	elif rand < 19:
		flower_id = 10
		amount = 6
	else:
		emit_signal("has_been_destroyed", self)
		return
	emit_signal("spawn_flower",self,flower_id,amount)
	emit_signal("has_been_destroyed", self)	
	
func hit(item):
	if item=="Monster Fertilizer":
		emit_signal("monster_interacted", self, 2)
	if item=="Gold Ore" and !got_gold:
		got_gold = true
		emit_signal("item_used")
		
func position_array():
	return [position]
