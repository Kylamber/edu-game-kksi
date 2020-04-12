extends Node

var path = "res://Data/save_file.json"

var default_data = {
	"player" : {
		"recycle_points" : 0,
		"scraps" : 0,
		"health" : 100,
		"level_path" : "res://Maps/C1S1/c1s1.tscn"
	}
}

var data = { }

func _ready():
	load_game()

func load_game():
	var file = File.new()
	
	if !file.file_exists(path):
		reset_data()
		return
	
	file.open(path, File.READ)
	
	var text = file.get_as_text()
	
	data = parse_json(text)

func save_game():
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(data))
	file.close()

func new_game():
	reset_data()

func reset_data():
	data = default_data.duplicate(true)
