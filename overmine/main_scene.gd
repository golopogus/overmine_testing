extends Node2D

const grid_size_options = [[8,8],[50,50],[4,4]]
var chosen_grid_size = grid_size_options[0]
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
var number_of_mines_per_chunk = 10
var moveable = false
var local_mous_pos
var current_neighbors = []
var current_chunk
var safe_tiles = []
var tile_dict = {} # pos = [tile.name, 'unknown' (type), value, true (hidden),marked]
var tile_load = preload("res://tile.tscn")
var test_load = preload("res://test.tscn")
var chunk_load = preload("res://chunk_loc.tscn")
var tile_holder_load = preload("res://tile_holder.tscn")

#############################################################################	
#############################################################################	
#############################################################################

func _ready() -> void:
	
	chunk_size.x= chosen_grid_size[0] * 16
	chunk_size.y= chosen_grid_size[1] * 16
	chunk_split = -floor(num_of_chunks/2)
	$Camera2D.position.x = chunk_size.x * num_of_chunks.x/2 + chunk_size.x/2
	$Camera2D.position.y = chunk_size.y * num_of_chunks.y/2 + chunk_size.y/2
	place_chunk_loc()
	place_tile_loc()

#############################################################################	
#############################################################################	
#############################################################################

func _process(_delta: float) -> void:
	
	if moveable == true:
		
		var difference = local_mous_pos - get_global_mouse_position()
		
		$Camera2D.position += difference

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
		print(nearest_tile_pos)
		if tile_dict.has(nearest_tile_pos):
			if gamestart == false:
				current_chunk = get_nearest(nearest_tile_pos,'chunk')
				start_game(nearest_tile_pos)
			else:
				clicked(nearest_tile_pos)
	
	if Input.is_action_just_pressed("right_click"):
		
		mark(nearest_tile_pos, nearest_chunk_pos)
				
	if Input.is_action_just_pressed("ui_up"):
		get_tree().reload_current_scene()
	#
	if Input.is_action_pressed("restart"):
		if moveable == false:
			local_mous_pos = get_global_mouse_position()
		moveable = true
		
	if Input.is_action_just_released("restart"):
		moveable = false

					
#############################################################################
#█ █▄░█ █ ▀█▀ █ ▄▀█ ▀█▀ █ █▄░█ █▀▀   █▀▀ █▀█ █ █▀▄
#█ █░▀█ █ ░█░ █ █▀█ ░█░ █ █░▀█ █▄█   █▄█ █▀▄ █ █▄▀
#############################################################################	

func place_chunk_loc():
	
	var start_pos = Vector2()
	var chunk_position = Vector2()
	
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

	x_length = $sprites/hidden.texture.get_width()
	y_length = $sprites/hidden.texture.get_height()

	var tile_pos = Vector2()

	for x in x_tiles:
		for y in y_tiles:
			tile_pos = Vector2(start_pos.x + x_length * x, start_pos.y + y_length * y )
			if tile_dict.has(tile_pos) == false:
				tile_dict[tile_pos] = ['none', 'unknown', 0, false,false]
					
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
			
			#var global_mine_pos = (rand_tile_pos * 16) + initial_pos + pos				

			tile_dict[rand_tile_pos][1] = 'mine'
			var neighbors = create_neighbors(rand_tile_pos,x_length,y_length, 'ALL')
			for i in neighbors:
				if tile_dict[i][1] != 'mine':
					tile_dict[i][1] = 'warning'
					tile_dict[i][2] += 1
						
		chunk_dict[pos][2] = true
	print("Mines placed for chunk:", pos)
	
	

func convert_grid_to_pos(grid,pos):
	var new_grid = []
	for i in grid:
		var new_pos = (i * 16) + initial_pos + pos
		new_grid.append(new_pos)
	return new_grid
		
		
		
						
#############################################################################	
#█▀▀ █░█ █░█ █▄░█ █▄▀ █ █▄░█ █▀▀
#█▄▄ █▀█ █▄█ █░▀█ █░█ █ █░▀█ █▄█	
#############################################################################

func draw_chunk(pos):

	current_neighbors = create_neighbors(pos,chunk_size.x,chunk_size.y, 'ALL')
	
	var dont_erase = current_neighbors
	var to_draw = []
	
	dont_erase.append(pos)
	delete_chunk(dont_erase)
	
	for i in dont_erase:
		if chunk_dict.has(i):
			if chunk_dict[i][1] == false:
				to_draw.append(i)
	
	for i in to_draw:
		
		var chunk = chunk_load.instantiate()
		#var r = randf_range(.5,1)
		$chunks.add_child(chunk)
		chunk_dict[i][0] = chunk.name
		chunk_dict[i][1] = true
		chunk.position = i
		
		if chunk_dict[i][2] == false and gamestart == true:
			safe_tiles = []
			check_chunk_boundary(i)
			randomize_mine_placement(i)	
	#	chunk.modulate = Color(r,r,r)
		for x in chosen_grid_size[0]:
			for y in chosen_grid_size[1]:
				
				var tile = tile_load.instantiate()
				var path_2_node = 'chunks/' + chunk_dict[i][0]
				var tile_type
				var global_pos = Vector2(x,y) * 16 + initial_pos + i
				
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
	var global_bounds = [Vector2(x_bounds[0],y_bounds[0]) * 16 + initial_pos + pos + Vector2(-16,-16), Vector2(x_bounds[1],y_bounds[1]) * 16 + initial_pos + pos + Vector2(16,16)]
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
			var top_row_pos_global = (top_row_pos * 16) + initial_pos + pos
			var tiles_above_pos = create_neighbors(top_row_pos_global,x_length,y_length,'TOP')
			for i in tiles_above_pos:
				if i.x >= global_bounds[0].x and i.x <= global_bounds[1].x:
					border.append(i)
			#check_if_safe_neighbor(tile_above_pos)
			
			var bottom_row_pos = Vector2(x,y_bounds[1])
			var bottom_row_pos_global = (bottom_row_pos * 16) + initial_pos + pos
			var tiles_below_pos = create_neighbors(bottom_row_pos_global,x_length,y_length,'BOTTOM')
			for i in tiles_below_pos:
				if i.x >= global_bounds[0].x and i.x <= global_bounds[1].x:
					border.append(i)
			
			#check_if_safe_neighbor(tile_below_pos)
		
	for y in int(sim_size.y):
		
		if y % jump == 0:
			
			var left_col_pos = Vector2(x_bounds[0],y)
			var left_col_pos_global = (left_col_pos * 16) + initial_pos + pos
			var tiles_left_of_pos = create_neighbors(left_col_pos_global,x_length,y_length,'LEFT')
			for i in tiles_left_of_pos:
				if i.y >= global_bounds[0].y and i.y <= global_bounds[1].y:
					border.append(i)
			
			var right_row_pos = Vector2(x_bounds[1],y)
			var right_row_pos_global = (right_row_pos * 16) + initial_pos + pos
			var tiles_right_of_pos = create_neighbors(right_row_pos_global,x_length,y_length,'RIGHT')
			for i in tiles_right_of_pos:
				if i.y >= global_bounds[0].y and i.y <= global_bounds[1].y:
					border.append(i)

	convert_to_safe_tile(border)
	
#############################################################################	
#############################################################################	
#############################################################################

func start_game(click_pos):
	
	gamestart = true
	
	var safe_neighbors = create_neighbors(click_pos,x_length,y_length, 'ALL')
	safe_neighbors.append(click_pos)
	
	for i in safe_neighbors:
		tile_dict[i][1] = 'safe'
		
	convert_to_safe_tile(safe_neighbors)
	 
	var chunk_pos = get_nearest(click_pos,'chunk')
	var chunk_neighbors = create_neighbors(chunk_pos,chunk_size.x,chunk_size.y, 'ALL')
	
	chunk_neighbors.append(chunk_pos)
	
	
	for i in chunk_neighbors:
		randomize_mine_placement(i)	
	
	await get_tree().process_frame
	clicked(click_pos)


	
func convert_to_safe_tile(array):
	
	for pos in array:
		
		if tile_dict[pos][1] == 'safe':
			safe_tiles.append(pos)
#############################################################################	
#############################################################################	
#############################################################################						
					
func clicked(pos):
	
	
	var nearest_chunk_pos = get_nearest(pos, 'chunk')
	#await randomize_mine_placement(nearest_chunk_pos)
	var node_path = 'chunks/' +  chunk_dict[nearest_chunk_pos][0] + '/' + tile_dict[pos][0]
	print("Click processing started")
	if chunk_dict[nearest_chunk_pos][1] == true:
		if tile_dict[pos][3] == false:
			tile_dict[pos][3] = true
			if tile_dict[pos][1] == 'unknown':
				tile_dict[pos][1] = 'safe'
			if tile_dict[pos][1] == 'safe':
				update_safe_neighbors(pos)
				
			var tile_type = tile_dict[pos][1]
			
			if tile_dict[pos][1] == 'warning':
				tile_type = str(tile_dict[pos][2])
				
			var sprite_path = 'sprites/' + tile_type
			var new_texture = get_node(sprite_path).texture
			
			get_node(node_path).texture = new_texture
			
	elif chunk_dict[nearest_chunk_pos][1] == false:
		
		tile_dict[pos][3] = true
		if chunk_dict[nearest_chunk_pos][2] == false:
			if tile_dict[pos][1] == 'unknown':
				tile_dict[pos][1] = 'safe'
			safe_tiles = []
			check_chunk_boundary(nearest_chunk_pos)
		
			randomize_mine_placement(nearest_chunk_pos)
			await get_tree().process_frame
		if tile_dict[pos][1] == 'unknown':
				tile_dict[pos][1] = 'safe'
		if tile_dict[pos][1] == 'safe':
			update_safe_neighbors(pos)
			
	
		
		
	
		
#############################################################################	
#############################################################################	
#############################################################################

func update_safe_neighbors(pos):	
	var nearest_chunk_pos = get_nearest(pos, 'chunk')
	if chunk_dict[nearest_chunk_pos][2] == false:
		await randomize_mine_placement(nearest_chunk_pos)
	var neighbors
	
	neighbors = create_neighbors(pos, x_length, y_length, 'ALL')

	var safe = true
	
	for i in neighbors:
		if tile_dict[i][1] == 'mine':
			safe = false
			
	if safe == true:
		for i in neighbors:
	
			if tile_dict[i][3] == false:
				if tile_dict[i][1] != 'mine':
					clicked(i)

	#var safe = true
	#
	#for i in neighbors:
		#if tile_dict[i][1] != 'mine':
			#safe = false
			#
	#if safe == true:
		#for i in neighbors:
			#if tile_dict[i][3] == false:
				#if tile_dict[i][1] != 'mine':
					#print(tile_dict[i][1])
					#print(i)
#
					#clicked(i)
	
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
	match dir:
		
		'TOP':
			var n = Vector2(pos.x, pos.y - y)
			var ne = Vector2(pos.x + x, pos.y - y)
			var nw = Vector2(pos.x - x, pos.y - y)
			
			pre_neighbors = [nw,n,ne]
		'BOTTOM':
			var se = Vector2(pos.x + x, pos.y + y)
			var s = Vector2(pos.x, pos.y + y)
			var sw = Vector2(pos.x - x, pos.y + y)
			
			pre_neighbors = [sw,s,se]
		'RIGHT':
			var ne = Vector2(pos.x + x, pos.y - y)
			var e = Vector2(pos.x + x, pos.y)
			var se = Vector2(pos.x + x, pos.y + y)
			
			pre_neighbors = [ne,e,se]
		'LEFT':
			var sw = Vector2(pos.x - x, pos.y + y)
			var w = Vector2(pos.x - x, pos.y)
			var nw = Vector2(pos.x - x, pos.y - y)
			
			pre_neighbors = [nw,w,sw]

		'ALL':
			var n = Vector2(pos.x, pos.y - y)
			var ne = Vector2(pos.x + x, pos.y - y)
			var e = Vector2(pos.x + x, pos.y)
			var se = Vector2(pos.x + x, pos.y + y)
			var s = Vector2(pos.x, pos.y + y)
			var sw = Vector2(pos.x - x, pos.y + y)
			var w = Vector2(pos.x - x, pos.y)
			var nw = Vector2(pos.x - x, pos.y - y)
	
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
		
#############################################################################	
#############################################################################	
#############################################################################
	
func get_nearest(pos, val):
	
	var nearest = Vector2()
	match val:
		'chunk':
			nearest.x = floor(pos.x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
			nearest.y = floor(pos.y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y
		
		'tile':
			nearest.x = floor(pos.x/x_length) * x_length + initial_pos.x
			nearest.y = floor(pos.y/y_length) * y_length + initial_pos.y
	
	return nearest
