extends CanvasLayer

signal scene_changed()

func transition(path, delay = 0.5):
	yield(get_tree().create_timer(delay), "timeout")
	$fade_tr.play("fade")
	yield($fade_tr, "animation_finished")
	assert(get_tree().change_scene(path) == OK)
	$fade_tr.play_backwards("fade")
	yield($fade_tr, "animation_finished")
	emit_signal("scene_changed") 
