extends Control


func _on_lvl_pressed(sender) -> void:
	get_tree().change_scene_to_file("res://SCENES/level" + sender + ".tscn")
