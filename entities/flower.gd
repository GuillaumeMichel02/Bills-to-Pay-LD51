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
		emit_signal("player_got_something", item_id, amount)
	else:
		$/root/AudioManager.play_sound("broke")
	emit_signal("has_been_destroyed", self)
	
func position_array():
	return [position]
