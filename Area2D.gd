extends Area2D

func _on_Area2D_body_entered(body):
	if body.name == "Ezra":
		globVar.is_on_ladder = true


func _on_Area2D_body_exited(body):
	if body.name == "Ezra":
		globVar.is_on_ladder = false
