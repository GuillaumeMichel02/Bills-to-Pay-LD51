extends AnimatedSprite2D

@export var active: bool = false
@export var item_id: int = 0
@export var item_amount: int = 0

var is_out = false

func _ready():
	pass

func set_out(out):
	is_out = out
	if is_out:
		self.animation = "out"
	else:
		self.animation = "inactive"

func set_item(new_id, item_name, amount):
	item_id = new_id
	if item_id > 0:
		$ItemName.text = item_name
	else:
		$ItemName.text = ""
	$Item.animation = item_name
	item_amount = amount
	$Amount.text = "Rent: 5$/10s"

func set_active(is_active):
	active = is_active
	if active:
		self.animation = "active"
	else:
		self.animation = "inactive"
