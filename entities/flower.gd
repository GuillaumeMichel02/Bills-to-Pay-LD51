extends StaticBody2D

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)

@export var item_id: int = 0
@export var amount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_information(pos, flower_id, flower_name, flower_amount):
	position = pos
	item_id = flower_id
	$FlowerSprite.animation = flower_name
	amount = flower_amount


	
func _on_countdown_restart():
	pass
		
func hit(item):
	if item not in ["Sword", "Axe", "Pickaxe", "Fishing Rod"]:
		if item == "Hoe":
			emit_signal("player_got_something", item_id, amount)
		else:
			emit_signal("player_got_something", item_id, 1)
	else:
		$/root/AudioManager.play_sound("broke")
	emit_signal("has_been_destroyed", self)

func get_interaction_cursor(item):
	if item not in ["Sword", "Axe", "Pickaxe", "Fishing Rod"]:
		$Cursor.animation = "white"
	else:
		$Cursor.animation = "red"
	$Cursor/AnimationPlayer.play("cursor")
	$Cursor.visible = true

func remove_interaction_cursor():
	$Cursor.visible = false
	
func position_array():
	return [position]
