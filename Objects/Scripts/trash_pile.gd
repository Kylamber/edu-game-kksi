extends Area2D

func _on_trash_pile_body_entered(body):
	if !globVar.is_scavanging:
		yield(get_tree().create_timer(1), "timeout")
		if get_overlapping_bodies().size() == 1:
			globVar.is_scavanging = true
			yield(get_tree().create_timer(2.5), "timeout")
			if globVar.is_scavanging:
				$CollisionShape2D.disabled = true
				self.visible = false
				save_and_load.data["player"]["scraps"] += 1
				save_and_load.data["player"]["recycle_points"] += 1

func _on_trash_pile_body_exited(body):
	print("cancel scavange")
	globVar.is_scavanging = false

