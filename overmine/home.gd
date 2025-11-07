extends Node2D

var upgrade_load = preload("res://upgrade_menu.tscn")




func _on_shop_button_pressed() -> void:
	$upgrade_menu.visible = true


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")
