extends KinematicBody2D

onready var Player = get_parent().get_node("Ezra")
onready var avoid_fall = $avoid_fall
onready var avoid_fall2 = $avoid_fall2

var motion = Vector2.ZERO
var speed = 5 * globVar.tile_size

var state = "idle"
var dir = 1
var orient_anim = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	match state:
		"idle":
			idle()
		"chase":
			chase()
			attack()
		"dead":
			dead()
	
	set_anim()
	motion.y += 1280 * delta
	motion = move_and_slide(motion, Vector2.UP)

func idle():
	check_cliff()
	motion.x = speed * dir
	if is_on_wall():
		dir *= -1

func chase():
	if !avoid_fall.is_colliding():
		if Player.position.x < position.x:
			yield(get_tree().create_timer(0.2), "timeout")
			motion.x = -speed
		elif Player.position.x > position.x:
			yield(get_tree().create_timer(0.2), "timeout")
			motion.x = speed
	else:
		motion.x = 0

func kill():
	state = "dead"

func dead():
	motion.x = 0
	$stomped.set_collision_layer_bit(0, false)

func attack():
	if $attack.is_colliding():
		$attack.get_collider().call_deferred("damaged", 50)

func stomped(stomper):
	state = "dead"

func check_cliff():
	if !avoid_fall2.is_colliding():
		dir *= -1

func set_anim():
	if motion.x > 0:
		orient_anim = true
		$attack.cast_to = Vector2(12, 0)
		anim("run")
	elif motion.x < 0:
		orient_anim = false
		$attack.cast_to = Vector2(-12, 0)
		anim("run")
	elif motion.x == 0:
		anim("idle")

func anim(animation: String, backwards = false):
	match animation:
		"idle":
			$spr_kecoa.play("idle", backwards)
			$spr_kecoa.flip_h = orient_anim
		"run":
			$spr_kecoa.play("run", backwards)
			$spr_kecoa.flip_h = orient_anim
