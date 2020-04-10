extends KinematicBody2D

onready var Player = get_parent().get_node("Ezra")

var state = "idle"
var motion = Vector2.ZERO
var orient_anim = false
var gravity = 1280
var speed = 3 * globVar.tile_size
var dir = 1

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
	motion.y += gravity * delta
	motion = move_and_slide(motion, Vector2.UP)

func idle():
	motion.x = 0

func chase():
	if $jump_cooldown.is_stopped():
		if Player.position.x < position.x:
			yield(get_tree().create_timer(0.2), "timeout")
			dir = -1
			motion.y = -sqrt(2 * gravity * globVar.tile_size)
		elif Player.position.x > position.x:
			yield(get_tree().create_timer(0.2), "timeout")
			dir = 1
			motion.y = -sqrt(2 * gravity * globVar.tile_size)
		$jump_cooldown.start()
		motion.x = speed * dir
	if is_on_floor():
		motion.x = 0

func attack():
	if $attack.is_colliding():
		$attack.get_collider().call_deferred("damaged", 50)

func dead():
	motion.x = 0
	$stomped.set_collision_layer_bit(3, false)

func stomped(stomper):
	state = "dead"

func set_anim():
	if motion.x == 0:
		anim("idle")
	
	if dir == 1:
		orient_anim = true
	elif dir == -1:
		orient_anim = false
	
	if motion.x > 0:
		$attack.cast_to = Vector2(8, 0)
	elif motion.x < 0:
		$attack.cast_to = Vector2(-8, 0)
	
	if motion.y < 0:
		anim("up")
	elif motion.y > 0:
		anim("down")

func anim(animation: String, backwards = false):
	match animation:
		"idle":
			$spr_bin.play("idle", backwards)
			$spr_bin.flip_h = orient_anim
		"up":
			$spr_bin.play("up", backwards)
			$spr_bin.flip_h = orient_anim
		"down":
			$spr_bin.play("down", backwards)
			$spr_bin.flip_h = orient_anim
