extends Area2D

var player_position
var radius
var max_mouse_dist = 0
var radius_center
var off_center = false
var mouse_diff = Vector2()
var center
var used_mouse_pos

func _process(_delta: float) -> void:

	center = get_parent().player_position
	
	radius = 200
	var mouse_pos = get_global_mouse_position()
	
	if get_parent().gamestart == true:
		
		used_mouse_pos = mouse_pos - mouse_diff
		var mouse_dist = (used_mouse_pos - center).length()
		
		if mouse_dist < radius:
			
			position = used_mouse_pos
		
		else:

			if mouse_dist >= max_mouse_dist:
				max_mouse_dist = mouse_dist
		
			else:
				var new_pos = center + (used_mouse_pos - center).normalized() * radius
				mouse_diff = mouse_pos - new_pos
				max_mouse_dist = 0
			
			position = center + (used_mouse_pos - center).normalized() * radius
		
	
			
	else:
		position = mouse_pos
