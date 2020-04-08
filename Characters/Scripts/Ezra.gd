extends KinematicBody2D

signal health_updated(health)

export var acceleration = 256
var max_speed = 5 * globVar.tile_size
export var friction = 0.5

onready var stomp = $Stomp_cast

var max_jump_height = 2.0 * globVar.tile_size
var min_jump_height = 0.7 * globVar.tile_size
var max_jump_velocity
var min_jump_velocity
var jump_duration = 0.5
var gravity

var orient_anim = false

var x_input
var y_input

var motion = Vector2.ZERO

var state = "alive"
var invulnerable = false
export (float) var max_health = 100
var health = max_health setget set_health

func _ready():
	gravity = 4 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)

func movement(delta):
	x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	y_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if x_input != 0:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)
	else:
		motion.x = lerp(motion.x, max_speed * x_input, friction)
	
	#Is not on ladder
	if globVar.is_on_ladder == false:
		if Input.is_action_just_pressed("ui_up") && is_on_floor():
			motion.y = max_jump_velocity
		if Input.is_action_just_released("ui_up") && motion.y < min_jump_velocity:
				motion.y = min_jump_velocity
		motion.y += gravity * delta
	#Is on ladder
	elif globVar.is_on_ladder == true:
		if y_input != 0:
			motion.y += y_input * acceleration * delta
			motion.y = clamp(motion.y, -max_speed, max_speed)
		else:
			motion.y = lerp(motion.x, max_speed * y_input, friction)
	

func _process(delta):
	match state:
		"alive":
			movement(delta)
			set_anim()
			keyInput()
			ezra_stomp()
			motion = move_and_slide(motion, Vector2.UP)
		"freeze":
			pass
		"dead":
			motion.x = 0

func damaged(amount):
	if $Invulnerable.is_stopped():
		set_health(health - amount)
		motion.y = min_jump_velocity
		$Stomp_cast.enabled = false
		$Invulnerable.start()
		$Effects.play("damaged")
		$Effects.queue("invulnerable")

func kill():
	fade.transition("res://Maps/C1S1/c1s1.tscn")
	state = "dead"

func set_health(value):
	var prev_health = health 
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health updated", health)
		if health == 0:
			kill()

func ezra_stomp():
	if stomp.is_colliding() && stomp.get_collision_normal() == Vector2.UP:
		motion.y = min_jump_velocity
		stomp.get_collider().entity.call_deferred("stomped", self)

func keyInput():
	if Input.is_action_just_pressed("ui_accept") && globVar.gate_entered == true:
		fade.transition(globVar.gate_path)
 
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
	$Effects.play("rest")
	$Stomp_cast.enabled = true
