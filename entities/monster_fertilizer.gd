extends StaticBody2D

signal monster_effect_entity(used_on_entity)
signal monster_effect_ground(body ,used_on_ground)
signal has_been_destroyed(body)

var used_on_entity = null
var used_on_ground = null
var difficulty
var ground_difficulty = {
	"G" : 1,
	"S" : 1,
	"D" : 5,
}


func set_ground(tile_name):
	used_on_ground = tile_name
	difficulty = ground_difficulty[used_on_ground]

func _on_countdown_restart():
	if randi()%difficulty == 0:
		print("Heh")
		emit_signal("monster_effect_entity", used_on_entity)
		emit_signal("monster_effect_ground", self ,used_on_ground)
		emit_signal("has_been_destroyed", self)
		
func get_interaction_cursor(item):
	pass

func remove_interaction_cursor():
	pass

func position_array():
	return [position]
	
func hit(_item):
	pass
