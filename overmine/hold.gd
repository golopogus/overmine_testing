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
var to_draw = ''
var center = Vector2()

func _ready() -> void:
	
	initialize_shapes()
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("left_click"):
		if drawing == false:
			list_of_pts = []
			drawing = true
			to_draw = ''
	
	if Input.is_action_just_released("left_click"):
		
			var updated_list = initialize_pts(list_of_pts)
			get_boundary(updated_list)
			drawing = false

func _process(_delta: float) -> void:
	
	if drawing == true:
		var mouse_pos = get_global_mouse_position()		
		if current_pos != mouse_pos:
			current_pos = mouse_pos
			list_of_pts.append(current_pos)
			queue_redraw() 

func _draw() -> void:

	draw_polyline(list_of_pts,Color(.2,.3,10),10)

	#match to_draw:
		#'square': draw_polyline(shape_dict[to_draw]['all_pts'],Color(.9,.3,.3),4)
		#'triangle': draw_polyline(shape_dict[to_draw]['all_pts'],Color(.6,.6,.6),4)
		#'circle': draw_circle(circle_pos,radius,Color(.4,.7,.1),false,4)
		#'diamond': draw_polyline(shape_dict[to_draw]['all_pts'],Color(.9,.8,.3),4)
		#'upside_down_triangle': draw_polyline(shape_dict[to_draw]['all_pts'],Color(.4,.7,.1),4)
	
	draw_polyline(shape_dict['triangle']['all_pts'],Color(.6,.6,.6),4)
	draw_circle(center,radius,Color(.4,.7,.1),false,4)
	draw_polyline(shape_dict['diamond']['all_pts'],Color(.9,.8,.3),4)
	draw_polyline(shape_dict['upside_down_triangle']['all_pts'],Color(.1,.1,.1),4)
	draw_polyline(shape_dict['square']['all_pts'],Color(.9,.3,.3),4)
	

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
			

func get_boundary(pts):
	
	var x_pts = []
	var y_pts = []
	
	for pt in pts:
		x_pts.append(pt.x)
		y_pts.append(pt.y)
	
	var x_max = x_pts.max()
	var x_min = x_pts.min()
	var y_max = y_pts.max()
	var y_min = y_pts.min()

	var x_len = abs(x_max - x_min)
	var y_len = abs(y_max - y_min)
	var x_2_center = x_len/2.0
	var y_2_center = y_len/2.0
	
	center = Vector2(x_min + x_2_center,y_min + y_2_center)
	radius = (x_2_center + y_2_center)/2.0
	draw_reference_shapes(Vector2(x_2_center,y_2_center),pts)
	
func draw_reference_shapes(dist_from_center,pts):
	
	get_square_pts(dist_from_center)
	get_triangle_pts(dist_from_center)
	get_diamond_pts(dist_from_center)
	get_upside_down_triangle_pts(dist_from_center)
	
	get_avg_dist(pts)
	
func get_avg_dist(pts):
	
	var circle_guess = check_circle_accuracy(pts)
	var square_guess = check_accuracy(pts,'square')
	var triangle_guess = check_accuracy(pts,'triangle')
	var diamond_guess = check_accuracy(pts,'diamond')
	var upside_down_triangle_guess = check_accuracy(pts,'upside_down_triangle')
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
	
	print('My guess is ... a ' + shape_name + ' with an average ' + str(floor(answer)) + ' pixels off from perfect' )
	print('triangle: ' + str(triangle_guess) 
		+ ' sqaure: ' + str(square_guess)
		+ ' circle: ' + str(circle_guess)
		+ ' diamond: ' + str(diamond_guess)
		+ 'upt: ' + str(upside_down_triangle_guess))

	to_draw = shape_name
	queue_redraw()
	
func check_circle_accuracy(pts):
	
	var total_dist = 0
	
	for i in pts:
		var dist_from_center = calculate_dist(i,center)
		var dist = abs(dist_from_center - radius)
		total_dist += dist

	var average_dist = total_dist/(pts.size())

	return average_dist
		
func check_accuracy(pts,shape):
	var total_dist = 0
	var count = 0
	#if shape == 'square':
		#can_print = true
	for i in pts:
		var dist = []
		for line in shape_dict[shape]:
			if line != 'all_pts':
				dist.append(determine_if_perp(i,shape_dict[shape][line]['pts'][0],shape_dict[shape][line]['pts'][1],shape_dict[shape][line]['slope'],shape))
		#if can_print == true:
			#can_print = false
		total_dist += dist.min()
		count += 1.0
	
	var average_dist = total_dist/count

	return average_dist

				
func determine_if_perp(pos,p1,p2,slope,shape):

		var x_int
		var y_int
		var min_dist
		
		if str(slope) == 'undefined':
			
			x_int = p1.x
			y_int = pos.y
			#if can_print == true:
				#print(' int: (' + str(x_int) + ',' + str(y_int) + ')')
				#print('p1: ' + str(p1))
				#print( 'p2: ' + str(p2))
				#print('pos: ' + str(pos))
				#print('y_int: ' + str(y_int) + ' > ' + str(p1.y))
				#print('y_int: ' + str(y_int) + ' < ' + str(p2.y))
			if y_int < p1.y and y_int > p2.y:
				
				min_dist = calculate_dist(pos,Vector2(x_int,y_int))
			else:
				min_dist = handle_corners(pos,shape)
				
		elif slope == 0:
			y_int = p1.y
			x_int = pos.x
			#if can_print == true:
				#print(' int: (' + str(x_int) + ',' + str(y_int) + ')')
				#print('p1: ' + str(p1))
				#print( 'p2: ' + str(p2))
				#print('pos: ' + str(pos))
				#print('x_int: ' + str(x_int) + ' > ' + str(p1.x))
				#print('x_int: ' + str(x_int) + ' < ' + str(p2.x))
				
			if x_int > p1.x and x_int < p2.x:
				min_dist = calculate_dist(pos,Vector2(x_int,y_int))
			else:
				min_dist = handle_corners(pos,shape)
		else:
			var slope1 = slope
			var b1 = p1.y - slope1 * p1.x
			var slope2 = -1.0/slope
			#var b2 = pos.y + 1/slope * pos.x
			var b2 = pos.y - slope2 * pos.x
			x_int = ((b2-b1) * slope1)/(1.0+pow(slope1,2))
			y_int = slope2 * x_int + b2
			#if can_print == true:
				#print('slope: ' + str(slope) + ', int: (' + str(x_int) + ',' + str(y_int) + ')')
				#print('p1: ' + str(p1) + ',' + str(p2))
				#print('pos: ' + str(pos))
				#print('y=' + str(slope) + 'x+' + str(b1))
				#print('y=-1/' + str(slope) + 'x+' + str(b2))
		
			if x_int > p1.x and x_int < p2.x:
				min_dist = calculate_dist(pos,Vector2(x_int,y_int))
			else:
				min_dist = handle_corners(pos,shape)
		
		return min_dist
	
func handle_corners(pos,shape):
	var dist = []
	
	for i in range(shape_dict[shape]['all_pts'].size() - 1):
		dist.append(calculate_dist(pos,shape_dict[shape]['all_pts'][i]))
			
	return dist.min()
	
func get_slope(pt1,pt2):
	var rise = pt2.y - pt1.y
	var run = pt2.x - pt1.x
	var slope
	if run == 0:
		slope = 'undefined'
	else:
		slope = rise/run
		
	return slope
			
func calculate_dist(v1,v2):
	var dist_from_center = pow(pow(v1.x - v2.x,2) + pow(v1.y - v2.y,2),.5)
	return dist_from_center

func calculate_dir(v1,v2):
	var dir = (v2 - v1).normalized()
	return dir

func initialize_shapes():
	
	shape_dict = {		
	'square' = {
		'all_pts' = [],
		'line1' = {
			'pts': 0,
			'slope': 0
			},
		'line2' = {
			'pts': 0,
			'slope': 0
			},
		'line3' = {
			'pts': 0,
			'slope': 0
			},
		'line4' = {
			'pts': 0,
			'slope': 0
			}
		},
	'triangle' = {
		'all_pts' = [],
		'line1' = {
			'pts': 0,
			'slope': 0
			},
		'line2' = {
			'pts': 0,
			'slope': 0
			},
		'line3' = {
			'pts': 0,
			'slope': 0
			}
		},
	'diamond' = {
		'all_pts' = [],
		'line1' = {
			'pts': 0,
			'slope': 0
			},
		'line2' = {
			'pts': 0,
			'slope': 0
			},
		'line3' = {
			'pts': 0,
			'slope': 0
			},
		'line4' = {
			'pts': 0,
			'slope': 0
			}
		},
	'upside_down_triangle' = {
		'all_pts' = [],
		'line1' = {
			'pts': 0,
			'slope': 0
			},
		'line2' = {
			'pts': 0,
			'slope': 0
			},
		'line3' = {
			'pts': 0,
			'slope': 0
			}
		}
	}
	
func get_square_pts(dist_from_center):
	
	var pt1 = center + Vector2(-1,-1) * dist_from_center
	var pt2 = center + Vector2(1,-1) * dist_from_center
	var pt3 = center + Vector2(1,1) * dist_from_center
	var pt4 = center + Vector2(-1,1) * dist_from_center

	shape_dict['square']['all_pts'] = [pt1,pt2,pt3,pt4,pt1]
	shape_dict['square']['line1']['pts'] = [pt1,pt2]
	shape_dict['square']['line2']['pts'] = [pt3,pt2]
	shape_dict['square']['line3']['pts'] = [pt4,pt3]
	shape_dict['square']['line4']['pts'] = [pt4,pt1]

	
	for line in shape_dict['square']:
		if line != 'all_pts':
			shape_dict['square'][line]['slope'] = get_slope(shape_dict['square'][line]['pts'][0],shape_dict['square'][line]['pts'][1])

			
func get_triangle_pts(dist_from_center):

	var pt1 = center + Vector2(-1,1) * dist_from_center
	var pt2 = center + Vector2.UP * dist_from_center
	var pt3 = center + Vector2(1,1) * dist_from_center
	
	shape_dict['triangle']['all_pts'] = [pt1,pt2,pt3,pt1]
	shape_dict['triangle']['line1']['pts'] = [pt1,pt2]
	shape_dict['triangle']['line2']['pts'] = [pt2,pt3]
	shape_dict['triangle']['line3']['pts'] = [pt1,pt3]
	
	for line in shape_dict['triangle']:
		if line != 'all_pts':
			shape_dict['triangle'][line]['slope'] = get_slope(shape_dict['triangle'][line]['pts'][0],shape_dict['triangle'][line]['pts'][1])

func get_upside_down_triangle_pts(dist_from_center):

	var pt1 = center + Vector2(-1,-1) * dist_from_center
	var pt2 = center + Vector2.DOWN * dist_from_center
	var pt3 = center + Vector2(1,-1) * dist_from_center
	
	shape_dict['upside_down_triangle']['all_pts'] = [pt1,pt2,pt3,pt1]
	shape_dict['upside_down_triangle']['line1']['pts'] = [pt1,pt2]
	shape_dict['upside_down_triangle']['line2']['pts'] = [pt2,pt3]
	shape_dict['upside_down_triangle']['line3']['pts'] = [pt1,pt3]
	
	for line in shape_dict['upside_down_triangle']:
		if line != 'all_pts':
			shape_dict['upside_down_triangle'][line]['slope'] = get_slope(shape_dict['upside_down_triangle'][line]['pts'][0],shape_dict['upside_down_triangle'][line]['pts'][1])

func get_diamond_pts(dist_from_center):
	
	var pt1 = center + Vector2.LEFT * dist_from_center
	var pt2 = center + Vector2.UP * dist_from_center
	var pt3 = center + Vector2.RIGHT * dist_from_center
	var pt4 = center + Vector2.DOWN * dist_from_center
	
	shape_dict['diamond']['all_pts'] = [pt1,pt2,pt3,pt4,pt1]
	shape_dict['diamond']['line1']['pts'] = [pt1,pt2]
	shape_dict['diamond']['line2']['pts'] = [pt2,pt3]
	shape_dict['diamond']['line3']['pts'] = [pt4,pt3]
	shape_dict['diamond']['line4']['pts'] = [pt1,pt4]
	
	for line in shape_dict['diamond']:
		if line != 'all_pts':
			shape_dict['diamond'][line]['slope'] = get_slope(shape_dict['diamond'][line]['pts'][0],shape_dict['diamond'][line]['pts'][1])
