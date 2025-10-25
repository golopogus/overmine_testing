extends Node2D

var drawing : bool
var list_of_pts = []
var current_pos = Vector2()
var shape_dict = {}
var radius = 1
var circle_pos = Vector2()
var square_pts = []
var new_pts = []
var triangle_pts = []
var upside_down_triangle_pts = []
var radius2 = 1
var radius3 = 1
var can_print = false
var diamond_pts = []
var list_of_points2 = []
var timer_running = false
var drawing2 = false
var x_pts = []

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("left_click"):
		if timer_running == false:
			if drawing == false:
				list_of_pts = []
				drawing = true
		
		else:
			if drawing2 == false:
				$Timer.stop()
				list_of_points2 = []
				drawing2 = true
			
		
	if Input.is_action_just_released("left_click"):
		if drawing == true:
			print('first')
			timer_running = true
			$Timer.start()
			drawing = false
			
		elif drawing2 == true:
			print('second')


			var updated_list = initialize_pts(list_of_pts)
			var updated_list2 = initialize_pts(list_of_points2)
			check_double(updated_list,updated_list2)
			timer_running = false
			drawing2 = false
		#var updated_list = initialize_pts(list_of_pts)
		#check(updated_list)
		#est_list = []
		
		

		
		
		
func _process(_delta: float) -> void:
	
	if drawing == true:
		#await get_tree().create_timer(.5).timeout
		var mouse_pos = get_global_mouse_position()		
		#if (current_pos - mouse_pos).length() > 10:
		if current_pos != mouse_pos:
			current_pos = mouse_pos
			list_of_pts.append(current_pos)
			queue_redraw() 
	elif drawing2 == true:

		var mouse_pos = get_global_mouse_position()		
		#if (current_pos - mouse_pos).length() > 10:
		if current_pos != mouse_pos:
			current_pos = mouse_pos
			list_of_points2.append(current_pos)
			queue_redraw() 
	
	
	
func _draw() -> void:

	draw_polyline(list_of_pts,Color(.2,.3,10),10)

	draw_polyline(list_of_points2,Color(.2,.3,10),10)
	draw_polyline(x_pts,Color(.9,.7,.5),4)
	#draw_polyline(square_pts,Color(.9,.3,.3),4)
	#draw_polyline(triangle_pts,Color(.6,.6,.6),4)
	#draw_polyline(diamond_pts,Color(.9,.8,.3),4)
	#draw_polyline(upside_down_triangle_pts,Color(.4,.7,.1),4)
	#
	
	#draw_circle(circle_pos,radius,Color(.4,.7,.1),false,4)

	

			
func initialize_pts(pts):
	var dist = []
	
	for i in len(pts):
		if i == len(pts) - 1:
			pass
		else:
			dist.append(calculate_dist(pts[i],pts[i+1]))		
	
	var min_dist = dist.min()
	
	new_pts = []
	for i in len(pts):
		if i == len(pts) - 1:
			new_pts.append(pts[i])
		else:
			new_pts.append(pts[i])
			var current_dist = calculate_dist(pts[i],pts[i+1])
			var num_cuts = floor(current_dist / min_dist) - 1.0
			var dir = calculate_dir(pts[i],pts[i+1])
			if num_cuts > 0:
				for cut in num_cuts:
					
					var new_pos = pts[i] + (cut + 1) * dir
					new_pts.append(new_pos)
	
	var new_dist = []
	for i in len(new_pts):
		if i == len(new_pts) - 1:
			pass
		else:
			new_dist.append(calculate_dist(new_pts[i],new_pts[i+1]))
	

	return new_pts
			
	
	
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
	circle_pos = Vector2(x_min + x_len/2.0,y_min + y_len/2.0)
	
	var avg_len = (x_len + y_len)/2.0
	radius = avg_len/2.0
	
	get_square_pts(Vector2(x_len,y_len))
	get_triangle_pts(Vector2(x_len,y_len))
	get_diamond_pts(Vector2(x_len,y_len))
	get_upside_down_triangle_pts(Vector2(x_len,y_len))
	
	

	var circle_guess = check_circle_accuracy(pts)
	var square_guess = check_square_accuracy(pts,avg_len)
	var triangle_guess = check_triangle_accuracy(pts)
	var diamond_guess = check_diamond_accuracy(pts)
	var upside_down_triangle_guess = check_upside_down_triangle_accuracy(pts)
	var shape_name
	var answer
	var total_guess = [triangle_guess,square_guess,circle_guess,diamond_guess,upside_down_triangle_guess]
	
	if circle_guess == total_guess.min():
		shape_name = 'circle'
		answer = circle_guess
	elif square_guess == total_guess.min():
		shape_name = 'square'
		answer = square_guess
	elif triangle_guess == total_guess.min():
		shape_name = 'triangle'
		answer = triangle_guess
	elif diamond_guess == total_guess.min():
		shape_name = 'diamond'
		answer = diamond_guess
	elif upside_down_triangle_guess == total_guess.min():
		shape_name = 'upside_down_triangle'
		answer = upside_down_triangle_guess
	#if circle_guess > square_guess:
		#shape_name = 'circle'
		#answer = circle_guess
	#else:
		#shape_name = 'square'
		#answer = square_guess
	print(total_guess)
	print('My guess is ... a ' + shape_name + ' with an average ' + str(floor(answer)) + ' pixels off from perfect' )
	queue_redraw()
	
func check_circle_accuracy(pts):
	#var all_dist = []
	var count = 0
	var total_percentage = 0
	var total_distance = 0
	var t = 0
	
	for i in pts:
		var dist_from_center = pow(pow(i.x - circle_pos.x,2) + pow(i.y - circle_pos.y,2),.5)
		var dist = abs(dist_from_center - radius)
		var actual_dist = dist_from_center - radius
		#var percentage = radius / (dist+radius)
		var percentage = dist/radius
		total_distance += actual_dist
		total_percentage += percentage
		count += 1.0
		t += dist
	
	var average_dist = total_distance/count
	var tt = t/count
	var actual_area = PI * pow(average_dist + radius,2.0)
	var area = PI * pow(radius,2.0)
	var area_percentage = (1 - abs((actual_area - area) / area)) * 100.0
	var ans = (1 - total_percentage/count) * 100.0
	var answer = (area_percentage + ans)/2.0

	#return ans
	return tt


		
		
	
			
func get_square_pts(avg):
	var center = circle_pos
	var corner1 = center + Vector2(-1,-1) * avg/2.0
	var corner2 = center + Vector2(1,-1) * avg/2.0
	var corner3 = center + Vector2(-1,1) * avg/2.0
	var corner4 = center + Vector2(1,1) * avg/2.0
	
	square_pts = [corner1,corner2,corner4,corner3,corner1]
			
func get_triangle_pts(avg):
	var center = circle_pos
	var corner1 = center + Vector2(-1,1) * avg/2.0
	var corner2 = center + Vector2(1,1) * avg/2.0
	var tip = center + Vector2.UP * avg/2.0
	
	
	triangle_pts = [corner1,tip,corner2,corner1]

func get_upside_down_triangle_pts(avg):
	var center = circle_pos
	var pt1 = center + Vector2(-1,-1) * avg/2.0
	var pt2 = center + Vector2(1,-1) * avg/2.0
	var pt3 = center + Vector2.DOWN * avg/2.0
	
	
	upside_down_triangle_pts = [pt1,pt2,pt3,pt1]

func get_diamond_pts(avg):
	var center = circle_pos
	var pt1 = center + Vector2.LEFT * avg/2.0
	var pt2 = center + Vector2.UP * avg/2.0
	var pt3 = center + Vector2.RIGHT * avg/2.0
	var pt4 = center + Vector2.DOWN * avg/2.0
	
	diamond_pts = [pt1,pt2,pt3,pt4,pt1]
func get_x_pts(avg):
	var center = circle_pos
	var pt1 = center + Vector2(-1,-1) * avg/2.0
	var pt2 = center + Vector2(1,-1) * avg/2.0
	var pt3 = center + Vector2(-1,1) * avg/2.0
	var pt4 = center + Vector2(1,1) * avg/2.0
	
	x_pts = [pt1,center,pt2,center,pt3,center,pt4]
	
func check_triangle_accuracy(pts):
	var rise = triangle_pts[1].y - triangle_pts[0].y
	var run = triangle_pts[1].x - triangle_pts[0].x
	var slope = rise/run
	
	var line_dict = {}
	line_dict['line1'] = {
		'pts': [triangle_pts[0], triangle_pts[1]],
		'slope': slope
		}
	line_dict['line2'] = {
		'pts': [triangle_pts[1], triangle_pts[2]],
		'slope': -slope
		}
	line_dict['line3'] = {
		'pts': [triangle_pts[0], triangle_pts[2]],
		'slope': 0
		}
		
	var total_dist = 0
	var count = 0

	for i in pts:
		var dist = []
		for line in line_dict:

			dist.append(determine_if_perp(i,line_dict[line]['pts'][0],line_dict[line]['pts'][1],line_dict[line]['slope'],'triangle'))

		total_dist += dist.min()
		count += 1.0
	
	var average_dist = total_dist/count

	return average_dist
	
func check_upside_down_triangle_accuracy(pts):
	var rise = upside_down_triangle_pts[0].y - upside_down_triangle_pts[2].y
	var run = upside_down_triangle_pts[0].x - upside_down_triangle_pts[2].x

	var slope = rise/run
	
	var line_dict = {}
	line_dict['line1'] = {
		'pts': [upside_down_triangle_pts[0], upside_down_triangle_pts[2]],
		'slope': slope
		}
	line_dict['line2'] = {
		'pts': [upside_down_triangle_pts[2], upside_down_triangle_pts[1]],
		'slope': -slope
		}
	line_dict['line3'] = {
		'pts': [upside_down_triangle_pts[0], upside_down_triangle_pts[1]],
		'slope': 0
		}
		
	var total_dist = 0
	var count = 0
	can_print = true
	for i in pts:
		var dist = []
		for line in line_dict:

			dist.append(determine_if_perp(i,line_dict[line]['pts'][0],line_dict[line]['pts'][1],line_dict[line]['slope'],'upside_down_triangle'))
		can_print = false
		total_dist += dist.min()
		count += 1.0
	
	var average_dist = total_dist/count

	return average_dist
	
func check_diamond_accuracy(pts):
	var rise1 = diamond_pts[1].y - diamond_pts[0].y
	var run1 = diamond_pts[1].x - diamond_pts[0].x
	var slope1 = rise1/run1
	
	var rise2 = diamond_pts[2].y - diamond_pts[1].y
	var run2 = diamond_pts[2].x - diamond_pts[1].x
	var slope2 = rise2/run2
	
	var line_dict = {}
	line_dict['line1'] = {
		'pts': [diamond_pts[0], diamond_pts[1]],
		'slope': slope1
		}
	line_dict['line2'] = {
		'pts': [diamond_pts[3], diamond_pts[2]],
		'slope': slope1
		}
	line_dict['line3'] = {
		'pts': [diamond_pts[1], diamond_pts[2]],
		'slope': slope2
		}
	line_dict['line4'] = {
		'pts': [diamond_pts[0], diamond_pts[3]],
		'slope': slope2
		}
		
	var total_dist = 0
	var count = 0
	
	for i in pts:
		var dist = []
		for line in line_dict:
			dist.append(determine_if_perp(i,line_dict[line]['pts'][0],line_dict[line]['pts'][1],line_dict[line]['slope'],'diamond'))
		total_dist += dist.min()
		count += 1.0
	
	var average_dist = total_dist/count

	return average_dist
				
func determine_if_perp(pos,p1,p2,slope,shape):

		var x_int
		var y_int
		var min_dist
		
		if slope == 0:
			y_int = p1.y
			x_int = pos.x
		else:
			var slope1 = slope
			var b1 = p1.y - slope1 * p1.x
			var slope2 = -1.0/slope
			#var b2 = pos.y + 1/slope * pos.x
			var b2 = pos.y - slope2 * pos.x
			x_int = ((b2-b1) * slope1)/(1.0+pow(slope1,2))
			y_int = slope2 * x_int + b2
			if can_print == true:
				print('slope: ' + str(slope) + ', int: (' + str(x_int) + ',' + str(y_int) + ')')
				print('p1: ' + str(p1) + ',' + str(p2))
				print('pos: ' + str(pos))
				print('y=' + str(slope) + 'x+' + str(b1))
				print('y=-1/' + str(slope) + 'x+' + str(b2))
		
		
		if x_int > p1.x and x_int < p2.x:
			min_dist = calculate_dist(pos,Vector2(x_int,y_int))
			
		else:
			
			min_dist = handle_corners(pos,shape)
		
		return min_dist
	
func handle_corners(pos,shape):
	var dist = []
	if shape == 'triangle':
		for i in triangle_pts:
			dist.append(calculate_dist(pos,i))
	
	if shape == 'diamond':
		for i in diamond_pts:
			dist.append(calculate_dist(pos,i))

	
	if shape == 'upside_down_triangle':
		for i in upside_down_triangle_pts:
			dist.append(calculate_dist(pos,i))
	return dist.min()
	
	
	
	
	
func check_square_accuracy(pts,avg_len):
	var c1 = square_pts[0]
	var c2 = square_pts[1]
	var c3 = square_pts[3]
	var c4 = square_pts[2]
	var dist
	var count = 0
	var total_percentage = 0
	var total_dist = 0
	var real_dist
	var t = 0
	for i in pts:
		if i.x < c1.x:
			if i.y > c4.y:
				dist = calculate_dist(i,c4)
				real_dist = dist
			elif i.y < c1.y:
				dist = calculate_dist(i,c1)
				real_dist = dist
			else:
				dist = abs(i.x-c1.x)
				real_dist = dist
		
		elif i.x > c2.x:
			if i.y > c3.y:
				dist = calculate_dist(i,c3)
				real_dist = dist
			elif i.y < c2.y:
				dist = calculate_dist(i,c2)
				real_dist = dist
			else:
				dist = abs(i.x-c2.x)
				real_dist = dist
		
		elif i.y < c1.y:
			dist = abs(i.y - c1.y)	
			real_dist = dist
		
		elif i.y > c3.y:
			dist = abs(i.y - c3.y)
			real_dist = dist
			
		
		else:
			var min1 = (i.x - c1.x)
			var min2 =  (c2.x - i.x)
			var min3 = (i.y - c1.y) 
			var min4 = (c3.y - i.y) 
			dist = min(min1,min2,min3,min4)
			real_dist = -dist
		
		total_dist += real_dist
		var percentage = dist/(avg_len/2.0)
		total_percentage += percentage
		count += 1.0
		t += dist
	
	var tt = t/count
	var average_dist = total_dist/count
	var actual_area = pow((average_dist + avg_len/2.0) * 2.0,2.0)
	var area = pow(avg_len,2.0)
	var percentage_area = (1 - abs((actual_area - area) / area)) * 100.0
	var average_percentage = (1 - total_percentage/count) * 100.0

	var answer = (percentage_area + average_percentage)/2.0
	#return average_percentage
	return tt

		
		
	
				
func calculate_dist(v1,v2):
	var dist_from_center = pow(pow(v1.x - v2.x,2) + pow(v1.y - v2.y,2),.5)
	return dist_from_center

func calculate_dir(v1,v2):
	var dir = (v2 - v1).normalized()
	return dir
					
func _on_timer_timeout() -> void:
	$Timer.stop()
	print('time')
	var updated_list = initialize_pts(list_of_pts)
	check(updated_list)
	timer_running = false
	drawing = false
func check_double(pts,pts2):
	var x_min
	var y_min
	var x_max
	var y_max
	var x_min1
	var y_min1
	var x_max1
	var y_max1
	var x_min2
	var y_min2
	var x_max2
	var y_max2
	var initialize1 = true
	var initialize2 = true
	
	for i in pts:
		if initialize1 == true:
			x_min1 = i.x
			y_min1 = i.y
			x_max1 = i.x
			y_max1 = i.y
			initialize1 = false
		else:
			if i.x < x_min1:
				x_min1 = i.x
			if i.y < y_min1:
				y_min1 = i.y
			if i.x > x_max1:
				x_max1 = i.x
			if i.y > y_max1:
				y_max1 = i.y
				

	for i in pts2:
		if initialize2 == true:
			x_min2 = i.x
			y_min2 = i.y
			x_max2 = i.x
			y_max2 = i.y
			initialize2 = false
		else:
			if i.x < x_min2:
				x_min2 = i.x
			if i.y < y_min2:
				y_min2 = i.y
			if i.x > x_max2:
				x_max2 = i.x
			if i.y > y_max2:
				y_max2 = i.y
	

	if x_min1 < x_min2:
		x_min = x_min1
	else:
		x_min = x_min2
	if y_min1 < y_min2:
		y_min = y_min1
	else:
		y_min = y_min2
		
	if x_max1 > x_max2:
		x_max = x_max1
	else:
		x_max = x_max2
	if y_max1 > y_max2:
		y_max = y_max1
	else:
		y_max = y_max2
	
	var x_len = x_max - x_min
	var y_len = y_max - y_min
	circle_pos = Vector2(x_min + x_len/2.0,y_min + y_len/2.0)
	var avg_len = (x_len + y_len)/2.0
	radius = avg_len/2.0
	
	get_x_pts(Vector2(x_len,y_len))
	
	#var circle_guess = check_circle_accuracy(pts)
#
	#var shape_name
	#var answer
	#var total_guess = []
	#
	#if circle_guess == total_guess.min():
		#shape_name = 'circle'
		#answer = circle_guess
#
	#print(total_guess)
	#print('My guess is ... a ' + shape_name + ' with an average ' + str(floor(answer)) + ' pixels off from perfect' )
	queue_redraw()
