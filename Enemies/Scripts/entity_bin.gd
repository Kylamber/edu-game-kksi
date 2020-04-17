extends KinematicBody2D

onready var Player = get_parent().get_node("Ezra")

var state = "idle"
var motion = Vector2.ZERO
var orient_anim = false
var gravity = 1280
var speed = 5 * globVar.tile_size 
var dir = 1

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
			yield(get_tree().create_timer(0.2), "timeout") # Reaction time
			dir = -1
			motion.y = -sqrt(2 * gravity * globVar.tile_size) # Jumping
		elif Player.position.x > position.x:
			yield(get_tree().create_timer(0.2), "timeout") # Reaction time
			dir = 1
			motion.y = -sqrt(2 * gravity * globVar.tile_size) # Jumping
		$jump_cooldown.start()
		motion.x = speed * dir
	if is_on_floor():
		motion.x = 0

# Attack function
func attack():
	if $attack.is_colliding():
		$attack.get_collider().call_deferred("damaged", 50)

# Dead state function
func dead():
	motion.x = 0
	$stomped.set_collision_layer_bit(3, false)

# Called when killed
func kill():
	state = "dead"
	$enemy_die_particle.emitting = true
	disable_entity()

# Called when stomped
func stomped(stomper):
	if state != "dead":
		stomper.motion.y = stomper.min_jump_velocity
		kill()

# Setting up the animations
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

# Play animation
func anim(animation: String, backwards = false):
	$spr_bin.play(animation, backwards)
	$spr_bin.flip_h = orient_anim

# Disable the entity's functionality
func disable_entity():
	$spr_bin.visible = false
	$CollisionShape2D.disabled = true
	$attack.enabled = false

