extends CharacterBody2D

signal hotbar_left_signal
signal hotbar_right_signal
signal has_hit_something(body)
signal has_interacted_with_ground

var speed = 300.0
var can_act: bool = true
var has_hit: bool = false
var direction_name = "down"
var screen_size
var sprite_x
var sprite_y


func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(_delta):
	
	# If the player cannot act, he cannot move
	if !can_act:
		return
	
	#Movement management
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if direction:
		if direction.x:
			velocity.y = 0
			velocity.x = direction.x * speed
			if direction.x > 0:
				direction_name = "right"
				$Tool/ToolHitbox.position = Vector2(56,12)
				$Tool/ToolHitbox.rotation = 0
			else:
				direction_name = "left"
				$Tool/ToolHitbox.position = Vector2(-56,12)
				$Tool/ToolHitbox.rotation = 0
		else:
			velocity.x = 0
			velocity.y = direction.y * speed
			if direction.y > 0:
				direction_name = "down"
				$Tool/ToolHitbox.position = Vector2(0,46)
				$Tool/ToolHitbox.rotation = PI/2
			else:
				direction_name = "up"
				$Tool/ToolHitbox.position = Vector2(0,-35)
				$Tool/ToolHitbox.rotation = PI/2
		$BodySprite.animation = direction_name
		$AnimationPlayer.play("moving")
	else:
		velocity.x = 0
		velocity.y = 0
		$AnimationPlayer.play("resting")
	move_and_slide()
	
	position.x = clamp(position.x, 32, 2048 - 32) 
	position.y = clamp(position.y, 0, 1536 - 64)  



func _unhandled_input(event):
	#Player wants to do an action and isn't already doing it
	if !can_act:
		return
	if event.is_pressed() and event.is_action("action"):
		can_act = false
		$Tool.visible = true
		if $Tool/ToolSprite.animation != "Nothing":
			$HandSprite.visible = true
			$/root/AudioManager.play_sound("hit")
		else:
			$/root/AudioManager.play_sound("normal_hit")
		$Tool/ToolHitbox.set_deferred("disabled",false)
		var swing_animation = "swing_"+direction_name
		$AnimationPlayer.play(swing_animation)
		
		return
		
	if event.is_pressed() and event.is_action("hotbar_left"):
		emit_signal("hotbar_left_signal")
		
	if event.is_pressed() and event.is_action("hotbar_right"):
		emit_signal("hotbar_right_signal")
		


func _on_animation_player_animation_finished(anim_name):
	if anim_name=="moving" or anim_name=="resting":
		return
	$Tool/ToolHitbox.set_deferred("disabled",true)
	$Tool.visible = false
	$HandSprite.visible = false
	if has_hit == false:
		emit_signal("has_interacted_with_ground")
	has_hit = false
	can_act = true


func _on_tool_body_entered(body):
	has_hit = true
	$Tool/ToolHitbox.set_deferred("disabled",true)
	emit_signal("has_hit_something", body)
	
func has_a_weapon():
	return $Tool/ToolSprite.animation != "Nothing"
	
