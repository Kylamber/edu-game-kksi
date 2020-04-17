extends KinematicBody2D

export var stay_mode = false
onready var Player = get_parent().get_node("Ezra")
onready var avoid_fall = $avoid_fall
onready var avoid_fall2 = $avoid_fall2

var motion = Vector2.ZERO
var speed = 5 * globVar.tile_size

var state = "idle"
var dir = 1
var orient_anim = false

func _process(delta):
	match state:
		"idle":
			if stay_mode:
				idle_stay()
			else:
				idle_move()
		"chase":
			chase()
			attack()
		"dead":
			disable_entity()
	# Set animation
	set_anim()
	
	# Obey gravity
	motion.y += 1280 * delta
	motion = move_and_slide(motion, Vector2.UP)

# Moving idle
func idle_move():
	check_cliff()
	motion.x = speed * dir
	if is_on_wall():
		dir *= -1

# Stay in one place idle
func idle_stay():
	motion.x = 0

# Called when in chasing state
func chase():
	if !avoid_fall.is_colliding():
		if Player.position.x < position.x:
			yield(get_tree().create_timer(0.2), "timeout") # Reaction time
			motion.x = -speed
		elif Player.position.x > position.x:
			yield(get_tree().create_timer(0.2), "timeout") # Reaction time
			motion.x = speed
	else:
		motion.x = 0

# Attacking function
func attack():
	if $attack.is_colliding():
		$attack.get_collider().call_deferred("damaged", 50)

# Called when killed
func kill():
	state = "dead"
	$enemy_die_particle.emitting = true

# Called if stomped by the player
func stomped(stomper):
	if state != "dead":
		stomper.motion.y = stomper.min_jump_velocity
		kill()

# Checks if there is a cliff
func check_cliff():
	if !avoid_fall2.is_colliding():
		dir *= -1

# Set the animations so it's not cluttered inside the movement function
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

# Easy animation access
func anim(animation: String, backwards = false):
	$spr_kecoa.play(animation, backwards)
	$spr_kecoa.flip_h = orient_anim

# Disable the entity's functionality. 
func disable_entity():
	motion.x = 0
	motion.y = 0
	$spr_kecoa.visible = false
	$CollisionShape2D.disabled = true
	$avoid_fall2.enabled = false
	$avoid_fall.enabled = false
	$attack.enabled = false

