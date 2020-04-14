extends Area2D

func _on_trash_pile_body_entered(body):
	if globVar.state != "is_scavanging":
		yield(get_tree().create_timer(1), "timeout")
		if get_overlapping_bodies().size() == 1:
			globVar.state = "is_scavanging"
			$Particles2D.emitting = true
			yield(get_tree().create_timer(1.5), "timeout")
			if globVar.state == "is_scavanging":
				globVar.state = "scavange_complete"
				$Particles2D.emitting = false
				yield(get_tree().create_timer(0.1), "timeout")
				$CollisionShape2D.disabled = true
				self.visible = false
				save_and_load.data["player"]["scraps"] += 1
				save_and_load.data["player"]["recycle_points"] += 1

func _on_trash_pile_body_exited(body):
	if globVar.state == "is_scavanging":
		globVar.state = "on_ground"

