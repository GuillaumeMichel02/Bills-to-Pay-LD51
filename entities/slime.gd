extends CharacterBody2D

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)
signal item_used()
signal player_hurt()

var speed = 100
var health = 3
var random_direction
var direction
var player
var player_seen = false
var is_hurt = false

func _ready():
	random_direction = randf_range(PI,-PI)
	direction = random_direction
	$RandomDirectionTimer.start()
	var collision_at_spawn = $PlayerDetection.get_overlapping_bodies()
	for entity in collision_at_spawn:
		if entity.is_in_group("Player"):
			player_seen = true
			player = entity
	
func _physics_process(_delta):
	var collision_at_spawn = $PlayerDetection.get_overlapping_bodies()
	for entity in collision_at_spawn:
		if entity.is_in_group("Player"):
			player_seen = true
			player = entity
			
	if is_hurt:
		direction = player.get_angle_to(position)
	elif player_seen:
		direction = get_angle_to(player.position)
	else:
		direction = random_direction
	
	velocity = Vector2(cos(direction), sin(direction)) * speed

	move_and_slide()
	position.x = clamp(position.x, 32, 2048 - 32) 
	position.y = clamp(position.y, 0, 1536 - 64)  
	
	
func _on_countdown_restart():
	pass
	
func hit(item):
	if is_hurt:
		return
	$/root/AudioManager.play_sound("slime_hit")
	if item == "Purple Flower":
		health = 0
		emit_signal("item_used")
	if item == "Fishing Rod":
		health += 1
	if item == "Sword":
		health -= 1
		is_hurt = true
		set_collision_mask_value(2, false)
		$Sprite2d.modulate.a = 0.5
		$Sprite2d/Sprite2d.modulate.a = 0.5
		speed = 300
		$Hurt.start()
	
	if health == 0:
		$/root/AudioManager.play_sound("broke")
		$AnimationPlayer.play("Death")
	


func _on_random_direction_timer_timeout():
	random_direction = randf_range(PI,-PI)


func _on_player_detection_body_entered(body):
	player = body
	player_seen = true
	


func _on_player_detection_body_exited(_body):
	player_seen = false
	direction = random_direction


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Death":
		emit_signal("player_got_something", 16, randi()%3+1)
		emit_signal("has_been_destroyed", self)


func _on_hurt_timeout():
	is_hurt = false
	set_collision_mask_value(2, true)
	$Sprite2d.modulate.a = 1
	$Sprite2d/Sprite2d.modulate.a = 1
	if health != 1:
		speed = 150


func _on_harm_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("player_hurt")
		is_hurt = true
		$Hurt.start()
	
func position_array():
	return []
