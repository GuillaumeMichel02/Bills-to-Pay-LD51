extends StaticBody2D

signal has_been_destroyed(body)
signal spawn_flower(body, item_id,amount)
signal monster_interacted(body, difficulty)
signal item_used()
var got_gold = false
var got_monster = false
var health = 2
var aimed_by_player = false


func _on_countdown_restart():
	var tiled_children = get_children()
	for entity in tiled_children:
		if entity.is_in_group("world_entities"):
			entity._on_countdown_restart()
	var flower_id
	var amount
	var rand = randi()
	if got_gold:
		if rand%8==0:
			flower_id = 9
			amount = 1	
			emit_signal("spawn_flower",self,flower_id,amount)
			emit_signal("has_been_destroyed", self)	
	elif rand%6==0:
		rand = randi()%20
		if rand == 0:
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
	if item=="Monster Fertilizer" and !got_monster:
		got_monster = true
		emit_signal("monster_interacted", self, 1)
	if item=="Gold Ore" and !got_gold:
		got_gold = true
		emit_signal("item_used")

func get_interaction_cursor(item):
	if (item == "Monster Fertilizer" and !got_monster) or (item =="Gold Ore" and !got_gold):
		$Cursor.animation = "green"
		$Cursor/AnimationPlayer.play("cursor")
		$Cursor.visible = true
	else:
		$Cursor.visible = false
func remove_interaction_cursor():
	$Cursor.visible = false
		
func position_array():
	return [position]
