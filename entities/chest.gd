extends StaticBody2D

signal chest_opened()

signal item_sold()

var all_out = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func hit(item):
	if item == "Nothing" and !all_out:
		emit_signal("chest_opened")
		return
	if item != "Nothing":
		emit_signal("item_sold")
