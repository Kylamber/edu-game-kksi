extends Control

func _on_Continue_button_down():
	fade.transition(save_and_load.data["player"]["level_path"])


func _on_New_Game_button_down():
	save_and_load.new_game()
	fade.transition(save_and_load.data["player"]["level_path"])
