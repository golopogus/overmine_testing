extends Node2D

const grid_size_options = [[8,8],[50,50]]
var chosen_grid_size = grid_size_options[0]
var num_of_chunks = Vector2(25,25)
var split
var initial_pos = Vector2(8,8)
var chunk_size = Vector2()
var x_length
var y_length
var start = false
var midpoint
var chunk_dict = {}
var gamestart = false
var initial_chunk_pos = Vector2(0,0)
var number_of_mines = 10
var unused_pos = []
var moveable = false
var local_mous_pos
var current_boundary
var tile_name_conv = 0
var chunk_name_conv = 0
var current_neighbors = []

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
	
	chunk_size.x= chosen_grid_size[0] * 16
	chunk_size.y= chosen_grid_size[1] * 16
	split = -floor(num_of_chunks/2)
	$Camera2D.position = chunk_size/2 
	place_chunk_loc()
	spawn_tiles()

#############################################################################	
#############################################################################	
#############################################################################

func _process(_delta: float) -> void:
	
	if moveable == true:
		var difference = local_mous_pos - get_global_mouse_position()
		$Camera2D.position += difference
	
	#check mouse pos closest to chunk, if drawn ok, if not draw given pos
	#var start at Vector2(-640,360)
	var nearest_chunk_pos = Vector2()
	
	nearest_chunk_pos.x = floor(get_global_mouse_position().x/chunk_size.x) * chunk_size.x + initial_chunk_pos.x
	nearest_chunk_pos.y = floor(get_global_mouse_position().y/chunk_size.y) * chunk_size.y + initial_chunk_pos.y
	

	if start == true:
		for i in current_neighbors:
			if i == nearest_chunk_pos:
				draw_chunk(i)
				break
	
#############################################################################	
#############################################################################	
#############################################################################
	
func spawn_tiles():
	var start_pos = Vector2()  
	start_pos.x = initial_pos.x + chunk_size.x * split.x
	start_pos.y = initial_pos.y + chunk_size.y * split.y
	
	var x_tiles = chosen_grid_size[0] * num_of_chunks.x
	var y_tiles = chosen_grid_size[1] * num_of_chunks.y
	#first need to find positions for each tile
	x_length = $sprites/hidden.texture.get_width()
	y_length = $sprites/hidden.texture.get_height()
	midpoint = Vector2(x_length/2,y_length/2)

	for x in x_tiles:
		for y in y_tiles:
			#var tile = tile_load.instantiate()
			#$tiles.add_child(tile)
			var tile_pos = Vector2(start_pos.x + x_length * x, start_pos.y + y_length * y )
			unused_pos.append(tile_pos)
			tile_dict[tile_pos] = ['none', 'unknown', 0, true]
	
	draw_chunk(initial_chunk_pos)

#############################################################################	
#############################################################################	
#############################################################################

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		if get_global_mouse_position().x >= 0 and get_global_mouse_position().x <= chosen_grid_size[0] * x_length and get_global_mouse_position().y >= 0 and get_global_mouse_position().y <= chosen_grid_size[1] * y_length:
			var nearest_tile_pos = Vector2()
			nearest_tile_pos.x = floor(get_global_mouse_position().x/x_length) * x_length + initial_pos.x
			nearest_tile_pos.y = floor(get_global_mouse_position().y/y_length) * y_length + initial_pos.y

			if gamestart == false:
				initiate_board(nearest_tile_pos)
			
			else:
				pre_click_check(nearest_tile_pos)
	#if Input.is_action_just_pressed("restart"):
		#get_tree().reload_current_scene()
	
	if Input.is_action_pressed("left_click"):
		if moveable == false:
			local_mous_pos = get_global_mouse_position()
		moveable = true
	if Input.is_action_just_released("left_click"):
		moveable = false
	
	if Input.is_action_just_pressed("right_click"):
		start = true
		
#############################################################################	
#############################################################################	
#############################################################################

func initiate_board(click_pos):
	gamestart = true
	#turn first click safe
	var neighbors = create_neighbors(click_pos,x_length,y_length)
	neighbors.append(click_pos)
	for i in neighbors:
		unused_pos.erase(i)
	
	tile_dict[click_pos][1] = 'safe'

	#randomize mines around start
	var used_mine_positions = []
	
	for mine in number_of_mines:
		
		#converting row, column numbering to position
		var rand_tile_pos = unused_pos[randi_range(0,len(unused_pos) - 1)]
		unused_pos.erase(rand_tile_pos)
		update_dict(rand_tile_pos, 'mine', 0, true)
		used_mine_positions.append(rand_tile_pos)
		update_neighbors(rand_tile_pos,'mine')
	
	pre_click_check(click_pos)

#############################################################################	
#############################################################################	
#############################################################################

func update_dict(pos,type,value,is_hidden):
	tile_dict[pos][1] = type
	tile_dict[pos][2] = value
	tile_dict[pos][3] = is_hidden
	
#############################################################################	
#############################################################################	
#############################################################################

func update_neighbors(pos,type):	
	var neighbors = create_neighbors(pos,x_length,y_length)
	if type == 'mine':
		for i in neighbors:
			
			if 8 <= i.x and i.x <= chosen_grid_size[0] * x_length - midpoint.x and 8 <= i.y and i.y <= chosen_grid_size[1] * y_length - midpoint.y:
				if tile_dict[i][1] == 'unknown':
					tile_dict[i][1] = 'warning'
				tile_dict[i][2] += 1
	
	if type == 'safe':
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
						if tile_dict[i][3] == true:
							pre_click_check(i)

#############################################################################	
#############################################################################	
#############################################################################						
					
func pre_click_check(pos):
	var node_path = 'tiles/' + tile_dict[pos][0]
	if tile_dict[pos][3] == true:
		tile_dict[pos][3] = false
		match tile_dict[pos][1]:
			'warning':
				get_node(node_path).clicked(tile_dict[get_node(node_path).position])
			'mine':
				get_node(node_path).clicked(tile_dict[get_node(node_path).position])
			_:
				tile_dict[pos][1] = 'safe'
				get_node(node_path).clicked(tile_dict[get_node(node_path).position])
				update_neighbors(pos,'safe')

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
	
	var neighbors = [n,ne,e,se,s,sw,w,nw]
	
	return neighbors
	
#############################################################################	
#############################################################################	
#############################################################################
	
func draw_chunk(pos):
	#check what is drawn
	
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
		var r = randf()
		$chunks.add_child(chunk)
		chunk_dict[i][0] = chunk.name
		chunk_dict[i][1] = true
		chunk.position = i
		chunk.modulate = Color(r,r,r)
		
		for x in chosen_grid_size[0]:
			for y in chosen_grid_size[1]:
				var tile = tile_load.instantiate()
				var path_2_node = 'chunks/' + chunk_dict[i][0]
				get_node(path_2_node).add_child(tile)
				tile.position = Vector2(x,y) * 16 
				var new_texture = get_node("sprites/hidden").texture
				tile.texture = new_texture
				tile_name_conv += 1
	
#############################################################################	
#############################################################################	
#############################################################################

func place_chunk_loc():
	
	var start_pos = Vector2()
	start_pos.x = chunk_size.x * split.x
	start_pos.y = chunk_size.y * split.y
	var chunk_position = Vector2()
	
	for x in num_of_chunks.x:
		for y in num_of_chunks.y:
			chunk_position = start_pos + Vector2(x,y)*chunk_size
			chunk_dict[chunk_position] = ['not_named',false]
			
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
	





		
		
		
			
		
		
	
	
	
	
	
	
