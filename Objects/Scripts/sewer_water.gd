extends Area2D




func _on_sewer_water_body_entered(body):
	if body.has_method("kill"):
		body.call_deferred("kill")
