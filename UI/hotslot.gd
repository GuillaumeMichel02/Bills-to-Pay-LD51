extends AnimatedSprite2D

@export var active: bool = false
@export var item_id: int = 0
@export var item_amount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_item(new_id, item_name, amount):
	item_id = new_id
	if item_id > 0:
		$ItemName.text = item_name
	else:
		$ItemName.text = ""
	$Item.animation = item_name
	item_amount = amount
	if item_amount > 1:
		$Amount.text = str(item_amount)
	else:
		$Amount.text = ""

func give_amount(difference: int):
	if item_amount + difference < 0:
		return false
	else:
		item_amount += difference
		if item_amount > 1:
			$Amount.text = str(item_amount)
		elif item_amount > 0:
			$Amount.text = ""
		else:
			item_id = 0
			$Amount.text = ""
			$ItemName.text = ""
			$Item.animation = "Nothing"
		return true
	

func set_active(is_active):
	active = is_active
	if active:
		$ItemName.visible = true
		self.animation = "active"
	else:
		$ItemName.visible = false
		self.animation = "inactive"
