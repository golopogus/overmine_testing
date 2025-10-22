extends Node2D

signal drone_ready_for_tiles
signal drone_ready_for_check

func get_possible_tiles(data):
	emit_signal("drone_ready_for_tiles",data)

func check_tile(pos,path,instance):
	emit_signal("drone_ready_for_check",pos,path,instance)
	

	
