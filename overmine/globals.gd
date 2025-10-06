extends Node2D

func _ready() -> void:
	var scene_load = preload("res://main_scene.tscn")
	var scene = scene_load.instantiate()
	add_child(scene)
	Engine.max_fps = 0
func _process(delta: float) -> void:
	print(str(Engine.get_frames_per_second()))
	
