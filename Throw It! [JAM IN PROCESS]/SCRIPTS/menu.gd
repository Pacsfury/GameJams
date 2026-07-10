extends Control

@onready var play: Button = $VBoxContainer/play
@onready var quit: Button = $VBoxContainer/quit

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://SCENES/levelmap.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit(0)


func _on_play_mouse_entered() -> void:
	play.position.x += 30


func _on_quit_mouse_entered() -> void:
	quit.position.x += 30


func _on_quit_mouse_exited() -> void:
	quit.position.x -= 30


func _on_play_mouse_exited() -> void:
	play.position.x -= 30
