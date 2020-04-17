extends Control

func _ready():
	globVar.pausable = false

func _on_Continue_button_down():
	save_and_load.load_game()
	fade.transition(save_and_load.data["player"]["level_path"])
	globVar.pausable = true

func _on_New_Game_button_down():
	save_and_load.new_game()
	fade.transition(save_and_load.data["player"]["level_path"])
	globVar.pausable = true
