extends Node

func play_sound(sound_name):
	var AudioPlayer = $/root/Main/Sounds.find_child(sound_name)
	AudioPlayer.play()
