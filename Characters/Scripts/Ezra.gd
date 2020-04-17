extends KinematicBody2D

#Movement variables
export var acceleration = 300
var max_speed = 6 * globVar.tile_size
export var friction = 0.5

#Jump variables
var max_jump_height = 2.25 * globVar.tile_size
var min_jump_height = 0.7 * globVar.tile_size
var max_jump_velocity
var min_jump_velocity
var jump_duration = 0.5
var gravity

var orient_anim = false

var x_input
var y_input

var motion = Vector2.ZERO

var invulnerable = false
export (float) var max_health = 100

#Ready function
func _ready():
	gravity = 4 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	globVar.state = "on_ground"

func _process(delta):
	# State machine
	match globVar.state:
		"on_ground":
			on_ground(delta)
			motion = move_and_slide(motion, Vector2.UP)
		"on_ladder":
			on_ladder(delta)
			motion = move_and_slide(motion, Vector2.UP)
		"on_dialogue":
			anim("idle")
			#Zooming camera
			$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 0.75, 0.1)
			$Camera2D.zoom.y = lerp($Camera2D.zoom.x, 0.75, 0.1)
			motion.x = 0
		"dialogue_finished":
			#Zooming camera
			$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 1.25, 0.1)
			$Camera2D.zoom.y = lerp($Camera2D.zoom.x, 1.25, 0.1)
		"on_scavange":
			motion.x = 0
		"scavange_complete":
			#Zooming camera
			$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 0.75, 0.1)
			$Camera2D.zoom.y = lerp($Camera2D.zoom.x, 0.75, 0.1)
			set_anim()
			yield(get_tree().create_timer(1), "timeout")
			$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 1.25, 0.1)
			$Camera2D.zoom.y = lerp($Camera2D.zoom.x, 1.25, 0.1)
			globVar.state = "on_ground"
		"dead":
			motion.x = 0
	# If not dead then you can do key input
	if globVar.state != "dead":
		key_input()
	# Set the animation
	set_anim()

# This is for when you are at the ladder, cluncky but still works.
func on_ladder(delta):
	y_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if x_input != 0:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)
	else:
		motion.x = lerp(motion.x, max_speed * x_input, friction)

	if y_input != 0:
		motion.y += y_input * acceleration * delta
		motion.y = clamp(motion.y, -max_speed, max_speed)
	else:
		motion.y = lerp(motion.x, max_speed * y_input, friction)

# This is for when you are at the ground
func on_ground(delta):
	# Walking mechanism
	x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if x_input == 1:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, 0, max_speed)
	elif x_input == -1:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, 0)
	else:
		motion.x = lerp(motion.x, max_speed * x_input, friction)
	
	# Jumping Mechanism
	if Input.is_action_just_pressed("ui_up") && is_on_floor():
		motion.y = max_jump_velocity
	if Input.is_action_just_released("ui_up") && motion.y < min_jump_velocity:
		motion.y = min_jump_velocity
	
	# Still needs to obey gravity
	motion.y += gravity * delta
	
	# Stomping for squashing enemies.
	if $stomp_cast.is_colliding() && $stomp_cast.get_collision_normal() == Vector2.UP:
		play_audio("stomp")
		#Debug
		print("Action : Stomping")
		#Debug
		$stomp_cast.get_collider().entity.call_deferred("stomped", self)

# This is when you get damaged, the monsters are hard.
func damaged(amount):
	if $Invulnerable.is_stopped():
		set_health(save_and_load.data["player"]["health"] - amount)
		#Debug
		print("Action : Damaged")
		print("Damage : " + str(amount))
		#Debug
		motion.y = min_jump_velocity
		$Stomp_cast.enabled = false
		play_audio("hit_damage")
		$Invulnerable.start()
		$Effects.play("damaged")
		$Effects.queue("invulnerable")

# Oops, you are no longer invulnerable
func _on_Invulnerable_timeout():
	$Effects.play("rest")
	$Stomp_cast.enabled = true

func kill():
	globVar.state = "dead" # We concluded that he's dead when killed
	motion.y = min_jump_velocity # Do a little jump when dead, doesn't work tho.
	self.set_collision_layer_bit(0, false) # Disable the player's collision.
	#Debug
	print("Respawn Path : " + save_and_load.data["player"]["level_path"])
	print("Setting health to " + str(max_health))
	#Debug
	save_and_load.data["player"]["health"] = max_health # Set the player's health
	fade.transition(save_and_load.data["player"]["level_path"]) # Respawn to another/same scene

func set_health(value):
	var prev_health = save_and_load.data["player"]["health"]
	save_and_load.data["player"]["health"] = clamp(value, 0, max_health) # Makes sure the health doesn't go to negative
	if save_and_load.data["player"]["health"] != prev_health:
		#Debug
		print("Current health : " + str(save_and_load.data["player"]["health"]))
		#Debug
		if save_and_load.data["player"]["health"] == 0:
			kill() # You dead boi

# Key inputs goes here
func key_input():
	if Input.is_action_just_pressed("ui_accept") and globVar.gate_entered == true:
		fade.transition(globVar.gate_path)
	if Input.is_action_just_pressed("ui_accept") and globVar.dialogue_available == true and globVar.state != "on_dialogue" :
		dialogue.start_dialogue(globVar.dialogue_path)
		#Debug
		print("Action : Starting dialogue")
		print("Dialogue path : " + globVar.dialogue_path)
		#Debug
	elif Input.is_action_just_pressed("ui_accept") and globVar.state == "on_dialogue":
		dialogue.next_dialogue()
		#Debug
		print("Action : Next dialogue")
		#Debug

# Set up animations for spr_ezra.
func set_anim():
	if globVar.state == "on_ground":
		if is_on_floor():
			if x_input > 0:
				orient_anim = false
				anim("run")
			elif x_input < 0:
				orient_anim = true
				anim("run")
			elif x_input == 0:
				anim("idle")
		elif !is_on_floor():
			if motion.y > 0:
				anim("fall")
			elif motion.y < 0:
				anim("jump_up")
	elif globVar.state == "is_scavanging":
		anim("scavange")
	elif globVar.state == "scavange_complete":
		anim("sc_complete")

# Quick and easy uncluttered way to play animations.
func anim(animation: String, backwards = false):
	$spr_ezra.play(animation, backwards)
	$spr_ezra.flip_h = orient_anim

# Play audio, I don't know if this is better or not.
func play_audio(sound: String):
	get_node("sfx_collection/" + sound).play()

