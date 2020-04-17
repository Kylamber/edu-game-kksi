extends Area2D

export var connected_path = ""
onready var connected_to = get_parent().get_node(connected_path)

func _on_button_body_entered(body):
	$button.region_rect = Rect2(240, 48, 16, 16)
	connected_to.visible = false
	connected_to.set_collision_layer_bit(2, false)
