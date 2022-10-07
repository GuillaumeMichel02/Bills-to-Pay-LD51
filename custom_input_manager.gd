extends Node

var temp_event
var save_key_dict: Dictionary
	
func set_event(event):
	if event.keycode == 32 and !save_key_dict.is_empty():
		return false

	if !save_key_dict.find_key(event):
		
			temp_event = event
			return true
	return false
	
func set_event_to_action(key):
	for action in ["up", "down", "left", "right", "hotbar_left", "hotbar_right"]:
		if InputMap.action_has_event(action, temp_event):
			InputMap.action_erase_event(action, temp_event)
	InputMap.action_add_event(key, temp_event)
	save_key_dict[key] = temp_event
