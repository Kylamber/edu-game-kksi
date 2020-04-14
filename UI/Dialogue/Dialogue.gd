extends CanvasLayer

var dialogue = { }
var current_dialogue = 1
onready var dialogue_text = $Control/TextureRect/Label
onready var image_sprite = $Control/TextureRect/image

func _ready():
	$Control.hide()

func load_dialogue(path):
	var file = File.new()
	assert(file.file_exists(path))
	file.open(path, file.READ)
	var dialogue_parsed = JSON.parse(file.get_as_text()).result
	assert(dialogue_parsed.size() > 0)
	return dialogue_parsed

func start_dialogue(path):
	$Control.show()
	dialogue = load_dialogue(path)
	globVar.state = "on_dialogue"
	update_dialogue()

func update_dialogue():
	dialogue_text.text = (dialogue[str(current_dialogue)]["text"])
	image_sprite.texture = load(dialogue[str(current_dialogue)]["image_path"])
	$dialogue_animation.play("running_text")

func stop_dialogue():
	$Control.hide()
	globVar.state = "on_ground"
	current_dialogue = 1

func next_dialogue():
	current_dialogue += 1
	if current_dialogue <= dialogue.values().size():
		update_dialogue()
	else:
		stop_dialogue()
