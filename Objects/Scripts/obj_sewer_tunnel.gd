extends Area2D

export var path = ""
export var instant = false
export var delay = 0.5

func _on_sewer_tunnel_body_entered(body):
	if body.name == "Ezra":
		globVar.gate_entered = true
		globVar.gate_path = path
	if instant == true:
		fade.transition(path, delay)


func _on_sewer_tunnel_body_exited(body):
	if body.name == "Ezra":
		globVar.gate_entered = false
		globVar.gate_path = ""
