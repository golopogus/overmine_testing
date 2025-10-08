extends Node2D

const grid_size_options = [[8,8],[50,50]]
var chosen_grid_size = grid_size_options[0]
var bounds = Vector2()
var num_of_chunks = Vector2(100,100)
var num_of_chunks_start = Vector2(4,4)
var chunk_split
var shitter = Vector2()
var initial_chunk_split
var initial_pos = Vector2()
var chunk_size = Vector2()
var x_length
var y_length
var start = false
var midpoint
var chunk_dict = {}
var gamestart = false
var initial_chunk_pos = Vector2(0,0)
var number_of_mines_per_chunk = 10
var unused_pos = []
var moveable = false
var local_mous_pos
var current_boundary
var tile_name_conv = 0
var chunk_name_conv = 0
var current_neighbors = []
var upper_bounds
var lower_bounds 
var current_chunk
#var thread: Thread

#in form of node name: pos, type etc
# pos = [tile.name, 'unknown' (type), value, true (hidden)]
var tile_dict = {}
#PRELOADS
var tile_load = preload("res://tile.tscn")
var test_load = preload("res://test.tscn")
var chunk_load = preload("res://chunk_loc.tscn")
var tile_holder_load = preload("res://tile_holder.tscn")

#############################################################################	
#############################################################################	
#############################################################################

func _ready() -> void:
	Engine.time_scale = 0.01
	chunk_size.x= chosen_grid_size[0] * 16
	chunk_size.y= chosen_grid_size[1] * 16
	initial_chunk_split = -floor(num_of_chunks_start/2)
	chunk_split = -floor(num_of_chunks/2)
	$Camera2D.position = chunk_size/2 
	#$tester.position = Vector2(-64.0, -64.0)
	place_chunk_loc()
	place_tile_loc(chunk_split, num_of_chunks)
	#place_tile_loc(initial_chunk_split, num_of_chunks_start)

#############################################################################	
#############################################################################	
#############################################################################

func _process(_delta: float) -> void:
	
	if moveable == true:
		var difference = local_mous_pos - get_global_mouse_position()
		$Camera2D.position += difference
	
	#check mouse pos closest to chunk, if drawn ok, if not draw given pos
	
	var nearest_chunk_pos = Vector2()
	
	nearest_chunk_pos.x = floor(get_global_mouse_position().x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
	nearest_chunk_pos.y = floor(get_global_mouse_position().y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y
	#print(get_global_mouse_position())
	
	if start == true:
		if nearest_chunk_pos != current_chunk:
			current_chunk = nearest_chunk_pos
			draw_chunk(current_chunk)
			

#############################################################################
#█ █▄░█ █ ▀█▀ █ ▄▀█ ▀█▀ █ █▄░█ █▀▀   █▀▀ █▀█ █ █▀▄
#█ █░▀█ █ ░█░ █ █▀█ ░█░ █ █░▀█ █▄█   █▄█ █▀▄ █ █▄▀
#############################################################################	

func place_chunk_loc():
	
	var start_pos = Vector2()
	start_pos.x = chunk_size.x * chunk_split.x
	start_pos.y = chunk_size.y * chunk_split.y
	#print(start_pos)
	var chunk_position = Vector2()
	
	for x in num_of_chunks.x:
		for y in num_of_chunks.y:
			chunk_position = start_pos + Vector2(x,y)*chunk_size
			
			chunk_dict[chunk_position] = ['not_named',false,false]
	chunk_dict[start_pos][2] = true
	
#############################################################################	
#############################################################################	
#############################################################################
	
func place_tile_loc(split, chunks):
	
	var start_pos = Vector2()  
	start_pos.x = initial_pos.x + chunk_size.x * split.x
	start_pos.y = initial_pos.y + chunk_size.y * split.y
	#print(start_pos)
	lower_bounds = start_pos
	upper_bounds = Vector2(chunk_size.x * chunks.x - 16, chunk_size.y * chunks.y - 16)
	
	
	var x_tiles = chosen_grid_size[0] * chunks.x
	var y_tiles = chosen_grid_size[1] * chunks.y
	#first need to find positions for each tile
	x_length = $sprites/hidden.texture.get_width()
	y_length = $sprites/hidden.texture.get_height()
	midpoint = Vector2(x_length/2,y_length/2)
	#var check = []
	
	var neighbors = []
	var tile_pos = Vector2()
	#var x_count = 0
	#var x_p = []
	#var y_p = []
	for x in x_tiles:
		for y in y_tiles:
			tile_pos = Vector2(start_pos.x + x_length * x, start_pos.y + y_length * y )
			if tile_dict.has(tile_pos) == false:
				unused_pos.append(tile_pos)
				neighbors = create_neighbors(tile_pos,x_length,y_length)
				tile_dict[tile_pos] = ['none', 'unknown', 0, false, neighbors]
				#check.append(tile_pos)
				#print(int(x) % 64)
				
		
	draw_chunk(initial_chunk_pos)
	
	#for i in check:
		#print(i)
#############################################################################	
#############################################################################	
#############################################################################

func randomize_mine_placement(safe_pos):
	#var total_tiles = x * y
	#var tiles_per_chunk = chosen_grid_size[0] * chosen_grid_size[1]

	for chunk in $chunks.get_children():
		
		var unused_tile_pos = get_chunk_grid()
		
		if chunk_dict[chunk.position][2] == false:
			
			for mine in number_of_mines_per_chunk:
				
				var rand_tile_pos = Vector2()
				
				rand_tile_pos = unused_tile_pos[randi_range(0, len(unused_tile_pos)-1)]
					
				unused_tile_pos.erase(rand_tile_pos)
			
				var global_mine_pos = (rand_tile_pos * 16) + initial_pos + chunk.position
				
				if tile_dict[global_mine_pos][1] != 'safe':
					
					tile_dict[global_mine_pos][1] = 'mine'
					#unused_pos.erase(global_mine_pos)
					#mineu.append(global_mine_pos)
					
				#print(tile_dict[global_mine_pos][0])
					
					for neighbor in tile_dict[global_mine_pos][4]:
						if tile_dict[neighbor][1] != 'mine':
							tile_dict[neighbor][1] = 'warning'
							tile_dict[neighbor][2] += 1
						
#############################################################################	
#█▀▀ █░█ █░█ █▄░█ █▄▀ █ █▄░█ █▀▀
#█▄▄ █▀█ █▄█ █░▀█ █░█ █ █░▀█ █▄█	
#############################################################################

func draw_chunk(pos):
	#check what is drawn
	#current_neighbors = chunk_dict[pos][3]
	current_neighbors = create_neighbors(pos,chunk_size.x,chunk_size.y)
	var dont_erase = current_neighbors
	var to_draw = []
	dont_erase.append(pos)
	delete_chunk(dont_erase)
	var chunk_count = 0
	for i in dont_erase:
		if chunk_dict.has(i):
			if chunk_dict[i][1] == false:
				to_draw.append(i)
	var check = []		
	for i in to_draw:
		var chunk = chunk_load.instantiate()
		#var r = randf()
		$chunks.add_child(chunk)
		chunk_dict[i][0] = chunk.name
		chunk_dict[i][1] = true
		chunk.position = i
		#chunk.modulate = Color(r,r,r)
		
		for x in chosen_grid_size[0]:
			for y in chosen_grid_size[1]:
				var tile = tile_load.instantiate()
				var path_2_node = 'chunks/' + chunk_dict[i][0]
				get_node(path_2_node).add_child(tile)
				var poo = Vector2(x,y) * 16 + initial_pos + i
				tile.global_position = poo
				tile_dict[poo][0] = tile.name
				#print(tile_dict[tile.position][0])
				#if int(tile.position.x) % 64 == 0 and int(tile.position.y) % 64 == 0:
				#check.append(tile.position)
				var tile_type = ''
				if tile_dict[poo][3] == true:
					
					if tile_dict[poo][1] == 'warning':
						tile_type = str(tile_dict[poo][2])
					else:
						tile_type = tile_dict[poo][1]
							
				else:
					tile_type = 'hidden'
				var sprite_path = 'sprites/' + tile_type
				
				var new_texture = get_node(sprite_path).texture		
				#new_texture = $sprites/hidden.texture
				
				tile.texture = new_texture
				tile_name_conv += 1
		chunk_count += 1
	
	
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
		

############################################################################	
#############################################################################	
#############################################################################
	
		
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		if mouse_pos.x >= lower_bounds.x and mouse_pos.x <= upper_bounds.x and mouse_pos.y >= lower_bounds.y and mouse_pos.y <= upper_bounds.y:
			var nearest_tile_pos = Vector2()
			nearest_tile_pos.x = floor(mouse_pos.x/x_length) * x_length + initial_pos.x
			nearest_tile_pos.y = floor(mouse_pos.y/y_length) * y_length + initial_pos.y

			if gamestart == false:
				
				var nearest_chunk_pos = Vector2()
	
				nearest_chunk_pos.x = floor(nearest_tile_pos.x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
				nearest_chunk_pos.y = floor(nearest_tile_pos.y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y
#				
				current_chunk = nearest_chunk_pos
				initiate_board(nearest_tile_pos)
				#print(mouse_pos)
				#print(nearest_tile_pos)
			
			else:
				
				clicked(nearest_tile_pos)
	#if Input.is_action_just_pressed("restart"):
		#get_tree().reload_current_scene()
	
	#if Input.is_action_pressed("left_click"):
		#if moveable == false:
			#local_mous_pos = get_global_mouse_position()
		#moveable = true
	#if Input.is_action_just_released("left_click"):
		#moveable = false
	
	#if Input.is_action_just_pressed("left_click"):
		#thread = Thread.new()
		#thread.start(place_tile_loc(chunk_split, num_of_chunks))
	#
	if Input.is_action_just_pressed("right_click"):
		start = true
	
#############################################################################	
#############################################################################	
#############################################################################

func initiate_board(click_pos):
	gamestart = true
	#turn first click safe
	#var neighbors = create_neighbors(click_pos,x_length,y_length)
	var neighbors = tile_dict[click_pos][4]
	neighbors.append(click_pos)
	
	for i in neighbors:
		unused_pos.erase(i)
		tile_dict[i][1] = 'safe'

	randomize_mine_placement(click_pos)
	#randomize mines around start
	#var used_mine_positions = []
	#
	#for mine in number_of_mines_per_chunk:
		#
		##converting row, column numbering to position
		#var rand_tile_pos = unused_pos[randi_range(0,len(unused_pos) - 1)]
		#unused_pos.erase(rand_tile_pos)
		#update_dict(rand_tile_pos, 'mine', 0, true)
		#used_mine_positions.append(rand_tile_pos)
		#update_neighbors(rand_tile_pos,'mine')
	
	clicked(click_pos)

#############################################################################	
#############################################################################	
#############################################################################						
					
func clicked(pos):
	var nearest_chunk_pos = Vector2()
	
	nearest_chunk_pos.x = floor(pos.x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
	nearest_chunk_pos.y = floor(pos.y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y

	var node_path = 'chunks/' +  chunk_dict[nearest_chunk_pos][0] + '/' + tile_dict[pos][0]

	#print(tile_dict[pos][1])
	if tile_dict[pos][3] == false:
		tile_dict[pos][3] = true
		if tile_dict[pos][1] == 'unknown':
			tile_dict[pos][1] = 'safe'
			#update_neighbors(pos,'safe')
		var tile_type = tile_dict[pos][1]
		if tile_dict[pos][1] == 'warning':
			tile_type = str(tile_dict[pos][2])
		var sprite_path = 'sprites/' + tile_type
		var new_texture = get_node(sprite_path).texture
		
		get_node(node_path).texture = new_texture
		
	
		
			#_:
				#tile_dict[pos][1] = 'safe'
				#clicked(tile_dict[get_node(node_path).position])
				#update_neighbors(pos,'safe')
				
#############################################################################	
#############################################################################	
#############################################################################

#func clicked(node_path, type):
	#
	#get_node()
	#$sprites/hidden.visible = false
#
	#match array[1]:
		#'safe':
			#$sprites/safe.visible = true
		#
		#'mine': 
			#$sprites/mine_clicked.visible = true
			#
		#'warning':
			#var node_path = 'sprites/' + str(array[2])
			#get_node(node_path).visible = true

#############################################################################	
#############################################################################	
#############################################################################

#func update_dict(pos,type,value,is_hidden):
	#tile_dict[pos][1] = type
	#tile_dict[pos][2] = value
	#tile_dict[pos][3] = is_hidden
	
#############################################################################	
#############################################################################	
#############################################################################

func update_neighbors(pos,tile_type):	
	var neighbors = create_neighbors(pos,x_length,y_length)
	if tile_type == 'mine':
		for i in neighbors:
			
			if 8 <= i.x and i.x <= chosen_grid_size[0] * x_length - midpoint.x and 8 <= i.y and i.y <= chosen_grid_size[1] * y_length - midpoint.y:
				if tile_dict[i][1] == 'unknown':
					tile_dict[i][1] = 'warning'
				tile_dict[i][2] += 1
	
	if tile_type == 'safe':
		var safe_count = 0
		var theoretical_safe_count = 0
		for i in neighbors:
			if 8 <= i.x and i.x <= chosen_grid_size[0] * x_length - midpoint.x and 8 <= i.y and i.y <= chosen_grid_size[1] * y_length - midpoint.y:
				theoretical_safe_count += 1
				if tile_dict[i][1] != 'mine':
					safe_count +=1
		if safe_count == theoretical_safe_count:
			for i in neighbors:
				if 8 <= i.x and i.x <= chosen_grid_size[0] * x_length - midpoint.x and 8 <= i.y and i.y <= chosen_grid_size[1] * y_length - midpoint.y:
					
					if tile_dict[i][1] == 'unknown' or tile_dict[i][1] == 'warning':
						if tile_dict[i][3] == false:
							clicked(i)

#############################################################################	
#############################################################################	
#############################################################################

func create_neighbors(pos,x,y):
	
	var n = Vector2(pos.x, pos.y - y)
	var ne = Vector2(pos.x + x, pos.y - y)
	var e = Vector2(pos.x + x, pos.y)
	var se = Vector2(pos.x + x, pos.y + y)
	var s = Vector2(pos.x, pos.y + y)
	var sw = Vector2(pos.x - x, pos.y + y)
	var w = Vector2(pos.x - x, pos.y)
	var nw = Vector2(pos.x - x, pos.y - y)
	
	var pre_neighbors = [n,ne,e,se,s,sw,w,nw]
	var neighbors = []
	for i in pre_neighbors:
		if i.x >= lower_bounds.x and i.x <= upper_bounds.x and i.y >= lower_bounds.y and i.y <= upper_bounds.y:
			neighbors.append(i)
			
	return neighbors
	
	
func get_chunk_grid():
	
	var chunk_grid = []
	for x in chosen_grid_size[0]:
		for y in chosen_grid_size[1]:
			chunk_grid.append(Vector2(x,y))
	
	return chunk_grid
			



		
		
		
			
		
		
	
	
	
	
	
	
