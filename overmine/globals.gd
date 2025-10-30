extends Node2D

signal drone_ready
signal drill_ready
signal ready_to_click
signal drone_ready_for_check
signal ball_ready
signal ball_pls

func get_tiles(data,grid,type):
	if type == 'drone':
		emit_signal("drone_ready",data,grid,type)
	elif type == 'drill':
		emit_signal("drill_ready",data,grid,type)
	elif type == "ball":
		emit_signal("ball_pls",data,grid,type)

func check_tile(pos,path,instance):
	emit_signal("drone_ready_for_check",pos,path,instance)
	
func get_init(path):
		emit_signal("ball_ready",path)

func click_tile(pos):
	emit_signal('ready_to_click',pos)
	

	
