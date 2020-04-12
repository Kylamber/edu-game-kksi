extends CanvasLayer

func _ready():
	$pause_control.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pause()
	
func pause():
	if(globVar.pausable == true):
		get_tree().paused = not get_tree().paused
		if(get_tree().paused == true):
			$pause_control.show()
		else:
			$pause_control.hide()
	else:
		pass

func _on_continue_pressed():
	save_and_load.save_game()

func _on_main_menu_pressed():
	get_tree().paused = not get_tree().paused
	fade.transition("res://Start Menu.tscn")
	yield(get_tree().create_timer(1), "timeout")
	$pause_control.hide()
