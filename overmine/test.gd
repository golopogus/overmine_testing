extends Node2D

const grid_size_options = [[8,8],[50,50]]
var chosen_grid_size = grid_size_options[0]
var bounds = Vector2()
var num_of_chunks = Vector2(5,5)
var num_of_chunks_start = Vector2(4,4)
var chunk_split
var shitter = Vector2()
var initial_chunk_split
var initial_pos = Vector2(0,0)
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
var upper_bounds_tiles
var lower_bounds_tiles
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
	$Camera2D.position.x = chunk_size.x * num_of_chunks.x/2
	$Camera2D.position.y = chunk_size.y * num_of_chunks.y/2
	
	place_chunk_loc()
	place_tile_loc()


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

	
	#if start == true:
	if nearest_chunk_pos != current_chunk:
		current_chunk = nearest_chunk_pos
		draw_chunk(current_chunk)
			

#############################################################################
#█ █▄░█ █ ▀█▀ █ ▄▀█ ▀█▀ █ █▄░█ █▀▀   █▀▀ █▀█ █ █▀▄
#█ █░▀█ █ ░█░ █ █▀█ ░█░ █ █░▀█ █▄█   █▄█ █▀▄ █ █▄▀
#############################################################################	

func place_chunk_loc():
	
	var start_pos = Vector2()
	#start_pos.x = chunk_size.x * chunk_split.x
	#start_pos.y = chunk_size.y * chunk_split.y

	var chunk_position = Vector2()
	
	for x in num_of_chunks.x:
		for y in num_of_chunks.y:
			chunk_position = start_pos + Vector2(x,y)*chunk_size
			
			chunk_dict[chunk_position] = ['not_named',false,false]
			
			#name, drawn, not_sure
	#chunk_dict[start_pos][2] = true
	
#############################################################################	
#############################################################################	
#############################################################################
	
func place_tile_loc():
	
	var start_pos = Vector2()  
	#start_pos.x = initial_pos.x + chunk_size.x * split.x
	#start_pos.y = initial_pos.y + chunk_size.y * split.y

	lower_bounds_tiles = start_pos
	upper_bounds_tiles = Vector2(chunk_size.x * num_of_chunks.x, chunk_size.x * num_of_chunks.x)
	#upper_bounds = Vector2(chunk_size.x * chunks.x - 16, chunk_size.y * chunks.y - 16)
	
	
	var x_tiles = chosen_grid_size[0] * num_of_chunks.x
	var y_tiles = chosen_grid_size[1] * num_of_chunks.y
	#first need to find positions for each tile
	x_length = $sprites/hidden.texture.get_width()
	y_length = $sprites/hidden.texture.get_height()
	midpoint = Vector2(x_length/2,y_length/2)

	
	var neighbors = []
	var tile_pos = Vector2()

	for x in x_tiles:
		for y in y_tiles:
			tile_pos = Vector2(start_pos.x + x_length * x, start_pos.y + y_length * y )
			if tile_dict.has(tile_pos) == false:
				unused_pos.append(tile_pos)
				neighbors = create_neighbors(tile_pos,x_length,y_length)
				tile_dict[tile_pos] = ['none', 'unknown', 0, false, neighbors,-1]
				
		
	draw_chunk(initial_chunk_pos)

#############################################################################	
#############################################################################	
#############################################################################

func randomize_mine_placement(pos):

	var unused_tile_pos = get_chunk_grid()
	
	if chunk_dict[pos][2] == false:
		for mine in number_of_mines_per_chunk:
			var rand_tile_pos = Vector2()
			rand_tile_pos = unused_tile_pos[randi_range(0, len(unused_tile_pos)-1)]					
			unused_tile_pos.erase(rand_tile_pos)
			var global_mine_pos = (rand_tile_pos * 16) + initial_pos + pos				
			if tile_dict[global_mine_pos][1] != 'safe':
				tile_dict[global_mine_pos][1] = 'mine'
				for neighbor in tile_dict[global_mine_pos][4]:
					if tile_dict[neighbor][1] != 'mine':
						tile_dict[neighbor][1] = 'warning'
						tile_dict[neighbor][2] += 1
						
		chunk_dict[pos][2] = true
						
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
	for i in dont_erase:
		if chunk_dict.has(i):
			if chunk_dict[i][1] == false:
				to_draw.append(i)
	
	for i in to_draw:
		var chunk = chunk_load.instantiate()
		#var r = randf()
		$chunks.add_child(chunk)
		chunk_dict[i][0] = chunk.name
		chunk_dict[i][1] = true
		chunk.position = i
		if chunk_dict[i][2] == false:# and gamestart == true:
			randomize_mine_placement(i)	
		
		#chunk.modulate = Color(r,r,r)
		
		for x in chosen_grid_size[0]:
			for y in chosen_grid_size[1]:
				var tile = tile_load.instantiate()
				var path_2_node = 'chunks/' + chunk_dict[i][0]
				get_node(path_2_node).add_child(tile)
				var global_pos = Vector2(x,y) * 16 + initial_pos + i
				tile.global_position = global_pos
				tile_dict[global_pos][0] = tile.name
				var tile_type = ''
				if tile_dict[global_pos][3] == true:
					
					if tile_dict[global_pos][1] == 'warning':
						tile_type = str(tile_dict[global_pos][2])
					else:
						tile_type = tile_dict[global_pos][1]
							
				else:
					if tile_dict[global_pos][5] == 1:
						tile_type = 'mark'
					else:
						tile_type = 'hidden'
				var sprite_path = 'sprites/' + tile_type
				var new_texture = get_node(sprite_path).texture		
				tile.texture = new_texture
				tile_name_conv += 1

	
	
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
	
	var mouse_pos = get_global_mouse_position()
	var nearest_tile_pos = Vector2()
	nearest_tile_pos.x = floor(mouse_pos.x/x_length) * x_length + initial_pos.x
	nearest_tile_pos.y = floor(mouse_pos.y/y_length) * y_length + initial_pos.y

	if tile_dict.has(nearest_tile_pos):
		var nearest_chunk_pos = Vector2()
		nearest_chunk_pos.x = floor(nearest_tile_pos.x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
		nearest_chunk_pos.y = floor(nearest_tile_pos.y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y
		current_chunk = nearest_chunk_pos
		if Input.is_action_just_pressed("left_click"):
		
			if gamestart == false:
				initiate_board(nearest_tile_pos)
			
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
	
	#if Input.is_action_just_pressed("left_click"):
		#thread = Thread.new()
		#thread.start(place_tile_loc(chunk_split, num_of_chunks))
	#
#	if Input.is_action_just_pressed("right_click"):
		#start = true

		
		#if mouse_pos.x >= lower_bounds.x and mouse_pos.x <= upper_bounds.x and mouse_pos.y >= lower_bounds.y and mouse_pos.y <= upper_bounds.y:
			#
			#var nearest_tile_pos = Vector2()
			#nearest_tile_pos.x = floor(mouse_pos.x/x_length) * x_length + initial_pos.x
			#nearest_tile_pos.y = floor(mouse_pos.y/y_length) * y_length + initial_pos.y
			#
			#tile_dict[nearest_tile_pos][5] *= -1
			#
			
			
			#mark(nearest_tile_pos)
			
			#clicked(nearest_tile_pos, 'right')
	
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
		#unused_pos.erase(i)
		tile_dict[i][1] = 'safe'
		#var chunk_pos = get_nearest(i,'chunk')
		#randomize_mine_placement(chunk_pos)	
	clicked(click_pos)

#############################################################################	
#############################################################################	
#############################################################################						
					
func clicked(pos):

	var nearest_chunk_pos = Vector2()
	
	nearest_chunk_pos.x = floor(pos.x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
	nearest_chunk_pos.y = floor(pos.y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y

	var node_path = 'chunks/' +  chunk_dict[nearest_chunk_pos][0] + '/' + tile_dict[pos][0]
	
	if chunk_dict[nearest_chunk_pos][1] == true:
		if tile_dict[pos][3] == false:
			tile_dict[pos][3] = true
			if tile_dict[pos][1] == 'unknown':
				tile_dict[pos][1] = 'safe'
			if tile_dict[pos][1] == 'safe':
				update_neighbors(pos,'safe')
				
			var tile_type = tile_dict[pos][1]
			
			if tile_dict[pos][1] == 'warning':
				tile_type = str(tile_dict[pos][2])
				
			var sprite_path = 'sprites/' + tile_type
			var new_texture = get_node(sprite_path).texture
			#print(chunk_dict[nearest_chunk_pos])
			
			get_node(node_path).texture = new_texture
		
		
#############################################################################	
#############################################################################	
#############################################################################

func update_neighbors(pos,tile_type):	
	#var neighbors = create_neighbors(pos,x_length,y_length)
	var neighbors = tile_dict[pos][4]

	if tile_type == 'safe':
		var safe_count = 0
		var theoretical_safe_count = neighbors.size()
		
		for i in neighbors:
			if tile_dict[i][1] != 'mine':
				safe_count += 1
		if safe_count == theoretical_safe_count:
			for i in neighbors:
				if tile_dict[i][3] == false:
					if tile_dict[i][1] != 'mine':#== 'unknown' or tile_dict[i][1] == 'warning':
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
		var nearest_chunk_pos = Vector2()
	
		nearest_chunk_pos.x = floor(i.x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
		nearest_chunk_pos.y = floor(i.y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y

		#if i.x >= lower_bounds.x and i.x <= upper_bounds.x and i.y >= lower_bounds.y and i.y <= upper_bounds.y:
		if chunk_dict.has(nearest_chunk_pos):
			neighbors.append(i)
			
	return neighbors
	
	
func get_chunk_grid():
	
	var chunk_grid = []
	for x in chosen_grid_size[0]:
		for y in chosen_grid_size[1]:
			chunk_grid.append(Vector2(x,y))
	
	return chunk_grid
			


func mark(pos,chunk_pos):	
	
	var node_path = 'chunks/' +  chunk_dict[chunk_pos][0] + '/' + tile_dict[pos][0]
	var sprite_path = 'sprites/'
	
	tile_dict[pos][5] *= -1
	
	if tile_dict[pos][5] == 1:
		sprite_path += 'mark'
	else:
		sprite_path += 'hidden'
		
	var new_texture = get_node(sprite_path).texture		
	get_node(node_path).texture = new_texture
	
	
func get_nearest(pos, val):
	
	var nearest = Vector2()
	
	match val:
		'chunk':
			nearest.x = floor(pos.x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
			nearest.y = floor(pos.y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y
		
		'tile':
			pass
	
	return nearest


			
		
		
			
		
		
	
	
	
	
	
	
