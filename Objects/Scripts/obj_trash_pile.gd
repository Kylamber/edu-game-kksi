extends Area2D

func _on_trash_pile_body_entered(body):
	if globVar.state != "is_scavanging": # Initiate scavange
		yield(get_tree().create_timer(1), "timeout")
		#Debug
		print("Action : Initiating scavange")
		#Debug
		if get_overlapping_bodies().size() == 1: # Start scavanging
			globVar.state = "is_scavanging"
			$scavanging.play()
			$Particles2D.emitting = true
			#Debug
			print("Action : Start scavanging")
			#Debug
			yield(get_tree().create_timer(1.5), "timeout")
			if globVar.state == "is_scavanging": # Finish scavanging
				globVar.state = "scavange_complete"
				$Particles2D.emitting = false
				yield(get_tree().create_timer(0.1), "timeout")
				$CollisionShape2D.disabled = true
				$collect.play()
				self.visible = false
				save_and_load.data["player"]["scraps"] += 1
				save_and_load.data["player"]["recycle_points"] += 1
				#Debug
				print("Action : Finished scavanging")
				print("Scraps : " + str(save_and_load.data["player"]["scraps"]))
				print("Recycle points : " + str(save_and_load.data["player"]["recycle_points"]))

func _on_trash_pile_body_exited(body):
	if globVar.state == "is_scavanging": # Cancel scavanging
		globVar.state = "on_ground"
		#Debug
		print("Action : Cancel scavange")
