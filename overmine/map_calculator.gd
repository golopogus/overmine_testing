extends Node2D

# used for calculations for map

var bounds
enum tile_types {UNKNOWN,SAFE,WARNING,MINE}

func create_bounds(initial_pos,chunk_size,num_of_chunks):
	var outer = chunk_size * num_of_chunks
	var inner = initial_pos
	bounds = Rect2(inner,outer)
	
	
func get_nearest(pos, type):

	if check_in_bounds(pos):
		var nearest = Vector2()
		match type:
			'chunk':
				nearest = floor(pos / MapManager.chunk_size) * MapManager.chunk_size + MapManager.initial_pos
			'tile':
				nearest = floor(pos / Vector2(MapManager.x_length,MapManager.y_length)) * Vector2(MapManager.x_length,MapManager.y_length) + MapManager.initial_pos
			
		return nearest
	else:
		pass
	
func check_in_bounds(pos):
	if pos != null and bounds.has_point(pos):
		return true
	else:
		return false
	
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
		if check_in_bounds(i):
		#var nearest_chunk_pos = get_nearest(i,'chunk')
			neighbors.append(i)
		
	return neighbors
	
func convert_grid_to_pos(grid,pos):
	
	var new_grid = []
	for i in grid:
		var new_pos = (i * Vector2(MapManager.x_length, MapManager.y_length)) + MapManager.initial_pos + pos
		new_grid.append(new_pos)
		
	return new_grid

func get_chunk_grid():
	
	var chunk_grid = []
	for x in MapManager.chosen_grid_size[0]:
		for y in MapManager.chosen_grid_size[1]:
			chunk_grid.append(Vector2(x,y))
	
	return chunk_grid
	
func get_node_from_pos(pos):
	
	var nearest_chunk_pos = get_nearest(pos, 'chunk')
	var node_path = 'chunks/' +  MapManager.chunk_dict[nearest_chunk_pos]['name'] + '/' + MapManager.tile_dict[pos]['name']
	#var node = get_node_from_path()
	return get_node(node_path)

func check_chunk_boundary(pos):
	
	var x_bounds = [0,MapManager.chosen_grid_size[0] - 1] 
	var y_bounds = [0,MapManager.chosen_grid_size[1] -1]
	var x_length = MapManager.x_length
	var y_length = MapManager.y_length
	var initial_pos = MapManager.initial_pos
	var tile_dict = MapManager.tile_dict
	var safe_tiles = MapManager.safe_tiles
	
	var global_bounds = [Vector2(x_bounds[0],y_bounds[0]) * Vector2(x_length, y_length) + initial_pos + pos - Vector2(x_length, y_length),
						 Vector2(x_bounds[1],y_bounds[1]) * Vector2(x_length, y_length) + initial_pos + pos + Vector2(x_length, y_length)]
	var jump = 3
	var sim_size = Vector2()
	
	var border_up = []
	var border_down = []
	var border_left = []
	var border_right = []	
	if x_bounds[1] % 3 == 0 or x_bounds[1] % 3 == 1:
		sim_size.x = x_bounds[1]
	else:
		sim_size.x = x_bounds[1] + 1
		
	if y_bounds[1] % 3 == 0 or y_bounds[1] % 3 == 1:
		sim_size.y = y_bounds[1]
	else:
		sim_size.y = y_bounds[1] + 1
	
	
	for x in int(sim_size.x):
		
		if x % jump == 0:
		
			var top_row_pos = Vector2(x,y_bounds[0])
			var top_row_pos_global = (top_row_pos * Vector2(x_length, y_length)) + initial_pos + pos
			var tiles_above_pos = create_neighbors(top_row_pos_global,x_length,y_length,'TOP')
			
			for i in tiles_above_pos:
				if i.x >= global_bounds[0].x and i.x <= global_bounds[1].x:
					border_up.append(i)
			
			var bottom_row_pos = Vector2(x,y_bounds[1])
			var bottom_row_pos_global = (bottom_row_pos * Vector2(x_length, y_length)) + initial_pos + pos
			var tiles_below_pos = create_neighbors(bottom_row_pos_global,x_length,y_length,'BOTTOM')
			
			for i in tiles_below_pos:
				if i.x >= global_bounds[0].x and i.x <= global_bounds[1].x:
					border_down.append(i)
		
	for y in int(sim_size.y):
		
		if y % jump == 0:
			
			var left_col_pos = Vector2(x_bounds[0],y)
			var left_col_pos_global = (left_col_pos * Vector2(x_length, y_length)) + initial_pos + pos
			var tiles_left_of_pos = create_neighbors(left_col_pos_global,x_length,y_length,'LEFT')
			
			for i in tiles_left_of_pos:
				if i.y >= global_bounds[0].y and i.y <= global_bounds[1].y:
					border_left.append(i)
			
			var right_row_pos = Vector2(x_bounds[1],y)
			var right_row_pos_global = (right_row_pos * Vector2(x_length, y_length)) + initial_pos + pos
			var tiles_right_of_pos = create_neighbors(right_row_pos_global,x_length,y_length,'RIGHT')
			
			for i in tiles_right_of_pos:
				if i.y >= global_bounds[0].y and i.y <= global_bounds[1].y:
					border_right.append(i)
	
	var border = {
		'up' = border_up,
		'down' = border_down,
		'left' = border_left,
		'right' = border_right,
	}
	
	for i in border['up']:
		if tile_dict[i]['clicked'] == true and tile_dict[i]['type'] != tile_types.MINE:
			var down_neighbors = create_neighbors(i,x_length,y_length,'BOTTOM')
			for neighbor in down_neighbors:
				if neighbor not in safe_tiles:
					safe_tiles.append(neighbor)
	
	for i in border['down']:
		if tile_dict[i]['clicked'] == true and tile_dict[i]['type'] != tile_types.MINE:
			var up_neighbors = create_neighbors(i,x_length,y_length,'TOP')
			for neighbor in up_neighbors:
				if neighbor not in safe_tiles:
					safe_tiles.append(neighbor)
		
	for i in border['left']:
		if tile_dict[i]['clicked'] == true and tile_dict[i]['type'] != tile_types.MINE:
			var right_neighbors = create_neighbors(i,x_length,y_length,'RIGHT')
			for neighbor in right_neighbors:
				if neighbor not in safe_tiles:
					safe_tiles.append(neighbor)
		
	for i in border['right']:
		if tile_dict[i]['clicked'] == true and tile_dict[i]['type'] != tile_types.MINE:
			var left_neighbors = create_neighbors(i,x_length,y_length,'LEFT')
			for neighbor in left_neighbors:
				if neighbor not in safe_tiles:
					safe_tiles.append(neighbor)
	
	return safe_tiles

func create_explosion_radius(pos):
	
	var x_length = MapManager.x_length
	var y_length = MapManager.y_length
	var n = pos + Vector2(0,-1) * Vector2(x_length,y_length)
	var s = pos + Vector2(0,1) * Vector2(x_length,y_length)
	var w = pos + Vector2(-1,0) * Vector2(x_length,y_length)
	var e = pos + Vector2(1,0) * Vector2(x_length,y_length)
	
	var pre_neighbors = [n,e,s,w]
	
	var mine_radius = GameManager.all_upgrade_data['mine_radius']['current']
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
		#var nearest_chunk_pos = get_nearest(i,'chunk')
		
		#if MapManager.chunk_dict.has(nearest_chunk_pos):
		if check_in_bounds(i):
			neighbors.append(i)
				
	return neighbors

func check_marks():
	var correct = true
	for i in MapManager.selected_mark:
		if MapManager.tile_dict[i]['type'] != tile_types.MINE:
			correct = false
			break
	return correct


func get_node_from_path(tree_path):
	var node = get_tree().current_scene.get_node(tree_path)
	
	return node
