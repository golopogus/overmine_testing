extends Node2D

var drawing : bool
var list_of_pts = []
var current_pos = Vector2()
var est_list = []
var shape_dict = {}
var test =[]
var a = []
var radius = 1
var circle_pos = Vector2()
var square_pts = []

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("left_click"):
		if drawing == false:
			list_of_pts = []
			a = []
			drawing = true
		
	if Input.is_action_just_released("left_click"):
		
		check(list_of_pts)
		test =[]
		
		est_list = []
		
		drawing = false
		
		
		
func _process(_delta: float) -> void:
	
	if drawing == true:
		#await get_tree().create_timer(.5).timeout
		var mouse_pos = get_global_mouse_position()		
		#if (current_pos - mouse_pos).length() > 10:
		if current_pos != mouse_pos:
			current_pos = mouse_pos
			list_of_pts.append(current_pos)
			queue_redraw() 
	
	
	
func _draw() -> void:
	
	draw_polyline(list_of_pts,Color(.2,.3,10),10)
	draw_circle(circle_pos,radius,Color(.4,.7,.1),false,4)
	draw_polyline(square_pts,Color(.9,.3,.3),4)
	

			

			
func check(pts):
	var x_min
	var y_min
	var x_max
	var y_max
	var initialize = true
	
	for i in pts:
		if initialize == true:
			x_min = i.x
			y_min = i.y
			x_max = i.x
			y_max = i.y
			initialize = false
		else:
			if i.x < x_min:
				x_min = i.x
			if i.y < y_min:
				y_min = i.y
			if i.x > x_max:
				x_max = i.x
			if i.y > y_max:
				y_max = i.y
	
	var x_len = x_max - x_min
	var y_len = y_max - y_min
	circle_pos = Vector2(x_min + x_len/2,y_min + y_len/2)
	var avg = (x_len + y_len)/2
	
	get_square_pts(x_min,x_max,y_min,y_max,avg)
	
	radius = avg/2
	check_circle_accuracy(pts)
	queue_redraw()
	
func check_circle_accuracy(pts):
	var all_dist = []
	for i in pts:
		var dist_from_center = pow(pow(i.x - circle_pos.x,2) + pow(i.y - circle_pos.y,2),.5)
		var dist = abs(dist_from_center - radius)
		all_dist.append(dist)
	
	print(all_dist)		
func get_square_pts(x_min,x_max,y_min,y_max,avg):
	var center = circle_pos
	var corner1 = center + Vector2(-1,-1) * avg/2
	var corner2 = center + Vector2(1,-1) * avg/2
	var corner3 = center + Vector2(-1,1) * avg/2
	var corner4 = center + Vector2(1,1) * avg/2
	
	square_pts = [corner1,corner2,corner4,corner3,corner1]		
	
#func check(pts):
	#
	#for i in len(pts):
		#if i != 0:
			#var exact_dir = (pts[i] - pts[i-1]).normalized()
			#get_est_dir(exact_dir)
	#
	#guess_shape(est_list)
			#
#func get_est_dir(exact_dir):
	#
	#var x = floor(exact_dir.x / 0.5 + 0.5) * 0.5
	#var y = floor(exact_dir.y / 0.5 + 0.5) * 0.5
	#
	#est_list.append(Vector2(x,y))
	#guess_shape(est_list)
	#
#func guess_shape(list):
#
	#for i in 5:
		#var posx = -1 + i * .5
		#for j in 5:
			#var posy = -1 + j * .5
			#shape_dict[Vector2(posx,posy)] = {
				#'value': 0
			#}
#
		#
	#for i in list:
		#var all_dir = []
		#for j in shape_dict:
			#all_dir.append(j)
		#all_dir.erase(i)
		#reset_dir(all_dir)
		#
		#shape_dict[i]['value'] += 1
		#
	#
	#for i in shape_dict:
		#if shape_dict[i]['value'] > 3:
			#for j in shape_dict[i]['value']:
				#test.append(i)
			#a.append(shape_dict[i]['value'])
#
	#calculate_new_shape(test)
	#
#func reset_dir(list):
	#for i in list:
		#if shape_dict[i]['value'] > 3:
			#for j in shape_dict[i]['value']:
				#test.append(i)
			#a.append(shape_dict[i]['value'])
		#shape_dict[i] = {
		#'value': 0
	#}
#
#func calculate_new_shape(list):
	#
	#var new_list = []
	#var curr_pos = get_global_mouse_position()
	#var pos = Vector2()
#
	#for i in len(list):
		#pos += list[i] * 10
		#new_list.append(pos + curr_pos)
	#
	#list_of_pts = new_list
	##print(get_global_mouse_position())
	##print(list_of_pts
	#print(a)
	#queue_redraw()
			#
		#
		#
