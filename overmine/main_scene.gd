extends Node2D

#signal upgrade_menu_update(all_upgrade_data)


#var mine_radius = [0,3]
var flag_correct = true
var lives = 1
var round_points = 0

var all_upgrade_data = {}
var all_store_data = {}

#var num_of_drones = 0
var num_of_drones = 0
var num_of_drills = 0
var upgrade_in_hand = false
var upgrade
const grid_size_options = [[8,8],[50,50],[40,40]]
var chosen_grid_size = grid_size_options[2]
var num_of_chunks = Vector2(10,10)
var chunk_split
var initial_pos = Vector2(0,0)
var chunk_size = Vector2()
var x_length
var y_length
var start = false
var chunk_dict = {}
var gamestart = false

var initial_chunk_pos = Vector2(0,0)
var number_of_mines_per_chunk = 320
var moveable = false
var local_mous_pos

var current_neighbors = []
var stored_pos = Vector2()
var current_chunk
var visible_area
var safe_tiles = []
var tiles_in_current_chunk = []
var in_game_menu = false
var tile_dict = {} # pos = [tile.name, 'unknown' (type), value, true (hidden),marked]
var tile_load = preload("res://tile.tscn")
var test_load = preload("res://test.tscn")
var chunk_load = preload("res://chunk_loc.tscn")
var tile_holder_load = preload("res://tile_holder.tscn")
var upgrade_load = preload("res://upgrade_menu.tscn")
var mouse_in = false

#############################################################################	
#############################################################################	
#############################################################################

func _notification(what: int) -> void:
	
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_in = true
	
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_in = false
		
func _ready() -> void:
	
	x_length = $sprites/hidden.texture.get_width()
	y_length = $sprites/hidden.texture.get_height()
	#$CanvasLayer/sprite_holder/normal.visible = true
	chunk_size = Vector2(chosen_grid_size[0],chosen_grid_size[1]) * Vector2(x_length,y_length)
	chunk_split = -floor(num_of_chunks/2)
	$Camera2D.position.x = chunk_size.x * num_of_chunks.x/2 + chunk_size.x/2
	$Camera2D.position.y = chunk_size.y * num_of_chunks.y/2 + chunk_size.y/2
	initialize_upgrade_data()
	initialize_store_data()
	update_points()
	update_lives(0)
	#$CanvasLayer/normal_rez/Button.text = '+1 Score Multiplier $' + str(cost_of_mult)
	#$CanvasLayer/normal_rez/Button2.text = '+1 Drone $' + str(cost_of_drone)
	place_chunk_loc()
	place_tile_loc()

#############################################################################	
#############################################################################	
#############################################################################

func _process(_delta: float) -> void:
	
	if moveable and mouse_in:
		
		
		var difference = local_mous_pos - get_global_mouse_position()
		
		
		###NEEDS ADJSUTING
		if $Camera2D.zoom == Vector2(1,1):
			if difference.x > 0:
				if $Camera2D.position.x + difference.x < initial_chunk_pos.x + chunk_size.x * num_of_chunks.x + 64:
					$Camera2D.position.x += difference.x/$Camera2D.zoom.x
			elif difference.x < 0:
				if $Camera2D.position.x + difference.x > initial_chunk_pos.x + chunk_size.x - 64:
					$Camera2D.position.x += difference.x/$Camera2D.zoom.x
			if difference.y > 0:
				if $Camera2D.position.y + difference.y < initial_chunk_pos.y + chunk_size.y * num_of_chunks.y + 64:
					$Camera2D.position.y += difference.y/$Camera2D.zoom.y	
			elif difference.y < 0:
				if $Camera2D.position.y + difference.y > initial_chunk_pos.y + chunk_size.y - 64:
					$Camera2D.position.y += difference.y/$Camera2D.zoom.y

	var nearest_chunk_pos = Vector2()
	var chunk_follow_pos = $Camera2D.position
	
	nearest_chunk_pos.x = floor(chunk_follow_pos.x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
	nearest_chunk_pos.y = floor(chunk_follow_pos.y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y

	if nearest_chunk_pos != current_chunk:
		current_chunk = nearest_chunk_pos
		draw_chunk(current_chunk)

############################################################################	
#############################################################################	
#############################################################################
	
func _unhandled_input(_event: InputEvent) -> void:
	
	var mouse_pos = get_global_mouse_position()
	var nearest_tile_pos = get_nearest(mouse_pos, 'tile')
	var nearest_chunk_pos = get_nearest(nearest_tile_pos,'chunk')
	
	if Input.is_action_just_pressed("left_click"):
		#if upgrade_in_hand == false:
		#if upgrade_in_hand == false:
			#if in_game_menu == false:
				#$CanvasLayer/normal_rez/game_menu.visible = false
				
		stored_pos = nearest_tile_pos
		#$CanvasLayer/sprite_holder/bomb.visible = false
		#$CanvasLayer/sprite_holder/normal.visible = false
		#$CanvasLayer/sprite_holder/clicked.visible = true
		
		if upgrade_in_hand == true:
			if tile_dict[nearest_tile_pos][3] == true:
				upgrade.place(nearest_tile_pos)
				upgrade_in_hand = false
				upgrade = 'NONE'
		
	if Input.is_action_just_released("left_click"):
		
		if upgrade_in_hand == false:
			if nearest_tile_pos == stored_pos:
				if tile_dict.has(nearest_tile_pos):
					if gamestart == false:
						current_chunk = get_nearest(nearest_tile_pos,'chunk')
						start_game(nearest_tile_pos)
					else:
						clicked(nearest_tile_pos)
		
			#else:
				#$CanvasLayer/sprite_holder/bomb.visible = false
				#$CanvasLayer/sprite_holder/normal.visible = true
				#$CanvasLayer/sprite_holder/clicked.visible = false
			
		
	if Input.is_action_just_pressed("right_click"):
		
		mark(nearest_tile_pos, nearest_chunk_pos)
				
	if Input.is_action_just_pressed("ui_up"):
		get_tree().reload_current_scene()
	

	if Input.is_action_pressed("restart"):
		
		if moveable == false:
			local_mous_pos = get_global_mouse_position()
			
		moveable = true
		
	if Input.is_action_just_released("restart"):
		moveable = false
	
	if Input.is_action_just_pressed("add"):
		update_lives(1)
	if Input.is_action_just_pressed("subtract"):
		update_lives(-1)


	#if Input.is_action_just_pressed("zoom_in"):
	if _event is InputEventMouseButton:
		if _event.button_index == MOUSE_BUTTON_WHEEL_UP and _event.pressed:
			if $Camera2D.zoom.x < 2.0 and $Camera2D.zoom.y < 2.0:
				$Camera2D.zoom *= 2
		
	if _event is InputEventMouseButton:
		if _event.button_index == MOUSE_BUTTON_WHEEL_DOWN and _event.pressed:
			if $Camera2D.zoom.x > .5 and $Camera2D.zoom.y > .5:
				$Camera2D.zoom /= 2
		
					
#############################################################################
#█ █▄░█ █ ▀█▀ █ ▄▀█ ▀█▀ █ █▄░█ █▀▀   █▀▀ █▀█ █ █▀▄
#█ █░▀█ █ ░█░ █ █▀█ ░█░ █ █░▀█ █▄█   █▄█ █▀▄ █ █▄▀
#############################################################################	

func place_chunk_loc():
	
	
	var start_pos = Vector2()
	var chunk_position = Vector2()
	
	$Camera2D.limit_left = start_pos.x
	$Camera2D.limit_right = num_of_chunks.x * chunk_size.x
	$Camera2D.limit_top = start_pos.y
	$Camera2D.limit_bottom = num_of_chunks.y * chunk_size.y
	
	for x in num_of_chunks.x:
		for y in num_of_chunks.y:
			chunk_position = start_pos + Vector2(x,y)*chunk_size
			chunk_dict[chunk_position] = ['not_named',false,false]
	
#############################################################################	
#############################################################################	
#############################################################################
	
func place_tile_loc():
	
	var start_pos = Vector2()  
	var x_tiles = chosen_grid_size[0] * num_of_chunks.x
	var y_tiles = chosen_grid_size[1] * num_of_chunks.y
	var tile_pos = Vector2()

	for x in x_tiles:
		for y in y_tiles:
			tile_pos = start_pos + Vector2(x_length,y_length) * Vector2(x,y)
			#tile_pos = Vector2(start_pos.x + x_length * x, start_pos.y + y_length * y )
			if tile_dict.has(tile_pos) == false:
				tile_dict[tile_pos] = ['none', 'unknown', 0, false,false,'NONE']
					
	draw_chunk(initial_chunk_pos)

#############################################################################	
#############################################################################	
#############################################################################

func randomize_mine_placement(pos):

	var unused_tile_grid = get_chunk_grid()
	var unused_tile_pos = convert_grid_to_pos(unused_tile_grid,pos)

	for i in safe_tiles:
		unused_tile_pos.erase(i)
	if chunk_dict[pos][2] == false:
		for mine in number_of_mines_per_chunk:
			
			var rand_tile_pos = Vector2()
			
			rand_tile_pos = unused_tile_pos[randi_range(0, len(unused_tile_pos)-1)]					
			unused_tile_pos.erase(rand_tile_pos)		
			tile_dict[rand_tile_pos][1] = 'mine'
			
			var neighbors = create_neighbors(rand_tile_pos,x_length,y_length, 'ALL')
			
			for i in neighbors:
				if tile_dict[i][1] != 'mine':
					tile_dict[i][1] = 'warning'
					tile_dict[i][2] += 1
						
		chunk_dict[pos][2] = true
						
#############################################################################	
#█▀▀ █░█ █░█ █▄░█ █▄▀ █ █▄░█ █▀▀
#█▄▄ █▀█ █▄█ █░▀█ █░█ █ █░▀█ █▄█	
#############################################################################

func draw_chunk(pos):
	
	
	var to_draw = []
	tiles_in_current_chunk = []
	
	current_neighbors = create_neighbors(pos,chunk_size.x,chunk_size.y, 'ALL')
	current_neighbors.append(pos)
	#send_dicts()
	delete_chunk(current_neighbors)
	for i in current_neighbors:
		if chunk_dict.has(i):
			if chunk_dict[i][1] == false:
				to_draw.append(i)
	
	for i in to_draw:
		
		var chunk = chunk_load.instantiate()

		$chunks.add_child(chunk)
		chunk_dict[i][0] = chunk.name
		chunk_dict[i][1] = true
		chunk.position = i
		
		if chunk_dict[i][2] == false and gamestart == true:
			safe_tiles = []
			check_chunk_boundary(i)
			randomize_mine_placement(i)	
		for x in chosen_grid_size[0]:
			for y in chosen_grid_size[1]:
				
				var tile = tile_load.instantiate()
				var path_2_node = 'chunks/' + chunk_dict[i][0]
				var tile_type
				var global_pos = Vector2(x,y) * Vector2(x_length, y_length) + initial_pos + i
				
				get_node(path_2_node).add_child(tile)
				tile.global_position = global_pos
				tile_dict[global_pos][0] = tile.name

				if tile_dict[global_pos][3] == true:	
					if tile_dict[global_pos][1] == 'warning':
						tile_type = str(tile_dict[global_pos][2])
					else:
						tile_type = tile_dict[global_pos][1]	
				else:
					if tile_dict[global_pos][4] == true:
						tile_type = 'mark'
					elif tile_dict[global_pos][5] != 'NONE':
						if tile_dict[global_pos][5] == 'MINE_SCAN':
							tile_type = 'mine_scan'
						else:
							tile_type = 'not_mine_scan'
					else:
						tile_type = 'hidden'
						
				var sprite_path = 'sprites/' + tile_type
				var new_texture = get_node(sprite_path).texture		
				
				tile.texture = new_texture
					
#############################################################################	
#############################################################################	
#############################################################################

func check_chunk_boundary(pos):
	
	var x_bounds = [0,chosen_grid_size[0] - 1] 
	
	var y_bounds = [0,chosen_grid_size[1] -1]
	var global_bounds = [Vector2(x_bounds[0],y_bounds[0]) * Vector2(x_length, y_length) + initial_pos + pos - Vector2(x_length, y_length),
						 Vector2(x_bounds[1],y_bounds[1]) * Vector2(x_length, y_length) + initial_pos + pos + Vector2(x_length, y_length)]
	var jump = 3
	var sim_size = Vector2()
	var border = []
	
	if x_bounds[1] % 3 == 0 or x_bounds[1] % 3 == 1:
		sim_size.x = x_bounds[1]
	else:
		sim_size.x = x_bounds + 1
		
	if y_bounds[1] % 3 == 0 or y_bounds[1] % 3 == 1:
		sim_size.y = y_bounds[1]
	else:
		sim_size.y = y_bounds + 1
		
	for x in int(sim_size.x):
		
		if x % jump == 0:
		
			var top_row_pos = Vector2(x,y_bounds[0])
			var top_row_pos_global = (top_row_pos * Vector2(x_length, y_length)) + initial_pos + pos
			var tiles_above_pos = create_neighbors(top_row_pos_global,x_length,y_length,'TOP')
			
			for i in tiles_above_pos:
				if i.x >= global_bounds[0].x and i.x <= global_bounds[1].x:
					border.append(i)
			
			var bottom_row_pos = Vector2(x,y_bounds[1])
			var bottom_row_pos_global = (bottom_row_pos * Vector2(x_length, y_length)) + initial_pos + pos
			var tiles_below_pos = create_neighbors(bottom_row_pos_global,x_length,y_length,'BOTTOM')
			
			for i in tiles_below_pos:
				if i.x >= global_bounds[0].x and i.x <= global_bounds[1].x:
					border.append(i)
		
	for y in int(sim_size.y):
		
		if y % jump == 0:
			
			var left_col_pos = Vector2(x_bounds[0],y)
			var left_col_pos_global = (left_col_pos * Vector2(x_length, y_length)) + initial_pos + pos
			var tiles_left_of_pos = create_neighbors(left_col_pos_global,x_length,y_length,'LEFT')
			
			for i in tiles_left_of_pos:
				if i.y >= global_bounds[0].y and i.y <= global_bounds[1].y:
					border.append(i)
			
			var right_row_pos = Vector2(x_bounds[1],y)
			var right_row_pos_global = (right_row_pos * Vector2(x_length, y_length)) + initial_pos + pos
			var tiles_right_of_pos = create_neighbors(right_row_pos_global,x_length,y_length,'RIGHT')
			
			for i in tiles_right_of_pos:
				if i.y >= global_bounds[0].y and i.y <= global_bounds[1].y:
					border.append(i)

	
#############################################################################	
#############################################################################	
#############################################################################

func start_game(click_pos):
	
	gamestart = true
	
	var safe_neighbors = create_neighbors(click_pos,x_length,y_length, 'ALL')
	
	safe_neighbors.append(click_pos)
	
	for i in safe_neighbors:
		tile_dict[i][1] = 'safe'
		safe_tiles.append(i)
	 
	var chunk_pos = get_nearest(click_pos,'chunk')
	var chunk_neighbors = create_neighbors(chunk_pos,chunk_size.x,chunk_size.y, 'ALL')
	
	chunk_neighbors.append(chunk_pos)
	
	for i in chunk_neighbors:
		randomize_mine_placement(i)	
	
	clicked(click_pos)
			
#############################################################################	
#############################################################################	
#############################################################################						
					
func clicked(pos):
		
	var nearest_chunk_pos = get_nearest(pos, 'chunk')
	var node_path = 'chunks/' +  chunk_dict[nearest_chunk_pos][0] + '/' + tile_dict[pos][0]
	if chunk_dict[nearest_chunk_pos][1] == true:
		if tile_dict[pos][3] == false:
			tile_dict[pos][3] = true
			if tile_dict[pos][1] == 'unknown':
				tile_dict[pos][1] = 'safe'
			#if tile_dict[pos][1] == 'safe':
				#update_safe_neighbors(pos,'safe')
			var tile_type = tile_dict[pos][1]
			
			if tile_dict[pos][1] == 'warning':
				tile_type = str(tile_dict[pos][2])
				
			var sprite_path = 'sprites/' + tile_type
			var new_texture = get_node(sprite_path).texture
			
			get_node(node_path).texture = new_texture
			
			if tile_dict[pos][1] != 'mine':
				var score_mulitplier = all_upgrade_data['click_multi']['current'] + 1
				round_points += 1 * score_mulitplier
				update_points()
			#if tile_type == 'mine':
				#if mine_radius > 0:
					#update_safe_neighbors(pos,'mine')
				#$CanvasLayer/sprite_holder/bomb.visible = true
				#$CanvasLayer/sprite_holder/normal.visible = false
				#$CanvasLayer/sprite_holder/clicked.visible = false
			#else:
				#$CanvasLayer/sprite_holder/bomb.visible = false
				#$CanvasLayer/sprite_holder/normal.visible = true
				#$CanvasLayer/sprite_holder/clicked.visible = false
				#round_points += 1 * score_multilier
				#update_points()
		#else:
			#$CanvasLayer/sprite_holder/bomb.visible = false
			#$CanvasLayer/sprite_holder/normal.visible = true
			#$CanvasLayer/sprite_holder/clicked.visible = false
			
	elif chunk_dict[nearest_chunk_pos][1] == false:
		tile_dict[pos][3] = true

		if chunk_dict[nearest_chunk_pos][2] == false:
			safe_tiles = []
			safe_tiles.append(pos)
			check_chunk_boundary(nearest_chunk_pos)
			randomize_mine_placement(nearest_chunk_pos)
		if tile_dict[pos][1] == 'unknown':
				tile_dict[pos][1] = 'safe'
		#if tile_dict[pos][1] == 'safe':
			#update_safe_neighbors(pos,'safe')
			#
		#if tile_dict[pos][1] != 'mine':
			#round_points += 1 * score_multilier
			#update_points()
		if tile_dict[pos][1] != 'mine':
			var score_multiplier = all_upgrade_data['click_multi']['current'] + 1
			round_points += 1 * score_multiplier
			update_points()
	if tile_dict[pos][1] == 'safe':
		update_safe_neighbors(pos,'safe')
		
	if tile_dict[pos][1] == 'mine':
		var mine_radius = all_upgrade_data['mine_radius']['current']
		if mine_radius > 0:
			update_safe_neighbors(pos,'mine')
			
#############################################################################	
#############################################################################	
#############################################################################

func update_safe_neighbors(pos,type):	
	var nearest_chunk_pos = get_nearest(pos, 'chunk')
	
	if chunk_dict[nearest_chunk_pos][2] == false:
		await randomize_mine_placement(nearest_chunk_pos)
	
	var neighbors
	var mine_neighbors
	
	
	
	if type == 'safe':
		neighbors = create_neighbors(pos, x_length, y_length, 'ALL')
		for i in neighbors:
			if tile_dict[i][3] == false:
				if tile_dict[i][1] != 'mine':
					clicked(i) 
	elif type == 'mine':
		mine_neighbors = create_explosion(pos)
		await get_tree().create_timer(.1).timeout
		for i in mine_neighbors:
			if tile_dict[i][3] == false:
				clicked(i)
	
	
#############################################################################	
#############################################################################	
#############################################################################
			
func delete_chunk(dont_erase):
	
	var delete = true
	
	for chunk in $chunks.get_children():		
		for pos in dont_erase:
			if chunk.position == pos:
				delete = false
		if delete == true:
			chunk_dict[chunk.position][1] = false
			chunk.queue_free()
		delete = true

#############################################################################	
#█▀▄▀█ █ █▀ █▀▀
#█░▀░█ █ ▄█ █▄▄	
#############################################################################

func create_neighbors(pos,x,y,dir):
	
	var pre_neighbors
	var n = pos + Vector2(0,-1) * Vector2(x,y)
	var ne = pos + Vector2(1,-1) * Vector2(x,y)
	var nw = pos + Vector2(-1,-1) * Vector2(x,y)
	var s = pos + Vector2(0,1) * Vector2(x,y)
	var se = pos + Vector2(1,1) * Vector2(x,y)
	var sw = pos + Vector2(-1,1) * Vector2(x,y)
	var w = pos + Vector2(-1,0) * Vector2(x,y)
	var e = pos + Vector2(1,0) * Vector2(x,y)
	
	match dir:
	
		'TOP':
			pre_neighbors = [n,ne,nw]
		'BOTTOM':
			pre_neighbors = [sw,s,se]
		'RIGHT':
			pre_neighbors = [ne,e,se]
		'LEFT':
			pre_neighbors = [nw,w,sw]
		'ALL':
			pre_neighbors = [n,ne,e,se,s,sw,w,nw]
			
	var neighbors = []

	for i in pre_neighbors:
		var nearest_chunk_pos = get_nearest(i,'chunk')
		
		if chunk_dict.has(nearest_chunk_pos):
			neighbors.append(i)
				
	return neighbors

#############################################################################	
#############################################################################	
#############################################################################

func get_chunk_grid():
	
	var chunk_grid = []
	
	for x in chosen_grid_size[0]:
		for y in chosen_grid_size[1]:
			chunk_grid.append(Vector2(x,y))
	
	return chunk_grid
	
#############################################################################	
#############################################################################	
#############################################################################
			
func mark(pos,chunk_pos):	
	
	if tile_dict[pos][3] == false:
		
		var node_path = 'chunks/' +  chunk_dict[chunk_pos][0] + '/' + tile_dict[pos][0]
		var sprite_path = 'sprites/'

		if tile_dict[pos][4] == false:
			sprite_path += 'mark'
			tile_dict[pos][4] = true
		elif tile_dict[pos][4] == true:
			sprite_path += 'hidden'
			tile_dict[pos][4] = false
			
		var new_texture = get_node(sprite_path).texture		
		get_node(node_path).texture = new_texture
	
	if tile_dict[pos][1] != 'mine':
		flag_correct = false
		
		
#############################################################################	
#############################################################################	
#############################################################################
	
func get_nearest(pos, val):
	
	var nearest = Vector2()
	
	match val:
		'chunk':
			nearest = floor(pos / chunk_size) * chunk_size + initial_pos
		'tile':
			nearest = floor(pos / Vector2(x_length,y_length)) * Vector2(x_length,y_length) + initial_pos
	return nearest
	
#############################################################################	
#############################################################################	
#############################################################################

func convert_grid_to_pos(grid,pos):
	
	var new_grid = []
	for i in grid:
		var new_pos = (i * Vector2(x_length, y_length)) + initial_pos + pos
		new_grid.append(new_pos)
	return new_grid
	
#############################################################################	
#############################################################################	
#############################################################################

func update_points():
	
	$CanvasLayer/Label.text = str(round_points)

func _on_upgrade_button_pressed() -> void:
	
	var upgrade_menu = upgrade_load.instantiate()
	$CanvasLayer/normal_rez.add_child(upgrade_menu)
	upgrade_menu.get_upgrade_list(all_upgrade_data)
	upgrade_menu.update_upgrades.connect(handle_upgrades)

func send_dicts():
	
	var grid = get_chunk_grid()
	var positions = convert_grid_to_pos(grid,current_chunk)
	#var node_path = 'chunks/' +  chunk_dict[current_chunk][0]
	return positions


	
func check_clicked(pos,val):
	
	if val == 'CLICKED':
		if tile_dict[pos][3] == true or tile_dict[pos][4] == true or tile_dict[pos][5] != 'NONE':
			return true
		else: 
			return false
	
	elif val == 'DRILL':
		var new_pos = pos - Vector2(8,8)
		if tile_dict.has(new_pos):
			return tile_dict[new_pos][3]
	
	elif val == 'WHAT':
		var new_pos = pos - Vector2(8,8)
		return tile_dict[new_pos][1]

	else:
		var nearest_chunk_pos = get_nearest(pos, 'chunk')
		var node_path = 'chunks/' +  chunk_dict[nearest_chunk_pos][0] + '/' + tile_dict[pos][0]
		if nearest_chunk_pos in current_neighbors:
			if tile_dict[pos][1] == 'mine':
				var sprite_path = $sprites/mine_scan.texture
				tile_dict[pos][5] = 'MINE_SCAN'
				get_node(node_path).texture = sprite_path
			else:
				var sprite_path = $sprites/not_mine_scan.texture
				tile_dict[pos][5] = "SAFE_SCAN"
				get_node(node_path).texture = sprite_path
		else:
			if tile_dict[pos][1] == 'mine':
				tile_dict[pos][5] = 'MINE_SCAN'
			else:
				tile_dict[pos][5] = "SAFE_SCAN"


func create_explosion(pos):
	
	var n = pos + Vector2(0,-1) * Vector2(x_length,y_length)
	#var ne = pos + Vector2(1,-1) * Vector2(x_length,y_length)
	#var nw = pos + Vector2(-1,-1) * Vector2(x_length,y_length)
	var s = pos + Vector2(0,1) * Vector2(x_length,y_length)
	#var se = pos + Vector2(1,1) * Vector2(x_length,y_length)
	#var sw = pos + Vector2(-1,1) * Vector2(x_length,y_length)
	var w = pos + Vector2(-1,0) * Vector2(x_length,y_length)
	var e = pos + Vector2(1,0) * Vector2(x_length,y_length)
	
	var pre_neighbors = [n,e,s,w]#,ne,nw,se,sw]
	
	var mine_radius = all_upgrade_data['mine_radius']['current']
	for i in range(mine_radius + 1):
		
		n = [pos + Vector2(0,-i) * Vector2(x_length,y_length)]
		pre_neighbors += n
		s = [pos + Vector2(0,i) * Vector2(x_length,y_length)]
		pre_neighbors += s
		w = [pos + Vector2(-i,0) * Vector2(x_length,y_length)]
		pre_neighbors += w
		e = [pos + Vector2(i,0) * Vector2(x_length,y_length)]
		pre_neighbors += e
	
	var neighbors = []

	for i in pre_neighbors:
		var nearest_chunk_pos = get_nearest(i,'chunk')
		
		if chunk_dict.has(nearest_chunk_pos):
			neighbors.append(i)
				
	return neighbors

func update_lives(change):
	
	var heart_holder = $CanvasLayer/normal_rez/heart_container
	
	if change == 1 or change == 0:
		
		var heart_load = preload("res://heart.tscn")
		var heart = heart_load.instantiate()
		heart_holder.add_child(heart)
		heart.position.x = (heart_holder.get_child_count()-1) * 20
		
	if change == -1:
		
		if heart_holder.get_child_count() > 0:
			heart_holder.get_child(heart_holder.get_child_count()-1).queue_free()
	
	lives += change
	
func _on_texture_button_pressed() -> void:
	pass

func initialize_upgrade_data():
	
	#MINE_DATA
	all_upgrade_data = {
		'mine_radius': {
			'name': 'Mine Radius',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'mine'
		},
	
	#DRONE_DATA
		'drone_speed': {
			'name': 'Drone Speed',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drone'
		},
		'scan_size': {
			'name': 'Scanner Size',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drone'
		},
		'drone_add': {
			'name': 'Add Drone',
			'description': '',
			'current': 0,
			'max': 1,
			'cost': 10,
			'owner': 'none'
		},
		'battery_speed': {
			'name': 'Battery Recharge Speed',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drone'
		},
		'battery_plus': {
			'name': 'Battery Size',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drone'
		},
	
	#DRILL_DATA
		'drill_size': {
			'name': 'Drill Size',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drill'
		},
		'drill_speed': {
			'name': 'Drill Speed',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drill'
		},
		'drill_dur': {
			'name': 'Drill Durability',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drill'
		},
		'drill_add': {
			'name': 'Add Drill',
			'description': '',
			'current': 0,
			'max': 1,
			'cost': 10,
			'owner': 'none'
		},
	
	#CLICK_DATA

		'click_multi': {
			'name': 'Click Multiplier',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'none'
		},
		
	# MARK DATA
		'mark': {
			'name': 'Mark',
			'description': '',
			'current': 0,
			'max': 1,
			'cost': 10,
			'owner': 'none'
		},
		'call_it_in': {
			'name': 'Call It In',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'none'
			
		},
	#HEART DATA
		'steel_heart': {
			'name': 'Steel Heart',
			'description': '',
			'current': 0,
			'max': 1,
			'cost': 10,
			'owner': 'none'
		}
	} 

func initialize_store_data():
	
	all_store_data = {
		'drone': {
			'inventory': -1,
			'cost': 10
		},
		'drill': {
			'inventory': -1,
			'cost': 10
		}
	} 
	
func handle_upgrades(upgrade_data):
	
	all_upgrade_data[upgrade_data]['current'] += 1
	
	if upgrade_data == 'drone_add':
		update_inventory('drone','add')
	
	if upgrade_data == 'drill_add':
		update_inventory('drill','add')
	
	if all_upgrade_data[upgrade_data]['owner'] == 'drone':
		for drone_base in $drones.get_children():
			drone_base.update_upgrade(upgrade_data, all_upgrade_data[upgrade_data]['current'])
		
		

func _on_drone_button_pressed() -> void:
	if all_store_data['drone']['inventory'] > 0:
		update_inventory('drone','remove')
		var drone_base_load = preload("res://drone_base.tscn")
		var drone_base = drone_base_load.instantiate()
		$drones.add_child(drone_base)
		drone_base.get_initial_upgrades(all_upgrade_data)
		upgrade_in_hand = true
		upgrade = drone_base
		drone_base.clicked()


func _on_drill_button_pressed() -> void:
	
	if all_store_data['drill']['inventory'] > 0:
		update_inventory('drill','remove')
		#round_points -= cost_of_drill
		#cost_of_drill += 10
		#$CanvasLayer/normal_rez/Button3.text = '+1 Drill' + str(cost_of_drill)
		#update_points()
		var driller_load = preload("res://driller.tscn")
		var driller = driller_load.instantiate()
		add_child(driller)
		upgrade_in_hand = true
		upgrade = driller
		driller.clicked()

func update_inventory(item,action):
	
	var node_path = 'CanvasLayer/normal_rez/game/' + item + '_buttons'
	if all_store_data[item]['inventory'] == -1:
		get_node(node_path).visible = true
	
	if action == 'add':
		all_store_data[item]['inventory'] += 1
	if action == 'remove':
		all_store_data[item]['inventory'] -= 1
	
	get_node(node_path + '/' + item + '_button/Label').text = str(all_store_data[item]['inventory'])


			


func _on_buy_drill_pressed() -> void:
	if all_upgrade_data['drill_add']['cost'] < round_points:
		round_points -= all_upgrade_data['drill_add']['cost']
		update_points()
		update_inventory('drill','add')


func _on_buy_drone_pressed() -> void:
	if all_upgrade_data['drone_add']['cost'] < round_points:
		round_points -= all_upgrade_data['drone_add']['cost']
		update_points()
		update_inventory('drone','add')
