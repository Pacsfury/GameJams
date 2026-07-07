extends Control

@onready var points: Label = $CanvasLayer/points
@onready var mult: Label = $CanvasLayer/mult
@onready var game = %"Game Manager"

func update_points():
	points.text = str(game.points)

func update_mult():
	mult.text = 'x' + str(game.mult)


func _on_end_pressed() -> void:
	get_tree().change_scene_to_file("res://SCENES/levelmap.tscn")
