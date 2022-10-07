extends Node

signal countdown_restart
signal remap_step_done



var total_time: float = 0
var is_game_over = false
var is_game_beginning = true 
var is_game_paused = false
var is_game_remapping = false
var is_game_remapped = false
var game_mode = 0
var game_modes = ["Rush 500", "Rush 2000", "Survival"]
var max_time_survival = 0.0
var min_time_rush500 = 0.0
var min_time_rush2000 = 0.0
var money_amount: int = 60
var money_loss: int = 10
var money_max: int = 60
var player_hurt: bool = false
var monster_alive: bool = false
var hotbar_current: int = 0
var hotbar_array: Array
var chestbar_current: int = 0
var chestbar_array: Array
var entity_positions: Array
var DROP_ITEMS = load("res://entities/drop_item.tscn")
var BIRDIE = load("res://entities/birdie.tscn")
var rocks = load("res://entities/rock.tscn")
var trees = load("res://entities/tree.tscn")
var bushes = load("res://entities/bush.tscn")
var flowers = load("res://entities/flower.tscn")
var quenouilles = load("res://entities/quenouille.tscn")
var quenouille_counter: int = 2
var ripples = load("res://entities/ripple.tscn")
var shells = load("res://entities/shell.tscn")
var slimes = load("res://entities/slime.tscn")
var slime_spawns = [Vector2(64,128), Vector2(1500,200), Vector2(1850,900)]
var monster_ferts = load("res://entities/monster_fertilizer.tscn")
var tiled_grasses = load("res://entities/tiled_grass.tscn")

var config_:Config

func save_game_mode():
	config_.game_mode = game_mode
	ResourceSaver.save(config_, "user://config.tres")
func save_mute():
	config_.is_mute = AudioServer.is_bus_mute(0)
	ResourceSaver.save(config_, "user://config.tres")
func save_max_time_survival(time):
	config_.max_time_survival = (snapped(time,0.001))
	ResourceSaver.save(config_, "user://config.tres")
func save_min_time_rush_500(time):
	config_.min_time_rush_500 = (snapped(time,0.001))
	ResourceSaver.save(config_, "user://config.tres")
func save_min_time_rush_1000(time):
	config_.min_time_rush_1000 = (snapped(time,0.001))
	ResourceSaver.save(config_, "user://config.tres")
func save_is_remapped(is_remapped):
	config_.is_remapped = is_remapped
	ResourceSaver.save(config_, "user://config.tres")
func save_input_map():
	config_.input_map = CustomInputManager.save_key_dict
	ResourceSaver.save(config_, "user://config.tres")
	
func load_():
	config_ = load("user://config.tres")
	if not config_:
		config_ = Config.new()
	game_mode = config_.game_mode
	game_mode_changes()
	AudioServer.set_bus_mute(0, config_.is_mute)
	max_time_survival = config_.max_time_survival
	min_time_rush500 = config_.min_time_rush500
	min_time_rush2000 = config_.min_time_rush2000
	if config_.is_remapped:
		$CanvasLayer2/TitleScreen/ResetInputs.visible = true
		for action in config_.input_map:
			CustomInputManager.set_event(config_.input_map[action])
			CustomInputManager.set_event_to_action(action)
		CustomInputManager.save_key_dict.clear()
		is_game_remapped = true
		

func game_mode_changes():
	if game_mode == 0:
		$CanvasLayer2/TitleScreen/GameMode.text = "Rush 500 (G to change)"
		$CanvasLayer2/TitleScreen/Money3.text = "Help Billy getting $500"
		$CanvasLayer/HUD_InGame/Objective.text = "/500"
	if game_mode == 1:
		$CanvasLayer2/TitleScreen/GameMode.text = "Rush 2000 (G to change)"
		$CanvasLayer2/TitleScreen/Money3.text = "Help Billy getting $2000"
		$CanvasLayer/HUD_InGame/Objective.text = "/2000"
	if game_mode == 2:
		$CanvasLayer2/TitleScreen/GameMode.text = "Survival (G to change)"
		$CanvasLayer2/TitleScreen/Money3.text = "Help Billy survive his increasing debts"
		$CanvasLayer/HUD_InGame/Objective.text = ""

#Item names and prices from ID
var item_dict = {
	0 : Array(["Nothing", 0]),
	1 : Array(["Sword", 0]),
	2 : Array(["Axe", 0]),
	3 : Array(["Pickaxe", 0]),
	4 : Array(["Fishing Rod", 0]),
	5 : Array(["Hoe", 0]),
	6 : Array(["Wood", 5]),
	7 : Array(["Berry", 4]),
	8 : Array(["Heart Flower", 5]),
	9 : Array(["Gold Flower", 80]),
	10 : Array(["Purple Flower", 4]),
	11 : Array(["White Flower", 6]),
	12 : Array(["Quenouille", 8]),
	13 : Array(["Fish", 8]),
	14 : Array(["Gold Ore", 20]),
	15 : Array(["Rock", 2]),
	16 : Array(["Monster Fertilizer", 10]),
	17 : Array(["Conch", 5]),
	18 : Array(["Clam", 5]),
	19 : Array(["Gold Bird", 35]),
	20 : Array(["Gold Fish", 25])
}
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	load_()
	get_tree().paused = true
	$CanvasLayer/HUD_InGame/Money.text = "$60"
	$CanvasLayer/HUD_InGame/ProfitLoss.modulate.a = 0

		
	for i in range(7,10):
		entity_positions.push_back(Vector2(i*64+32,11*64+32))
	for i in range(19,25):
		entity_positions.push_back(Vector2(i*64+32,14*64+32))
	for i in range(0,2):
		for j in range(0,2):
			entity_positions.push_back(Vector2((8+i)*64+32,(15+j)*64+32))
	for i in range(0,8):
		entity_positions.push_back(Vector2(17*64+32,i*64+32))
	for i in range(9,12):
		entity_positions.push_back(Vector2(31*64+32,i*64+32))
		
		
	#HUD_InGame/Hotbar generation
	var hotslot = load("res://UI/hotslot.tscn")
	for i in range(0,8) :
		hotbar_array.push_back(hotslot.instantiate())
		hotbar_array[i].position.x = i*70
		$CanvasLayer/HUD_InGame/Hotbar.add_child(hotbar_array[i])

	hotbar_array[0].set_active(true)
	$Player/Tool/ToolSprite.animation = item_dict[hotbar_array[0].item_id][0]
	
	#Chestbar generation
	var chestslot = load("res://UI/chestslot.tscn")
	for i in range(0,6) :
		chestbar_array.push_back(chestslot.instantiate())
		chestbar_array[i].position.x = i*140
		$CanvasLayer/HUD_Chest/Chestbar.add_child(chestbar_array[i])
		if i == 0:
			chestbar_array[i].set_cancel()
		else:
			chestbar_array[i].set_item(i, item_dict[i][0], 5)
	
	chestbar_array[0].set_active(true)
	
	#Entity generation
	var rand_x
	var rand_y
	var good_position
	
	#Rocks
	for i in range(0,8) :
		var rock = rocks.instantiate()
		good_position = false

		while !good_position:
			rand_x = randi_range(19,31)*64+32
			rand_y = randi_range(0,7)*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		rock.position = Vector2(rand_x, rand_y)
		rock.connect("player_got_something", _on_player_got_something)
		rock.connect("has_been_destroyed", _on_has_been_destroyed)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.add_child(rock)
	
	#Trees
	for i in range(0,8):
		var tree = trees.instantiate()
		good_position = false
		
		while !good_position:
			rand_x = randi_range(0,16)*64+32
			rand_y = randi_range(2,10)*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)) and !entity_positions.has(Vector2(rand_x+64, rand_y)):
				good_position = true
		tree.position = Vector2(rand_x+32, rand_y)
		tree.connect("player_got_something", _on_player_got_something)
		tree.connect("has_been_destroyed", _on_has_been_destroyed)
		tree.connect("has_brought_birdie", _on_has_brought_birdie)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		entity_positions.push_back(Vector2(rand_x+64, rand_y))
		$WorldEntities.add_child(tree)
		
	#Bushes
	for i in range(0,12) :
		var bush = bushes.instantiate()
		good_position = false

		while !good_position:
			if i < 5:
				rand_x = randi_range(0,16)*64+32
				rand_y = randi_range(2,10)*64+32
			else:
				rand_x = randi_range(10,20)*64+32
				rand_y = randi_range(10,12)*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		bush.position = Vector2(rand_x, rand_y)
		bush.connect("player_got_something", _on_player_got_something)
		bush.connect("has_been_destroyed", _on_has_been_destroyed)
		bush.connect("monster_interacted", _on_monster_interacted)
		bush.connect("bush_evolved", _on_bush_evolved)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.add_child(bush)
		
	#Flowers
	#Gold
	var flower = flowers.instantiate()
	good_position = false
	
	while!good_position:
		rand_x = randi_range(9,13)*64+32
		rand_y = randi_range(0,6)*64+32
		if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
	flower.set_information(Vector2(rand_x, rand_y),9,"Gold Flower",1)
	flower.connect("player_got_something", _on_player_got_something)
	flower.connect("has_been_destroyed", _on_has_been_destroyed)
	entity_positions.push_back(Vector2(rand_x, rand_y))
	$WorldEntities.add_child(flower)
	#Heart
	for i in range(0,6):
		flower = flowers.instantiate()
		good_position = false
	
		while!good_position:
			rand_x = randi_range(0,31)*64+32
			rand_y = randi_range(0,12)*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		flower.set_information(Vector2(rand_x, rand_y),8,"Heart Flower",2)
		flower.connect("player_got_something", _on_player_got_something)
		flower.connect("has_been_destroyed", _on_has_been_destroyed)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.add_child(flower)
	#Purple
	for i in range(0,6):
		flower = flowers.instantiate()
		good_position = false
	
		while!good_position:
			rand_x = randi_range(0,31)*64+32
			rand_y = randi_range(0,12)*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		flower.set_information(Vector2(rand_x, rand_y),10,"Purple Flower",3)
		flower.connect("player_got_something", _on_player_got_something)
		flower.connect("has_been_destroyed", _on_has_been_destroyed)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.add_child(flower)

	for i in range(0,6):
		flower = flowers.instantiate()
		good_position = false
	
		while!good_position:
			rand_x = randi_range(0,16)*64+32
			rand_y = randi_range(2,10)*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		flower.set_information(Vector2(rand_x, rand_y),11,"White Flower",2)
		flower.connect("player_got_something", _on_player_got_something)
		flower.connect("has_been_destroyed", _on_has_been_destroyed)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.add_child(flower)
	#Quenouilles
	for i in range(0,2):
		var quenouille = quenouilles.instantiate()
		good_position = false
	
		while !good_position:
			var rand = randi_range(0,27)
			if rand < 24:
				rand_x = rand*64+32
				rand_y = 21*64+32
			else:
				rand_x = (rand+5)*64+32
				rand_y = 17*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		quenouille.position = Vector2(rand_x, rand_y)
		quenouille.connect("player_got_something", _on_player_got_something)
		quenouille.connect("has_been_destroyed", _on_has_been_destroyed)
		quenouille.connect("quenouille_multiplied", _on_quenouille_multiplied)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.add_child(quenouille)
	
	#Ripples
	for i in range(0,3):
		var ripple = ripples.instantiate()
		good_position = false
	
		while !good_position:
			var rand = randi_range(0,27)
			if rand < 24:
				rand_x = rand*64+32
				rand_y = 21*64+32
			else:
				rand_x = (rand+5)*64+32
				rand_y = 17*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		ripple.position = Vector2(rand_x, rand_y)
		ripple.connect("player_got_something", _on_player_got_something)
		ripple.connect("has_been_destroyed", _on_has_been_destroyed)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.add_child(ripple)
		
	#Shells
	var shell = shells.instantiate()
	shell.set_information(Vector2(736,1120),18,"Clam")
	shell.connect("player_got_something", _on_player_got_something)
	shell.connect("has_been_destroyed", _on_has_been_destroyed)
	entity_positions.push_back(Vector2(736,1120))
	$WorldEntities.add_child(shell)	
	
	for i in range(0,6):
		shell = shells.instantiate()
		good_position = false
	
		while!good_position:
			rand_x = randi_range(0,24)*64+32
			rand_y = randi_range(17,20)*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		if randi()%6<3:
			shell.set_information(Vector2(rand_x, rand_y),18,"Clam")
		else:
			shell.set_information(Vector2(rand_x, rand_y),17,"Conch")
		shell.connect("player_got_something", _on_player_got_something)
		shell.connect("has_been_destroyed", _on_has_been_destroyed)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.add_child(shell)

	
func _on_countdown_player_animation_finished(_anim_name):
	money_amount -= money_loss
	if money_amount < 0:
		money_amount = 0
	$CanvasLayer/HUD_InGame/Money.text = "$"+str(money_amount)
	$CanvasLayer/HUD_InGame/ProfitLoss.text = "-"+str(money_loss)
	$CanvasLayer/HUD_InGame/ProfitLoss.modulate.r = 1
	$CanvasLayer/HUD_InGame/ProfitLoss.modulate.g = 0
	$CanvasLayer/HUD_InGame/ProfitLoss.modulate.b = 0	
	$CanvasLayer/HUD_animation.stop()
	$CanvasLayer/HUD_animation.play("loss")
	$/root/AudioManager.play_sound("gold_lose")
	
	if money_amount <= 20:
		$CanvasLayer/HUD_InGame/Sprite2d.modulate.a = 0.4 - money_amount/50.0
		if $PlayerSpeedBoost.is_stopped():
			$BackgroundMusic.set_pitch_scale(0.80 + money_amount/100.0)
	else:
		$CanvasLayer/HUD_InGame/Sprite2d.modulate.a = 0
		if $PlayerSpeedBoost.is_stopped():
			$BackgroundMusic.set_pitch_scale(1.0)
		
	if game_mode == 2 and money_loss < 50:
		money_loss += 1
	$CanvasLayer/HUD_InGame/Rent.text = "-"+str(money_loss)
		
	if money_amount == 0:
		game_over()
	for entity in $WorldEntities.get_children():
		entity._on_countdown_restart()

	fish_move()
	#Slime
	if !monster_alive:
		var slime = slimes.instantiate()
		slime_spawns.shuffle()
		slime.position = slime_spawns[0]
		slime.connect("player_got_something", _on_player_got_something)
		slime.connect("has_been_destroyed", _on_has_been_destroyed)
		slime.connect("item_used", _on_item_used)
		slime.connect("player_hurt", _on_player_hurt)
		monster_alive = true
		$WorldEntities.add_child(slime)
		
	
	$CountdownPlayer.play()

func _physics_process(_delta):
	var hit_entities = $Player/InteractionCheck.get_overlapping_bodies()
	var item = item_dict[hotbar_array[hotbar_current].item_id][0]
	if hit_entities.is_empty():
		if item == "Hoe" or item == "Monster Fertilizer":
			var pos = get_player_front_tile()
			$PlayerGroundCursor.position = pos
			$PlayerGroundCursor.visible = true
		return

	$PlayerGroundCursor.visible = false

func _on_player_interaction_check_body_entered(body):
	if body.is_in_group("world_entities"):
		body.get_interaction_cursor(item_dict[hotbar_array[hotbar_current].item_id][0])

func _on_player_interaction_check_body_exited(body):
	if body.is_in_group("world_entities"):
		body.remove_interaction_cursor()


func _on_player_hotbar_left_signal():
	hotbar_array[hotbar_current].set_active(false)
	hotbar_current = hotbar_current - 1
	if hotbar_current < 0:
		hotbar_current = 7
	hotbar_array[hotbar_current].set_active(true)
	if hotbar_array[hotbar_current].item_id > 0 and hotbar_array[hotbar_current].item_id < 6:
		$Player/Tool/ToolSprite.animation = item_dict[hotbar_array[hotbar_current].item_id][0]
	else:
		$Player/Tool/ToolSprite.animation = "Nothing"
	var hit_entities = $Player/InteractionCheck.get_overlapping_bodies()
	for entity in hit_entities:
		if entity.is_in_group("world_entities"):
			entity.get_interaction_cursor(item_dict[hotbar_array[hotbar_current].item_id][0])
	
	$/root/AudioManager.play_sound("menuselect1")


func _on_player_hotbar_right_signal():
	hotbar_array[hotbar_current].set_active(false)
	hotbar_current = hotbar_current + 1
	if hotbar_current > 7:
		hotbar_current = 0
	hotbar_array[hotbar_current].set_active(true)
	item_dict[hotbar_array[hotbar_current].item_id][0] = item_dict[hotbar_array[hotbar_current].item_id][0]
	if hotbar_array[hotbar_current].item_id > 0 and hotbar_array[hotbar_current].item_id < 6:
		$Player/Tool/ToolSprite.animation = item_dict[hotbar_array[hotbar_current].item_id][0]
	else:
		$Player/Tool/ToolSprite.animation = "Nothing"
	var hit_entities = $Player/InteractionCheck.get_overlapping_bodies()
	for entity in hit_entities:
		if entity.is_in_group("world_entities"):
			entity.get_interaction_cursor(item_dict[hotbar_array[hotbar_current].item_id][0])
			
	$/root/AudioManager.play_sound("menuselect1")

	
func _on_player_has_hit_something(body):
	if body.is_in_group("world_entities"):
		body.call("hit", item_dict[hotbar_array[hotbar_current].item_id][0])

func _on_has_brought_birdie(pos):
	if entity_positions.has(pos):
		return
	var birdie = BIRDIE.instantiate()
	birdie.position = pos
	$WorldEntities.call_deferred("add_child", birdie)
	birdie.connect("player_got_something", _on_player_got_something)
	birdie.connect("has_been_destroyed", _on_has_been_destroyed)
	$/root/AudioManager.play_sound("birdnoise")
	
func _on_quenouille_multiplied():
	if quenouille_counter < 10:
		var quenouille = quenouilles.instantiate()
		var good_position = false
		var rand_x
		var rand_y
		while !good_position:
			var rand = randi_range(0,27)
			if rand < 24:
				rand_x = rand*64+32
				rand_y = 21*64+32
			else:
				rand_x = (rand+5)*64+32
				rand_y = 17*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		quenouille.position = Vector2(rand_x, rand_y)
		quenouille.connect("player_got_something", _on_player_got_something)
		quenouille.connect("has_been_destroyed", _on_has_been_destroyed)
		quenouille.connect("quenouille_multiplied", _on_quenouille_multiplied)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		quenouille_counter += 1
		$WorldEntities.call_deferred("add_child",quenouille)

func fish_move():
	for i in range(0,3):
		var ripple = ripples.instantiate()
		var good_position = false
		var rand_x
		var rand_y
		
		while !good_position:
			var rand = randi_range(0,27)
			
			if rand < 24:
				rand_x = rand*64+32
				rand_y = 21*64+32
			else:
				rand_x = (rand+5)*64+32
				rand_y = 17*64+32
			if !entity_positions.has(Vector2(rand_x, rand_y)):
				good_position = true
		ripple.position = Vector2(rand_x, rand_y)
		ripple.connect("player_got_something", _on_player_got_something)
		ripple.connect("has_been_destroyed", _on_has_been_destroyed)
		entity_positions.push_back(Vector2(rand_x, rand_y))
		$WorldEntities.call_deferred("add_child",ripple)
		
func _on_player_got_something(item_id, amount):
	for i in range(0,8):
		if hotbar_array[i].item_id == item_id:
			hotbar_array[i].give_amount(amount)
			$/root/AudioManager.play_sound("normal_hit2")
			return
	for i in range(0,8):
		if hotbar_array[i].item_id == 0:
			hotbar_array[i].set_item(item_id, item_dict[item_id][0], amount)
			$/root/AudioManager.play_sound("normal_hit2")
			return
	var drop_position = get_player_tile()
	if entity_positions.has(drop_position):
		return
	var drop_item = DROP_ITEMS.instantiate()
	drop_item.get_information(drop_position, item_id, item_dict[item_id][0], amount)
	drop_item.connect("player_got_something", _on_player_got_something)
	drop_item.connect("has_been_destroyed", _on_has_been_destroyed)
	entity_positions.push_back(drop_position)
	$WorldEntities.call_deferred("add_child",drop_item)
			
func get_player_tile():
	var player_tile: Vector2 = Vector2(0,0)
	player_tile.x = floor($Player.position.x/64)*64 + 32
	player_tile.y = floor(($Player.position.y + 37)/64)*64 + 32
	return player_tile
	#player_tile.x = $Player
	
func get_player_front_tile():
	var player_tile = get_player_tile()
	if $Player.direction_name == "right":
		player_tile.x += 64
	if $Player.direction_name == "left":
		player_tile.x -= 64
	if $Player.direction_name == "up":
		player_tile.y -= 64
	if $Player.direction_name == "down":
		player_tile.y += 64
	return player_tile

	
func _on_has_been_destroyed(body):
	for pos in body.position_array():
		entity_positions.erase(pos)
	if body.is_in_group("Quenouille"):
		quenouille_counter -= 1
	elif body.is_in_group("Ennemy"):
		monster_alive = false
	body.queue_free()

func _on_item_used():
	hotbar_array[hotbar_current].give_amount(-1)
	
func _on_spawn_flower(body, flower_id, amount):
	var flower = flowers.instantiate()
	flower.set_information(body.position,flower_id,item_dict[flower_id][0],amount)
	flower.connect("player_got_something", _on_player_got_something)
	flower.connect("has_been_destroyed", _on_has_been_destroyed)
	entity_positions.push_back(body.position)
	$WorldEntities.call_deferred("add_child",flower)

func _on_player_has_interacted_with_ground():
	var player_tile = get_player_front_tile()
	var tile_pos = $TileMap.local_to_map(player_tile)
	var tile = $TileMap.get_cell_tile_data(0, tile_pos)
	if entity_positions.has(player_tile):
		return
	var item = item_dict[hotbar_array[hotbar_current].item_id][0]
	if item == "Hoe":
		if !tile:
			return
		if tile.get_custom_data("name") != "G":
			return
		var tiled_grass = tiled_grasses.instantiate()
		tiled_grass.position = player_tile
		tiled_grass.connect("monster_interacted", _on_monster_interacted)
		tiled_grass.connect("has_been_destroyed", _on_has_been_destroyed)
		tiled_grass.connect("item_used", _on_item_used)
		tiled_grass.connect("spawn_flower", _on_spawn_flower)
		entity_positions.push_back(player_tile)
		$WorldEntities.call_deferred("add_child",tiled_grass)
	elif item == "Heart Flower":
		$CountdownPlayer.advance(-5)
		_on_item_used()
	elif item == "White Flower":
		$Player.speed = 450
		if $PlayerSpeedBoost.is_stopped():
			$BackgroundMusic.set_pitch_scale($BackgroundMusic.pitch_scale*1.5)
		$PlayerSpeedBoost.start()
	elif item == "Monster Fertilizer":
		if !tile:
			return
		if tile.get_custom_data("name") == "":
			return
		var monster_fert = monster_ferts.instantiate()
		monster_fert.position = player_tile
		monster_fert.set_ground(tile.get_custom_data("name"))
		monster_fert.connect("monster_effect_ground", _on_monster_effect_ground)
		monster_fert.connect("has_been_destroyed", _on_has_been_destroyed)
		_on_item_used()
		$WorldEntities.call_deferred("add_child",monster_fert)
		
func _on_monster_interacted(body, difficulty):
	var monster_fert = monster_ferts.instantiate()
	body.call_deferred("add_child",monster_fert)
	monster_fert.used_on_entity = body
	monster_fert.difficulty = difficulty
	monster_fert.connect("monster_effect_entity", _on_monster_effect_entity)
	monster_fert.connect("has_been_destroyed", _on_has_been_destroyed)
	_on_item_used()

func _on_monster_effect_ground(body, tile_name):
	if tile_name == "G":
		var bush = bushes.instantiate()
		bush.position = body.position
		bush.connect("player_got_something", _on_player_got_something)
		bush.connect("has_been_destroyed", _on_has_been_destroyed)
		bush.connect("monster_interacted", _on_monster_interacted)
		bush.connect("bush_evolved", _on_bush_evolved)
		$WorldEntities.call_deferred("add_child",bush)
	elif tile_name == "S":
		var shell = shells.instantiate()
		if randi()%6<3:
			shell.set_information(body.position,18,"Clam")
		else:
			shell.set_information(body.position,17,"Conch")
		shell.connect("player_got_something", _on_player_got_something)
		shell.connect("has_been_destroyed", _on_has_been_destroyed)
		$WorldEntities.call_deferred("add_child",shell)
	else:
		var rock = rocks.instantiate()
		rock.position = body.position
		rock.connect("player_got_something", _on_player_got_something)
		rock.connect("has_been_destroyed", _on_has_been_destroyed)
		$WorldEntities.call_deferred("add_child",rock)
	entity_positions.push_back(body.position)

func _on_monster_effect_entity(body):
	body.evolve()

func _on_bush_evolved(body):
	var pos1 = body.position
	var pos2 = Vector2(0,0)
	var pos_right = Vector2(body.position.x + 64, body.position.y)
	var pos_left = Vector2(body.position.x - 64, body.position.y)
	if !entity_positions.has(pos_right):
		pos2 = pos_right
	elif !entity_positions.has(pos_left):
		pos2 = pos_left
	
	if pos2 != Vector2(0,0):
		var tree = trees.instantiate()
		tree.position = Vector2((pos1.x + pos2.x)/2,pos1.y)
		tree.connect("player_got_something", _on_player_got_something)
		tree.connect("has_been_destroyed", _on_has_been_destroyed)
		tree.connect("has_brought_birdie", _on_has_brought_birdie)
		entity_positions.push_back(pos1)
		entity_positions.push_back(pos2)
		$WorldEntities.add_child(tree)
	else:
		var bush = bushes.instantiate()
		bush.position = pos1
		bush.connect("player_got_something", _on_player_got_something)
		bush.connect("has_been_destroyed", _on_has_been_destroyed)
		bush.connect("monster_interacted", _on_monster_interacted)
		bush.connect("bush_evolved", _on_bush_evolved)
		entity_positions.push_back(pos1)
		$WorldEntities.add_child(bush)
		
func _on_player_hurt():
	if player_hurt:
		return
	player_hurt = true
	$/root/AudioManager.play_sound("slime_hit")
	$CountdownPlayer.advance(3)
	$Player.speed = 450
	$Player.modulate.a = 0.5
	$PlayerInvulnerability.start()
	
func _on_player_invulnerability_timeout():
	player_hurt = false
	$Player.speed = 300
	$Player.modulate.a = 1
	
func _on_player_speed_boost_timeout():
	$Player.speed = 300
	$Player.modulate.a = 1
	if money_amount <= 20:
		$CanvasLayer/HUD_InGame/Sprite2d.modulate.a = 0.4 - money_amount/50.0
		$BackgroundMusic.set_pitch_scale(0.80 + money_amount/100.0)
	else:
		$CanvasLayer/HUD_InGame/Sprite2d.modulate.a = 0
		$BackgroundMusic.set_pitch_scale(1.0)
#___________________________________________________________________________
#Chest 
func _on_chest_item_sold():
	var item_id = hotbar_array[hotbar_current].item_id
	var item_amount = hotbar_array[hotbar_current].item_amount
	var money_profit = item_amount * item_dict[item_id][1]
	money_amount += money_profit
	hotbar_array[hotbar_current].set_item(0, "Nothing", 0)
	$Player/Tool/ToolSprite.animation = "Nothing"
	$CanvasLayer/HUD_InGame/Money.text = "$"+str(money_amount)
	$CanvasLayer/HUD_InGame/ProfitLoss.text = "+"+str(money_profit)
	$CanvasLayer/HUD_InGame/ProfitLoss.modulate.r = 0
	$CanvasLayer/HUD_InGame/ProfitLoss.modulate.g = 200
	$CanvasLayer/HUD_InGame/ProfitLoss.modulate.b = 0	
	$CanvasLayer/HUD_animation.stop()
	$CanvasLayer/HUD_animation.play("profit")
	$/root/AudioManager.play_sound("gold_get")
	if money_amount <= 20:
		$CanvasLayer/HUD_InGame/Sprite2d.modulate.a = 0.4 - money_amount/50.0
		$BackgroundMusic.set_pitch_scale(0.80 + money_amount/100.0)
	else:
		$CanvasLayer/HUD_InGame/Sprite2d.modulate.a = 0
		$BackgroundMusic.set_pitch_scale(1.0)
		
	money_max = max(money_amount, money_max)
		
	if game_mode == 0 and money_amount >= 500:
		game_won()
	elif game_mode == 1 and money_amount >= 2000:
		game_won()
		
	if item_id > 0 and item_id < 6:
		chestbar_array[item_id].set_out(false)
		if $Chest.all_out:
			$Chest.all_out = false
			chestbar_array[item_id].set_active(true)
		money_loss -= 5
	$CanvasLayer/HUD_InGame/Rent.text = "-"+str(money_loss)
	$Chest.get_interaction_cursor("Nothing")
		

func _on_chest_chest_opened():
	$/root/AudioManager.play_sound("menuselect1")
	get_tree().paused = true
	$CanvasLayer/HUD_Chest.visible = true
	$CanvasLayer/HUD_InGame.visible = false
	$CanvasLayer/HUD_Chest/Money.text = "Balance: $"+str(money_amount)
	$CanvasLayer/HUD_Chest/rent.text = "-$"+str(money_loss)+"/10s"
	$Player/AnimationPlayer.seek(0.2)
	chestbar_current = 0
	chestbar_array[chestbar_current].set_active(true)

func _on_hud_chest_give_item_current():
	if chestbar_current == 0:
		return
	hotbar_array[hotbar_current].set_item(chestbar_array[chestbar_current].item_id, item_dict[chestbar_array[chestbar_current].item_id][0], 1)
	$Player/Tool/ToolSprite.animation = item_dict[chestbar_array[chestbar_current].item_id][0]
	chestbar_array[chestbar_current].set_out(true)
	$Chest.all_out = true
	for i in range(0,5):
		if !chestbar_array[i].is_out and $Chest.all_out:
			$Chest.all_out = false
	money_loss += 5
	$CanvasLayer/HUD_InGame/Rent.text = "-"+str(money_loss)
	$Chest.get_interaction_cursor(item_dict[chestbar_array[chestbar_current].item_id][0])
	


func _on_hud_chest_chest_quit():
	$/root/AudioManager.play_sound("menuselect1")
	get_tree().paused = false
	$CanvasLayer/HUD_Chest.visible = false
	$CanvasLayer/HUD_InGame.visible = true


func _on_hud_chest_chestbar_left_signal():
	chestbar_array[chestbar_current].set_active(false)
	chestbar_current = chestbar_current - 1
	if chestbar_current < 0:
		chestbar_current = 5
	while chestbar_array[chestbar_current].is_out:
		chestbar_current = chestbar_current - 1
		if chestbar_current < 0:
			chestbar_current = 5	
	chestbar_array[chestbar_current].set_active(true)
	$/root/AudioManager.play_sound("menuselect1")


func _on_hud_chest_chestbar_right_signal():
	chestbar_array[chestbar_current].set_active(false)
	chestbar_current = chestbar_current + 1
	if chestbar_current > 5:
		chestbar_current = 0
	while chestbar_array[chestbar_current].is_out:
		chestbar_current = chestbar_current + 1
		if chestbar_current > 5:
			chestbar_current = 0	
	chestbar_array[chestbar_current].set_active(true)
	$/root/AudioManager.play_sound("menuselect1")


func game_over():
	get_tree().paused = true
	$Timer.paused = true
	total_time = total_time + 1
	$BackgroundMusic.stop()
	$/root/AudioManager.play_sound("ohno")
	$CanvasLayer2/GameOver.visible = true
	$CanvasLayer2/GameOver/ScoreMax.text = "Max Balance: $"+str(money_max)
	$CanvasLayer2/GameOver/Time.text = "Time Survived: "+str(total_time)+" seconds"
	
	is_game_over = true
	
func game_won():
	$Timer.paused = true
	total_time = total_time + 1 - $Timer.get_time_left()
	get_tree().paused = true
	$BackgroundMusic.stop()
	$/root/AudioManager.play_sound("nice")
	$CanvasLayer2/GameWon.visible = true
	$CanvasLayer2/GameWon/ScoreMax.text = "You saved Billy in "+str(snapped(total_time,0.001))+" seconds!"
	is_game_over = true
	
func _unhandled_input(event):
	if is_game_over and event.is_pressed() and event.is_action("menu"):
		$/root/AudioManager.play_sound("menuselect1")
		get_tree().reload_current_scene()
	if is_game_beginning and event.is_pressed() and event.is_action("start"):
		$/root/AudioManager.play_sound("menuselect1")
		is_game_beginning = false
		$CanvasLayer2/TitleScreen.visible = false
		get_tree().paused = false
		$BackgroundMusic.play()
		$Timer.start()
		return
	if is_game_beginning and event.is_pressed() and event.is_action("game_mode"):
		game_mode = (game_mode + 1)%3
		save_game_mode()
		game_mode_changes()
		return
	if is_game_beginning and event.is_pressed() and event.is_action("reload"):
		InputMap.load_from_project_settings()
		save_is_remapped(false)
		return
	if is_game_beginning and event.is_pressed() and event.is_action("quit"):
		$/root/AudioManager.play_sound("menuselect1")
		get_tree().quit()
		return
	if is_game_remapping and event.is_pressed():
		if CustomInputManager.set_event(event):
			emit_signal("remap_step_done")
		return
	if is_game_paused and event.is_pressed() and (event.is_action("action")):
		$/root/AudioManager.play_sound("menuselect1")
		if is_game_remapped:
			InputMap.load_from_project_settings()
			$CanvasLayer2/PauseMenu/Remap.text = "Press Space to remap the input keys"
			$CanvasLayer2/PauseMenu/Controls.text = """
Keyboard
Space - Interact
WASD - Move
Q/E - Change Slot
Esc/P - Pause
M - Mute/Unmute
"""
			is_game_remapped = false
			save_is_remapped(false)
			CustomInputManager.save_key_dict.clear()
			return
		is_game_remapping = true
		$CanvasLayer2/PauseMenu/Restart.visible = false
		$CanvasLayer2/PauseMenu/Remap.visible = false
		var keys = ["action", "up", "down", "left", "right", "hotbar_left", "hotbar_right"]
		for key in keys:
			$CanvasLayer2/PauseMenu/Resume.text = "Press Any key to map \""+key+"\"..."
			await remap_step_done
			CustomInputManager.set_event_to_action(key)
		save_is_remapped(true)
		save_input_map()
		is_game_remapping = false
		is_game_remapped = true
		$CanvasLayer2/PauseMenu/Restart.visible = true
		$CanvasLayer2/PauseMenu/Remap.visible = true
		$CanvasLayer2/PauseMenu/Remap.text = "Press Space to reset the controls"
		$CanvasLayer2/PauseMenu/Resume.text = "Press Esc or Start to Resume"
		$CanvasLayer2/PauseMenu/Controls.text = """
Keyboard
Space/Custom - Interact
Custom - Move
Custom - Change Slot
Esc/P - Pause
M - Mute/Unmute
"""
		
		return
	if is_game_paused and event.is_pressed() and (event.is_action("menu")):
		$/root/AudioManager.play_sound("menuselect1")
		$BackgroundMusic.stream_paused = false
		is_game_paused = false
		get_tree().paused = false
		$CanvasLayer2/PauseMenu.visible = false
		return
	if is_game_paused and event.is_pressed() and event.is_action("reload"):
		$/root/AudioManager.play_sound("menuselect1")
		get_tree().reload_current_scene()
		return
	if !is_game_paused and !$CanvasLayer/HUD_Chest.visible and event.is_pressed() and event.is_action("menu"):
		$/root/AudioManager.play_sound("menuselect1")
		$BackgroundMusic.stream_paused = true
		is_game_paused = true
		get_tree().paused = true
		$CanvasLayer2/PauseMenu.visible = true
		return
	if event.is_pressed() and event.is_action("mute"):
		$/root/AudioManager.play_sound("menuselect1")
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
		save_mute()



func _on_timer_timeout():
	total_time += 1
	$CanvasLayer/HUD_InGame/Time.text = "Time: "+str(snapped(total_time,1))+"s"





func _on_world_entities_child_entered_tree(node):
	var entity_list = $WorldEntities.get_children()
	var index = 0
	while(entity_list[index].position.y < node.position.y):
		index = index + 1
	$WorldEntities.move_child(node, index)
