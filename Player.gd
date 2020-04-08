extends KinematicBody2D

var velocity = Vector2()
var acceleration = 15
var max_speed = 150

func movement():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	velocity.x += axis.x * acceleration
	velocity.y += axis.y * acceleration
	velocity.x = lerp(velocity.x, 0, 0.2)
	velocity.y = lerp(velocity.y, 0, 0.2)
	if(axis.x > 0):
		$ezra.flip_h = false
		$ezra.play("run")
	elif(axis.x < 0):
		$ezra.flip_h = true
		$ezra.play("run")
	elif(axis.y != 0):
		$ezra.play("run") 
	else:
		$ezra.play("idle")

# warning-ignore:unused_argument
func _physics_process(delta):
	movement()
	velocity = velocity.clamped(max_speed)
	velocity = move_and_slide(velocity)
