extends Area2D

export var level_path = ""
var activated = false

func _on_checkpoint_body_entered(body):
	if !activated:
		$checkpoint_reached.play()
		save_and_load.data["player"]["level_path"] = level_path
		save_and_load.save_game()
		#Debug
		print("Action : Checkpoint")
		print("Checkpoint path : " + level_path)
		#Debug
		activated = true
