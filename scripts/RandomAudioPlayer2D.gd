extends Node2D


func play_random_audio():
	var audio_collection = get_children()
	if not audio_collection:
		return

	var idx = randi_range(0, len(audio_collection)-1)
	var audio = audio_collection[idx]
	audio.play()
