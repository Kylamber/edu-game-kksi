extends Node

var path = "user://data.json"

# The default values
var default_data = {
	"player" : {
		"health" : 100,
		"level_path" : "res://Maps/C1S1/c1s1.tscn",
		"scraps" : 0,
		"recycle_points" : 0
		}
}

var data = { }

func load_game():
	var file = File.new()
	if not file.file_exists(path):
		reset_data()
		return
	file.open(path, file.READ)
	var text = file.get_as_text()
	data = parse_json(text)
	file.close()
	print("Action : Loading game")

func save_game():
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	#Debug
	print("Action : Saving game")

func new_game():
	reset_data()
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	load_game()
	#Debug
	print("Action : New game")

func reset_data():
	data = default_data.duplicate(true)


