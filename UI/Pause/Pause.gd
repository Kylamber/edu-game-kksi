extends CanvasLayer

func _ready():
	$pause_control.hide()

# Read some inputs
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pause()

# Where the magic lies
func pause():
	if(globVar.pausable == true):
		get_tree().paused = not get_tree().paused
		if(get_tree().paused == true):
			$pause_control.show()
			#Debug
			print("Action : Pausing")
		else:
			$pause_control.hide()
			#Debug
			print("Action : Unpausing")

func _on_continue_pressed():
	pause()

func _on_exit_to_main_menu_pressed():
	$pause_control/CenterContainer/ConfirmationDialog.popup() # You need to confirm don't cha ?

func _on_ConfirmationDialog_confirmed():
	get_tree().paused = not get_tree().paused
	fade.transition("res://UI/Start Menu.tscn")
	$pause_control.hide()
	#Debug
	print("Action : Main menu confirm")
