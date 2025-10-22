extends Node2D

signal drone_ready

func send_drone_signal(data):
	emit_signal("drone_ready",data)
	

	
