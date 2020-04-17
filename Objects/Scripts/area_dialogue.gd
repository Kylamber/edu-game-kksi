extends Area2D

export var dialogue_path = ""

func _on_test_dialogue_body_entered(body):
	globVar.dialogue_path = dialogue_path
	globVar.dialogue_available = true

func _on_test_dialogue_body_exited(body):
	globVar.dialogue_path = ""
	globVar.dialogue_available = false
