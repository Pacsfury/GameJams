extends Node

@onready var hud = %HUD

var needed_points: Array = [3000, 5000, 8000, 13000]
var is_playable: Array = [1, 0, 0, 0, 0]
var points: int = 0
var mult: int = 1
var level: int = 1

func add_points(pts: int) -> void:
	var scene_path = get_tree().current_scene.scene_file_path
	var file_name = scene_path.get_file() 
	
	level = int(file_name.to_int())
	
	points += pts
	hud.update_points()

	if points >= needed_points[level - 1]:
		is_playable[level] = 1
		hud.get_node("CanvasLayer/end").show()

func set_level(lvl: int) -> void:
	if is_playable[lvl - 1] == 1:
		level = lvl
		get_tree().change_scene_to_file("res://SCENES/level" + str(level) + ".tscn")
