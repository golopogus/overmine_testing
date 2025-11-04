extends Node2D

#notes for changing textures

#need to update draw_chunk, clicked, and marked
var flag_correct = true
var lives = 1
var test
var chance = 11
var book_spawned = false
var round_points = 0
var total_clicked = 0
var hold_chunks =[]
var all_upgrade_data = {}
var all_store_data = {}
var upgrade_in_hand = false
var upgrade
var timer = 5
# final game grid = [40,25] x (25x50)
const grid_size_options = [[40,20],[4,4],[8,8]]
var chosen_grid_size = grid_size_options[0]
#var num_of_chunks = Vector2(25,50)
var num_of_chunks = Vector2(10,10)
var chunk_split
var initial_pos = Vector2(0,0)
var chunk_size = Vector2()
var x_length
var y_length
var start = false
var chunk_dict = {}
var gamestart = false
var revealed_tiles = []
var initial_chunk_pos 
var number_of_mines_per_chunk = 160
var moveable = false
var local_mous_pos
var current_neighbors = []
var stored_pos = Vector2()
var current_chunk = Vector2()
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
var ball_load = preload("res://ball.tscn")
var mark_load = preload('res://mark.tscn')
var mouse_in = true
var view_port_size
var mine_thread
var texture_dict
#############################################################################	
#############################################################################	
#############################################################################

func _notification(what: int) -> void:
	
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_in = true
	
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_in = false
		
func _ready() -> void:
	
	mine_thread = Thread.new()

	Globals.connect("ready_to_click",clicked)
	Globals.connect("ball_ready",send_init)
	Globals.connect("ball_pls",send_tiles)
	x_length = $sprites/new_sprites/hidden/hidden1.texture.get_width()
	y_length = $sprites/new_sprites/hidden/hidden1.texture.get_height()
	#x_length = $sprites/hidden.texture.get_width()
	#y_length = $sprites/hidden.texture.get_height()

	chunk_size = Vector2(chosen_grid_size[0],chosen_grid_size[1]) * Vector2(x_length,y_length)
	chunk_split = -floor(num_of_chunks/2)
	
	initial_chunk_pos = get_nearest(Vector2(chunk_size.x * num_of_chunks.x/2.0 + chunk_size.x/2.0,chunk_size.y * num_of_chunks.y/2.0 + chunk_size.y/2.0),'chunk')
	#$Camera2D.position = initial_chunk_pos
	current_chunk = initial_chunk_pos
	
	initialize_textures()
	initialize_upgrade_data()
	initialize_store_data()
	update_points()
	update_lives(0)
	place_chunk_loc()
	place_tile_loc()
	
	
	
	$Camera2D.position.x = chunk_size.x * num_of_chunks.x/2.0 + chunk_size.x/2.0
	$Camera2D.position.y = chunk_size.y * num_of_chunks.y/2.0 + chunk_size.y/2.0

#############################################################################	
#############################################################################	
#############################################################################

func _process(_delta: float) -> void:
	
	$screen/Label.text = str(roundi($game_timer.time_left))
	
	if moveable and mouse_in:
	
		var difference = local_mous_pos - get_global_mouse_position()
		$Camera2D.position += difference
	
	var nearest_chunk_pos = Vector2()
	
	var chunk_follow_pos = $Camera2D.position

	nearest_chunk_pos = get_nearest(chunk_follow_pos,'chunk')
	
	if nearest_chunk_pos != current_chunk:

		current_chunk = nearest_chunk_pos
		call_deferred('update_chunk_pos',current_chunk)

############################################################################	
#############################################################################	
#############################################################################
	
func _unhandled_input(_event: InputEvent) -> void:
	
	var mouse_pos = get_global_mouse_position()
	var nearest_tile_pos = get_nearest(mouse_pos, 'tile')
	var nearest_chunk_pos = get_nearest(nearest_tile_pos,'chunk')
	
	if Input.is_action_just_pressed("left_click"):
	
		stored_pos = nearest_tile_pos

		if upgrade_in_hand == true:
			if tile_dict[nearest_tile_pos]['clicked'] == true:
				upgrade.place(nearest_tile_pos)
				upgrade_in_hand = false
				upgrade = 'NONE'
		elif $drones.get_child_count() > 0:
			check_if_drone_base(nearest_tile_pos)
		
	if Input.is_action_just_released("left_click"):
		revealed_tiles = []
		if upgrade_in_hand == false:
			if nearest_tile_pos == stored_pos:
				if tile_dict.has(nearest_tile_pos):
					if gamestart == false:
						current_chunk = get_nearest(nearest_tile_pos,'chunk')
						start_game(nearest_tile_pos)
						print('number of safe tiles revealed = ' + str(revealed_tiles.size()))
					else:
						clicked(nearest_tile_pos)
						if book_spawned == false:
							if revealed_tiles.size() >= 9:
								book_chance()
								
	if Input.is_action_just_pressed("right_click"):
		
		mark(nearest_tile_pos, nearest_chunk_pos)
				
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	

	if Input.is_action_pressed("pan"):
		
		
		if moveable == false:
			local_mous_pos = get_global_mouse_position()
			
		moveable = true
		
	if Input.is_action_just_released("pan"):
		moveable = false
	
	if Input.is_action_just_pressed("add"):
		update_lives(1)
	if Input.is_action_just_pressed("subtract"):
		var ball = ball_load.instantiate()
		add_child(ball)

	# LAPTOP
	
	#if Input.is_action_just_pressed('zoom_in'):
			#if $Camera2D.zoom.x < 2.0 and $Camera2D.zoom.y < 2.0:
				#$Camera2D.zoom *= 2
	#
	#if Input.is_action_just_pressed('zoom_out'):
			#if $Camera2D.zoom.x > .5 and $Camera2D.zoom.y > .5:
				#$Camera2D.zoom /= 2
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
	
	for x in num_of_chunks.x:
		for y in num_of_chunks.y:
			chunk_position = start_pos + Vector2(x,y)*chunk_size
			chunk_dict[chunk_position] = {
				'name':'not_named',
				'drawn': false,
				'mines': false
				}
	
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
			if tile_dict.has(tile_pos) == false:
				
				tile_dict[tile_pos] = {
					'name': 'none',
					'type': 'unknown',
					'value': 0,
					'clicked': false,
					'marked': false,
					'scan_type': 'NONE'	
				}
					
	draw_initial_chunks(initial_chunk_pos)

#############################################################################	
#############################################################################	
#############################################################################
			
func randomize_mine_placement(pos):
	
	var unused_tile_grid = get_chunk_grid()
	var unused_tile_pos = convert_grid_to_pos(unused_tile_grid,pos)

	for i in safe_tiles:
		unused_tile_pos.erase(i)
	if chunk_dict[pos]['mines'] == false:
		for mine in number_of_mines_per_chunk:
			
			var rand_tile_pos = Vector2()
			
			rand_tile_pos = unused_tile_pos[randi_range(0, len(unused_tile_pos)-1)]					
			unused_tile_pos.erase(rand_tile_pos)		
			tile_dict[rand_tile_pos]['type'] = 'mine'
			
			var neighbors = create_neighbors(rand_tile_pos,x_length,y_length, 'ALL')
			
			for i in neighbors:
				if tile_dict[i]['type'] != 'mine':
					tile_dict[i]['type'] = 'warning'
					tile_dict[i]['value'] += 1
						
		chunk_dict[pos]['mines'] = true
						
#############################################################################	
#█▀▀ █░█ █░█ █▄░█ █▄▀ █ █▄░█ █▀▀
#█▄▄ █▀█ █▄█ █░▀█ █░█ █ █░▀█ █▄█	
#############################################################################

func update_chunk_pos(pos):
	
	var pos_to_move = []
	
	current_neighbors = create_neighbors(pos,chunk_size.x,chunk_size.y, 'ALL')
	current_neighbors.append(pos)
	
	var chunks_to_move = move_chunks(current_neighbors)

	
	for i in current_neighbors:
		if chunk_dict.has(i):
			if chunk_dict[i]['drawn'] == false:
				pos_to_move.append(i)
	

	for i in len(pos_to_move):

		if len(pos_to_move) == len(chunks_to_move):
			
			chunks_to_move[i].position = pos_to_move[i]
			chunk_dict[chunks_to_move[i].position]['drawn'] = true
			chunk_dict[chunks_to_move[i].position]['name'] = chunks_to_move[i].name
			
			if chunk_dict[chunks_to_move[i].position]['mines'] == false and gamestart == true:
				safe_tiles = []
				check_chunk_boundary(chunks_to_move[i].position)

				call_deferred('randomize_mine_placement',chunks_to_move[i].position)
		#else:
			#hold_chunks = chunks_to_move	
		
	for chunk in chunks_to_move:
		var chunk_children = chunk.get_children()
		for child in chunk_children:
			#change_texture(child)
			call_deferred('change_texture',child)

func change_texture(tile):
	
	var pos = tile.global_position
	var sprite
	var tile_pos = tile_dict[pos]

	tile_dict[pos]['name'] = tile.name
	if tile_pos['clicked'] == false:
		if tile_pos['marked'] == true:
			tile.texture = texture_dict['mark']['mark0']
		else:
			#var rand_num = randi_range(1,3)
			tile.texture = texture_dict['hidden']['hidden1']# + str(rand_num)]
	else:		
		if tile_pos['type'] == 'warning':
			sprite = str(tile_pos['value'])
			tile.texture = texture_dict[sprite]
		else:
			sprite = tile_pos['type']
			tile.texture = texture_dict[sprite]
		
	
		
	
func draw_initial_chunks(pos):
	
	current_neighbors = create_neighbors(pos,chunk_size.x,chunk_size.y, 'ALL')
	current_neighbors.append(pos)
	
	for i in current_neighbors:
		
		var chunk = chunk_load.instantiate()

		$chunks.add_child(chunk)
		chunk_dict[i]['name'] = chunk.name
		chunk_dict[i]['drawn'] = true
		chunk.position = i
		
		#safe_tiles = []
		#check_chunk_boundary(i)
		#randomize_mine_placement(i)	
		
		for x in chosen_grid_size[0]:
			for y in chosen_grid_size[1]:
			
				var tile = tile_load.instantiate()
				var global_pos = Vector2(x,y) * Vector2(x_length, y_length) + initial_pos + i
				
				chunk.add_child(tile)
				tile.global_position = global_pos
				tile_dict[tile.global_position]['name'] = tile.name	
				
				
				tile.texture = texture_dict['hidden']['hidden1']

					
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
	
	var border_up = []
	var border_down = []
	var border_left = []
	var border_right = []	
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
	
	find_clicked_on_border(border)

func find_clicked_on_border(border):
	
	for i in border['up']:
		if tile_dict[i]['clicked'] == true and tile_dict[i]['type'] != 'mine':
			var down_neighbors = create_neighbors(i,x_length,y_length,'BOTTOM')
			for neighbor in down_neighbors:
				if neighbor not in safe_tiles:
					safe_tiles.append(neighbor)
	
	for i in border['down']:
		if tile_dict[i]['clicked'] == true and tile_dict[i]['type'] != 'mine':
			var up_neighbors = create_neighbors(i,x_length,y_length,'TOP')
			for neighbor in up_neighbors:
				if neighbor not in safe_tiles:
					safe_tiles.append(neighbor)
		
	for i in border['left']:
		if tile_dict[i]['clicked'] == true and tile_dict[i]['type'] != 'mine':
			var right_neighbors = create_neighbors(i,x_length,y_length,'RIGHT')
			for neighbor in right_neighbors:
				if neighbor not in safe_tiles:
					safe_tiles.append(neighbor)
		
	for i in border['right']:
		if tile_dict[i]['clicked'] == true and tile_dict[i]['type'] != 'mine':
			var left_neighbors = create_neighbors(i,x_length,y_length,'LEFT')
			for neighbor in left_neighbors:
				if neighbor not in safe_tiles:
					safe_tiles.append(neighbor)
					
#############################################################################	
#############################################################################	
#############################################################################

func start_game(click_pos):
	$game_timer.start()
	gamestart = true
	
	var safe_neighbors = create_neighbors(click_pos,x_length,y_length, 'ALL')
	
	safe_neighbors.append(click_pos)
	
	for i in safe_neighbors:
		tile_dict[i]['type'] = 'safe'
		safe_tiles.append(i)
	 
	var chunk_pos = get_nearest(click_pos,'chunk')
	var chunk_neighbors = create_neighbors(chunk_pos,chunk_size.x,chunk_size.y, 'ALL')
	
	chunk_neighbors.append(chunk_pos)
	
	for i in chunk_neighbors:
		check_chunk_boundary(i)
		randomize_mine_placement(i)	
	
	clicked(click_pos)
			
#############################################################################	
#############################################################################	
#############################################################################						
func clicked(pos):
	
	revealed_tiles.append(pos)
	var nearest_chunk_pos = get_nearest(pos, 'chunk')
	var tile = tile_dict[pos]
	var node_path = 'chunks/' +  chunk_dict[nearest_chunk_pos]['name'] + '/' + tile['name']
	
	if chunk_dict[nearest_chunk_pos]['drawn'] == true:
		if tile['clicked'] == false:
			total_clicked += 1
			tile['clicked'] = true
			if tile['type'] == 'unknown':
				tile['type'] = 'safe'

			change_texture(get_node(node_path))

			if tile['type'] == 'mine':
				
				var mine_radius = all_upgrade_data['mine_radius']['current']
				if mine_radius > 0:
					update_neighbors(pos,'mine')
					
			if tile['type'] != 'mine':
				var score_mulitplier = all_upgrade_data['click_multi']['current'] + 1
				round_points += 1 * score_mulitplier
				update_points()
		
		
		# reveal if tile complete
		elif tile['clicked'] == true:
			
			if tile['type'] == 'warning':
				
				var neighbors = create_neighbors(pos,x_length,y_length,'ALL')
				var count = 0
				for i in neighbors:
					if tile_dict[i]['type'] == 'mine':
						if tile_dict[i]['clicked'] == true or tile_dict[i]['marked'] == true:
							count += 1
				if count == tile['value']:
					for i in neighbors:
						if tile_dict[i]['type'] != 'mine' and tile_dict[i]['clicked'] == false:
							clicked(i)
							
			
						
			
				
	elif chunk_dict[nearest_chunk_pos]['drawn'] == false:
		tile_dict[pos]['clicked'] = true
		total_clicked += 1
		if chunk_dict[nearest_chunk_pos]['mines'] == false:
			safe_tiles = []
			safe_tiles.append(pos)
			check_chunk_boundary(nearest_chunk_pos)
			randomize_mine_placement(nearest_chunk_pos)
		if tile_dict[pos]['type'] == 'unknown':
				tile_dict[pos]['type'] = 'safe'

		if tile_dict[pos]['type'] != 'mine':
			var score_multiplier = all_upgrade_data['click_multi']['current'] + 1
			round_points += 1 * score_multiplier
			update_points()
		if tile_dict[pos]['type'] == 'mine':
			var mine_radius = all_upgrade_data['mine_radius']['current']
			if mine_radius > 0:
				update_neighbors(pos,'mine')
				
	if tile_dict[pos]['type'] == 'safe':
		
		update_neighbors(pos,'safe')					
	
			
#############################################################################	
#############################################################################	
#############################################################################

func update_neighbors(pos,type):	
	var nearest_chunk_pos = get_nearest(pos, 'chunk')
	
	if chunk_dict[nearest_chunk_pos]['mines'] == false:
		await randomize_mine_placement(nearest_chunk_pos)
	
	var neighbors
	var mine_neighbors
	
	if type == 'safe':
		neighbors = create_neighbors(pos, x_length, y_length, 'ALL')
		for i in neighbors:
			if tile_dict[i]['clicked'] == false:
				if tile_dict[i]['type'] != 'mine':
					clicked(i) 
	elif type == 'mine':
		mine_neighbors = create_explosion(pos)
		await get_tree().create_timer(.1).timeout
		for i in mine_neighbors:
			if tile_dict[i]['clicked'] == false:
				clicked(i)
	
	
#############################################################################	
#############################################################################	
#############################################################################

func move_chunks(dont_erase):
	
	var delete = true
	var chunks_to_move = []
			
	for chunk in $chunks.get_children():		
		for pos in dont_erase:
			if chunk.position == pos:
				chunk_dict[chunk.position]['drawn'] = true
				delete = false
		if delete == true:
			chunk_dict[chunk.position]['drawn'] = false
			chunks_to_move.append(chunk)
		delete = true

	return chunks_to_move

	

#############################################################################	
#█▀▄▀█ █ █▀ █▀▀
#█░▀░█ █ ▄█ █▄▄	
#############################################################################

var neighbor_dict
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
	#var rand_num = randi_range(1,3)
	if tile_dict[pos]['clicked'] == false:

		if tile_dict[pos]['marked'] == false:
			tile_dict[pos]['marked'] = true
			
		elif tile_dict[pos]['marked'] == true:
			tile_dict[pos]['marked'] = false		
	
	if tile_dict[pos]['type'] != 'mine':
		flag_correct = false
	
	var node_path = 'chunks/' +  chunk_dict[chunk_pos]['name'] + '/' + tile_dict[pos]['name']
	change_texture(get_node(node_path))
		
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
	$CanvasLayer/Label2.text = str(total_clicked/1000000.0 * 100) + '% Completed! So CLOSE!'
	$CanvasLayer/Label.text = str(round_points)

#############################################################################	
#############################################################################	
#############################################################################

func _on_upgrade_button_pressed() -> void:
	
	var upgrade_menu = upgrade_load.instantiate()
	$CanvasLayer/normal_rez.add_child(upgrade_menu)
	upgrade_menu.get_upgrade_list(all_upgrade_data)
	upgrade_menu.update_upgrades.connect(handle_upgrades)

#############################################################################	
#############################################################################	
#############################################################################

func send_tiles(path,grid,type):
	
	var tiles = check_tiles(grid,type)

	get_node(path).set_tiles(tiles)

#############################################################################	
#############################################################################	
#############################################################################
	
func check_tiles(all_tile_positions,type):

	var tiles = []
	for tile_pos in all_tile_positions:
		if tile_dict.has(tile_pos):
			if type == 'drone':
				if tile_dict[tile_pos]['clicked'] == false and tile_dict[tile_pos]['marked'] == false and tile_dict[tile_pos]['scan_type'] == 'NONE':
					tiles.append(tile_pos)
			else:
				tiles = tile_dict[tile_pos]
	
	return tiles

#############################################################################	
#############################################################################	
#############################################################################

func check_tile_for_drone(pos,path,instance):
	
	if instance == 1:
		if tile_dict[pos]['clicked'] == false and tile_dict[pos]['marked'] == false and tile_dict[pos]['scan_type'] == 'NONE':
			tile_dict[pos]['scan_type'] = 'TAKEN'
			get_node(path).set_tile(true)
		else:
			get_node(path).set_tile(false)
	elif instance == 2:
		if tile_dict[pos]['clicked'] == false and tile_dict[pos]['marked'] == false:
			change_tile_sprite(pos)

#############################################################################	
#############################################################################	
#############################################################################
	
		
func change_tile_sprite(pos):
	
	var nearest_chunk_pos = get_nearest(pos, 'chunk')
	var node_path = 'chunks/' +  chunk_dict[nearest_chunk_pos]['name'] + '/' + tile_dict[pos]['name']
	if nearest_chunk_pos in current_neighbors:
		if tile_dict[pos]['type'] == 'mine':
			var sprite_path = $sprites/mine_scan.texture
			get_node(node_path).texture = sprite_path
		else:
			var sprite_path = $sprites/not_mine_scan.texture
			get_node(node_path).texture = sprite_path
	
	if tile_dict[pos]['type'] == 'mine':
		tile_dict[pos]['scan_type'] = 'MINE_SCAN'
	else:
		tile_dict[pos]['scan_type'] = "SAFE_SCAN"

#############################################################################	
#############################################################################	
#############################################################################

func create_explosion(pos):
	
	var n = pos + Vector2(0,-1) * Vector2(x_length,y_length)
	var s = pos + Vector2(0,1) * Vector2(x_length,y_length)
	var w = pos + Vector2(-1,0) * Vector2(x_length,y_length)
	var e = pos + Vector2(1,0) * Vector2(x_length,y_length)
	
	var pre_neighbors = [n,e,s,w]
	
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

#############################################################################	
#############################################################################	
#############################################################################

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

#############################################################################	
#############################################################################	
#############################################################################

func _on_texture_button_pressed() -> void:
	pass

#############################################################################	
#############################################################################	
#############################################################################

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

#############################################################################	
#############################################################################	
#############################################################################

func handle_upgrades(upgrade_data):
	
	all_upgrade_data[upgrade_data]['current'] += 1
	
	if upgrade_data == 'drone_add':
		Globals.connect("drone_ready", send_tiles)
		Globals.connect("drone_ready_for_check",check_tile_for_drone)
		update_inventory('drone','add')
	
	if upgrade_data == 'drill_add':
		Globals.connect("drill_ready", send_tiles)
		update_inventory('drill','add')
	
	if all_upgrade_data[upgrade_data]['owner'] == 'drone':
		for drone_base in $drones.get_children():
			drone_base.update_upgrade(upgrade_data, all_upgrade_data[upgrade_data]['current'])
		
#############################################################################	
#############################################################################	
#############################################################################	

func _on_drone_button_pressed() -> void:
	if all_store_data['drone']['inventory'] > 0:
		update_inventory('drone','remove')
		if $drones.get_child_count() == 0:
			var drone_base_load = preload("res://drone_base.tscn")
			var drone_base = drone_base_load.instantiate()
			$drones.add_child(drone_base)
			drone_base.get_initial_upgrades(all_upgrade_data)
			upgrade_in_hand = true
			upgrade = drone_base
			drone_base.clicked()
		else:
			$drones.get_child(0).new_spawn()

#############################################################################	
#############################################################################	
#############################################################################

func _on_drill_button_pressed() -> void:
	
	if all_store_data['drill']['inventory'] > 0:
		update_inventory('drill','remove')
		#round_points -= cost_of_drill
		#cost_of_drill += 10
		#$CanvasLayer/normal_rez/Button3.text = '+1 Drill' + str(cost_of_drill)
		#update_points()
		var driller_load = preload("res://driller.tscn")
		var driller = driller_load.instantiate()
		#add to folder?
		add_child(driller)
		upgrade_in_hand = true
		upgrade = driller
		driller.clicked()

#############################################################################	
#############################################################################	
#############################################################################

func update_inventory(item,action):
	
	var node_path = 'CanvasLayer/normal_rez/game/' + item + '_buttons'
	if all_store_data[item]['inventory'] == -1:
		get_node(node_path).visible = true
	
	if action == 'add':
		all_store_data[item]['inventory'] += 1
	if action == 'remove':
		all_store_data[item]['inventory'] -= 1
	
	get_node(node_path + '/' + item + '_button/Label').text = str(all_store_data[item]['inventory'])

#############################################################################	
#############################################################################	
#############################################################################

func _on_buy_drill_pressed() -> void:
	if all_upgrade_data['drill_add']['cost'] < round_points:
		round_points -= all_upgrade_data['drill_add']['cost']
		update_points()
		update_inventory('drill','add')

#############################################################################	
#############################################################################	
#############################################################################

func _on_buy_drone_pressed() -> void:
	if all_upgrade_data['drone_add']['cost'] < round_points:
		round_points -= all_upgrade_data['drone_add']['cost']
		update_points()
		update_inventory('drone','add')

#############################################################################	
#############################################################################	
#############################################################################

func check_if_drone_base(pos):
	if $drones.get_child(0).position == pos:
		upgrade_in_hand = true
		upgrade = $drones.get_child(0)
		$drones.get_child(0).clicked()

#############################################################################	
#############################################################################	
#############################################################################
func book_chance():
	chance -= 1
	var rand_num = randi_range(1,chance)
	if rand_num == chance:
		book_spawned = true
		var rand_pos = randi_range(0,revealed_tiles.size() - 1)
		var book_load = preload("res://book.tscn")
		var book = book_load.instantiate()
		add_child(book)
		book.position = revealed_tiles[rand_pos]
		book.offset = Vector2(x_length,y_length) / 2.0
	
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
			'max': 10,
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

func create_double_neighbors(pos,x,y):
	
	var pre_neighbors
	var n = pos + Vector2(0,-1) * Vector2(x,y)
	var ne = pos + Vector2(1,-1) * Vector2(x,y)
	var nw = pos + Vector2(-1,-1) * Vector2(x,y)
	var s = pos + Vector2(0,1) * Vector2(x,y)
	var se = pos + Vector2(1,1) * Vector2(x,y)
	var sw = pos + Vector2(-1,1) * Vector2(x,y)
	var w = pos + Vector2(-1,0) * Vector2(x,y)
	var e = pos + Vector2(1,0) * Vector2(x,y)
	
	var n2 = pos + Vector2(0,-2) * Vector2(x,y)
	var ne2 = pos + Vector2(2,-2) * Vector2(x,y)
	var nw2 = pos + Vector2(-2,-2) * Vector2(x,y)
	var s2 = pos + Vector2(0,2) * Vector2(x,y)
	var se2 = pos + Vector2(2,2) * Vector2(x,y)
	var sw2 = pos + Vector2(-2,2) * Vector2(x,y)
	var w2 = pos + Vector2(-2,0) * Vector2(x,y)
	var e2 = pos + Vector2(2,0) * Vector2(x,y)
	
	var n3 = pos + Vector2(1,-2) * Vector2(x,y)
	var ne3 = pos + Vector2(-1,-2) * Vector2(x,y)
	var nw3 = pos + Vector2(-2,1) * Vector2(x,y)
	var s3 = pos + Vector2(-2,-1) * Vector2(x,y)
	var se3 = pos + Vector2(2,1) * Vector2(x,y)
	var sw3 = pos + Vector2(2,-1) * Vector2(x,y)
	var w3 = pos + Vector2(-1,2) * Vector2(x,y)
	var e3 = pos + Vector2(1,2) * Vector2(x,y)

	pre_neighbors = [n,ne,e,se,s,sw,w,nw,n2,ne2,e2,se2,s2,sw2,w2,nw2,n3,ne3,e3,se3,s3,sw3,w3,nw3]
	
			
	var neighbors = []

	for i in pre_neighbors:
		var nearest_chunk_pos = get_nearest(i,'chunk')
		
		if chunk_dict.has(nearest_chunk_pos):
			neighbors.append(i)
				
	return neighbors
	
func send_init(path):
	
	get_node(path).set_init(Vector2(x_length,y_length),initial_pos)

func initialize_textures():
		texture_dict = {
		'mark' = {
			'mark0' = $sprites/new_sprites/mark/mark0.texture,
			'mark1' = $sprites/new_sprites/mark/mark1.texture,
			'mark2' = $sprites/new_sprites/mark/mark2.texture,
			'mark3' = $sprites/new_sprites/mark/mark3.texture
		},
		'hidden' = {
			'hidden1' = $sprites/new_sprites/hidden/hidden1.texture,
			'hidden2' = $sprites/new_sprites/hidden/hidden2.texture,
			'hidden3' = $sprites/new_sprites/hidden/hidden3.texture
		},
		'1' = $"sprites/new_sprites/1".texture,
		'2' = $"sprites/new_sprites/2".texture,
		'3' = $"sprites/new_sprites/3".texture,
		'4' = $"sprites/new_sprites/4".texture,
		'5' = $"sprites/new_sprites/5".texture,
		'6' = $"sprites/new_sprites/6".texture,
		'7' = $"sprites/new_sprites/7".texture,
		'8' = $"sprites/new_sprites/8".texture,
		'safe' = $sprites/new_sprites/safe.texture,
		'mine' = $sprites/new_sprites/mine.texture
	}


func _on_game_timer_timeout() -> void:
	$screen/border_in.time_out()
