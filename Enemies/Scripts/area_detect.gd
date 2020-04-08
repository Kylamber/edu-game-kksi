extends Area2D

func _ready():
	pass # Replace with function body.



func _on_area_detect_body_entered(body):
	if get_parent().state != "dead":
		if body.name == "Ezra":
			get_parent().state = "chase"


func _on_area_detect_body_exited(body):
	if get_parent().state != "dead":
		if body.name == "Ezra":
			get_parent().state = "idle"
