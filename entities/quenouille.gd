extends StaticBody2D

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)
signal quenouille_multiplied

@export var item_id: int = 12
@export var amount: int = 3
var entity_position_memory: Array
var quenouille_test = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	



	
func _on_countdown_restart():
	if randi()%8 == 0:
		emit_signal("quenouille_multiplied")
		
func hit(item):
	if item not in ["Sword", "Axe", "Pickaxe"]:
		emit_signal("player_got_something", item_id, amount)
	else:
		$/root/AudioManager.play_sound("broke")
	emit_signal("has_been_destroyed", self)
	
func position_array():
	return [position]
