extends StaticBody2D

@export var is_aware: bool = false
var intruder
var entity_position_memory: Array
var aimed_by_player = false

signal player_got_something(item_id, amount)
signal has_been_destroyed(body)

	
func _on_countdown_restart():
	if randi()%3 != 0:
		$BirdieCollisionBox.set_deferred("disabled", true)
		$BirdieAwareBox/BirdieAwareCollision.set_deferred("disabled", true)
		$AnimationPlayer.play("Fly")
		$/root/AudioManager.play_sound("birdfly")
func hit(item):
	if item == "Nothing":
		emit_signal("player_got_something", 19, 1)
		emit_signal("has_been_destroyed", self)
	else:
		$BirdieCollisionBox.set_deferred("disabled", true)
		$BirdieAwareBox/BirdieAwareCollision.set_deferred("disabled", true)
		$AnimationPlayer.play("Fly")
		$/root/AudioManager.play_sound("birdfly")
		
func get_interaction_cursor(item):
	if item == "Nothing":
		$Cursor.animation = "white"
		$Cursor/AnimationPlayer.play("cursor")
		$Cursor.visible = true

func remove_interaction_cursor():
	$Cursor.visible = false
		
func position_array():
	return [position]


func _on_animation_player_animation_finished(_anim_name):
	emit_signal("has_been_destroyed", self)


func _on_aware_timer_timeout():
	if $BirdieAwareBox.get_overlapping_bodies().has(intruder):
		aware_check()
	else:
		$AwareTimer.stop()

func _on_birdie_aware_box_body_entered(body):
	intruder = body
	aware_check()
	$AwareTimer.start()

func aware_check():
	if !intruder.is_in_group("Player") or intruder.has_a_weapon():
		$BirdieCollisionBox.set_deferred("disabled", true)
		$BirdieAwareBox/BirdieAwareCollision.set_deferred("disabled", true)
		$AnimationPlayer.play("Fly")
		$/root/AudioManager.play_sound("birdfly")
	
