extends CharacterBody2D

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)

@export var item_id: int = 0
@export var amount: int = 0
var entity_position_memory: Array
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func get_information(drop_position, drop_item_id, item_name, drop_amount):
	position = drop_position
	item_id = drop_item_id
	$Item.animation = item_name
	amount = drop_amount
	$Amount.text = str(amount)
	if item_id == 19 or item_id == 20 or item_id == 13:
		emit_signal("has_been_destroyed", self)



	
func _on_countdown_restart():
	if randi()%3 == 0:
		emit_signal("has_been_destroyed", self)
		
func hit(item):
	if item not in ["Sword", "Axe", "Pickaxe", "Hoe"]:
		emit_signal("player_got_something", item_id, amount)
	emit_signal("has_been_destroyed", self)

func get_interaction_cursor(item):
	if item not in ["Sword", "Axe", "Pickaxe", "Hoe"]:
		$Cursor.animation = "white"
	else:
		$Cursor.animation = "red"
	$Cursor/AnimationPlayer.play("cursor")
	$Cursor.visible = true

func remove_interaction_cursor():
	$Cursor.visible = false

func position_array():
	return [position]
