extends KinematicBody2D

signal health_updated(health)

export var acceleration = 256
var max_speed = 6 * globVar.tile_size
export var friction = 0.5

onready var stomp = $Stomp_cast

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

func _ready():
	gravity = 4 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	globVar.state = "on_ground"

func _process(delta):
	match globVar.state:
		"on_ground":
			on_ground(delta)
			motion = move_and_slide(motion, Vector2.UP)
		"on_ladder":
			on_ladder(delta)
			motion = move_and_slide(motion, Vector2.UP)
		"on_dialogue":
			anim("idle")
			motion.x = 0
		"dead":
			motion.x = 0
	if globVar.state != "dead":
		key_input()
	set_anim()

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

func on_ground(delta):
	#Keyboard Inputs
	x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if x_input != 0:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)
	else:
		motion.x = lerp(motion.x, max_speed * x_input, friction)
	
	if Input.is_action_just_pressed("ui_up") && is_on_floor():
		motion.y = max_jump_velocity
	
	if Input.is_action_just_released("ui_up") && motion.y < min_jump_velocity:
			motion.y = min_jump_velocity
	
	motion.y += gravity * delta
	
	#Stomping
	if stomp.is_colliding() && stomp.get_collision_normal() == Vector2.UP:
		motion.y = min_jump_velocity
		stomp.get_collider().entity.call_deferred("stomped", self)

func damaged(amount):
	if $Invulnerable.is_stopped():
		set_health(save_and_load.data["player"]["health"] - amount)
		motion.y = min_jump_velocity
		$Stomp_cast.enabled = false
		$Invulnerable.start()
		$Effects.play("damaged")
		$Effects.queue("invulnerable")

func kill():
	globVar.state = "dead"
	self.set_collision_layer_bit(0, false)

func set_health(value):
	var prev_health = save_and_load.data["player"]["health"]
	save_and_load.data["player"]["health"] = clamp(value, 0, max_health)
	if save_and_load.data["player"]["health"] != prev_health:
		emit_signal("health_updated", save_and_load.data["player"]["health"])
		if save_and_load.data["player"]["health"] == 0:
			kill()

func key_input():
	if Input.is_action_just_pressed("ui_accept") and globVar.gate_entered == true:
		save_and_load.data["player"]["level_path"] = globVar.gate_path
		fade.transition(globVar.gate_path)
	if Input.is_action_just_pressed("ui_accept") and globVar.dialogue_available == true and globVar.state != "on_dialogue" :
		dialogue.start_dialogue(globVar.dialogue_path)
	elif Input.is_action_just_pressed("ui_accept") and globVar.state == "on_dialogue":
		dialogue.next_dialogue()
 
func get_xy():
	return position

func set_anim():
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

func anim(animation: String, backwards = false):
	match animation:
		"idle":
			$ezraspr.play("idle", backwards)
			$ezraspr.flip_h = orient_anim
		"run":
			$ezraspr.play("run", backwards)
			$ezraspr.flip_h = orient_anim
		"fall":
			$ezraspr.play("fall", backwards)
			$ezraspr.flip_h = orient_anim
		"jump_up":
			$ezraspr.play("jump_up", backwards)
			$ezraspr.flip_h = orient_anim

func _on_Invulnerable_timeout():
	print("called")
	$Effects.play("rest")
	$Stomp_cast.enabled = true
