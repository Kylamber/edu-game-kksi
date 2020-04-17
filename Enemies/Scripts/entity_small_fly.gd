extends KinematicBody2D

onready var player = get_parent().get_node("Ezra")

var state = "idle"
var motion = Vector2.ZERO
var orient_anim = false

func _process(delta):
	match state:
		"idle":
			idle()
		"chase":
			chase()
			attack()
		"dead":
			disable_entity()
	motion = move_and_slide(motion, Vector2.UP)
	set_anim()

# Idling function
func idle():
	motion.x = 0

# Chasing function
func chase():
	yield(get_tree().create_timer(0.1), "timeout")
	motion = (player.position - self.position + Vector2(0, 5)) * 2

# Attack function
func attack():
	if $attack.is_colliding():
		$attack.get_collider().call_deferred("damaged", 20)

# Called when first killed
func kill():
	state = "dead"
	$enemy_die_particle.emitting = true

# Called when stomped
func stomped(stomper):
	if state != "dead":
		stomper.motion.y = stomper.min_jump_velocity
		kill()

# Set animation
func set_anim():
	if motion.x > 0:
		orient_anim = false
		$attack.cast_to = Vector2(3, 0)
		anim("fly")
	elif motion.x < 0:
		orient_anim = true
		$attack.cast_to = Vector2(-3, 0)
		anim("fly")

# Play animation
func anim(animation: String, backwards = false):
	$spr_small_fly.play(animation, backwards)
	$spr_small_fly.flip_h = orient_anim

# Disable the entity's functionality
func disable_entity():
	motion.x = 0
	motion.y = 0
	$spr_small_fly.visible = false
	$CollisionShape2D.disabled = true
	$attack.enabled = false


