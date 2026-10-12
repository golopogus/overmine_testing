extends Node2D

# used for updating map and chunking

var flag_correct = true
var lives = 1
var test
var panning = false
var drawing = false
var chance = 5
var stored_mous_pos = Vector2()
var book_spawned = false
var round_points = 0
var total_clicked = 0
var hold_chunks =[]
var all_upgrade_data = {}
var all_store_data = {}
var upgrade_in_hand = false
var upgrade
var timer = 5
var used_mark = []
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
var number_of_mines_per_chunk = 175
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
var mat = load('res://mark.gdshader')
var mat2 = load("res://load.gdshader")
var drill_load = preload('res://driller.tscn')
var drone_base_load = preload('res://drone_base.tscn')
var mouse_in = true
var view_port_size
var custom_time = 0.0
var mine_thread
var texture_dict
var selected_mark = []
var banned_from_summons = Globals.book_ban

			
func randomize_mine_placement(pos):
	
	var unused_tile_grid = MapCalculator.get_chunk_grid()
	var unused_tile_pos = MapCalculator.convert_grid_to_pos(unused_tile_grid,pos)
	
	
	for i in safe_tiles:
		unused_tile_pos.erase(i)
	if chunk_dict[pos]['mines'] == false:
		for mine in number_of_mines_per_chunk:
			
			var rand_tile_pos = Vector2()
			
			rand_tile_pos = unused_tile_pos[randi_range(0, len(unused_tile_pos)-1)]					
			unused_tile_pos.erase(rand_tile_pos)		
			tile_dict[rand_tile_pos]['type'] = 'mine'
			
			var neighbors = MapCalculator.create_neighbors(rand_tile_pos,x_length,y_length, 'ALL')
			
			for i in neighbors:
				if tile_dict[i]['type'] != 'mine':
					tile_dict[i]['type'] = 'warning'
					tile_dict[i]['value'] += 1
						
		chunk_dict[pos]['mines'] = true


func update_chunk_pos(pos):
	
	var pos_to_move = []
	
	current_neighbors = MapCalculator.create_neighbors(pos,chunk_size.x,chunk_size.y, 'ALL')
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
				safe_tiles = MapCalculator.check_chunk_boundary(chunks_to_move[i].position)
		
				randomize_mine_placement(chunks_to_move[i].position)
				#call_deferred('randomize_mine_placement',chunks_to_move[i].position)

		
	for chunk in chunks_to_move:
		var chunk_children = chunk.get_children()
		for child in chunk_children:
			change_texture(child)
			#call_deferred('change_texture',child)
			
func highlight_mark(pos,chunk_pos,selected):
	var node_path = 'chunk_manager/chunks/' +  chunk_dict[chunk_pos]['name'] + '/' + tile_dict[pos]['name']
	var tile = MapCalculator.get_node_from_path(node_path)
	
		#tile.material.set("shader", val)
	if selected:
#
		tile.material.set("shader", '')
	else:

		tile.material = ShaderMaterial.new()
		tile.material.set("shader", mat)
	
func change_texture(tile):
	
	var pos = tile.global_position
	var sprite
	var tile_pos = tile_dict[pos]

	tile_dict[pos]['name'] = tile.name
	if tile_pos['clicked'] == false:
		if tile_pos['marked'] == true:
			if pos in used_mark:
				tile.texture = texture_dict['mark']['mark4']
			else:
				tile.texture = texture_dict['mark']['mark0']

		else:
		
			tile.texture = texture_dict['hidden']['hidden1']# + str(rand_num)]
	else:		
		if tile_pos['type'] == 'warning':
			sprite = str(tile_pos['value'])
			tile.texture = texture_dict[sprite]
		else:
			sprite = tile_pos['type']
			tile.texture = texture_dict[sprite]

func start_game(click_pos):
	gamestart = true
	
	var safe_neighbors = MapCalculator.create_neighbors(click_pos,x_length,y_length, 'ALL')
	
	safe_neighbors.append(click_pos)
	
	for i in safe_neighbors:
		tile_dict[i]['type'] = 'safe'
		safe_tiles.append(i)
	 
	var chunk_pos = MapCalculator.get_nearest(click_pos,'chunk')
	var chunk_neighbors = MapCalculator.create_neighbors(chunk_pos,chunk_size.x,chunk_size.y, 'ALL')
	
	chunk_neighbors.append(chunk_pos)
	
	for i in chunk_neighbors:
		safe_tiles = MapCalculator.check_chunk_boundary(i)
		randomize_mine_placement(i)	
		
	
	clicked(click_pos)
			
#############################################################################	
#############################################################################	
#############################################################################						
func clicked(pos):
	
	revealed_tiles.append(pos)
	var nearest_chunk_pos = MapCalculator.get_nearest(pos, 'chunk')
	var tile = tile_dict[pos]
	var node_path = 'chunk_manager/chunks/' +  chunk_dict[nearest_chunk_pos]['name'] + '/' + tile['name']
	var node = MapCalculator.get_node_from_path(node_path)
	if chunk_dict[nearest_chunk_pos]['drawn'] == true:
		if tile['clicked'] == false:
			total_clicked += 1
			tile['clicked'] = true
			if tile['type'] == 'unknown':
				tile['type'] = 'safe'

			change_texture(node)

			if tile['type'] == 'mine':
				
				var mine_radius = Globals.get_upgrade_data('mine_radius')#all_upgrade_data['mine_radius']['current']
				if mine_radius > 0:
					update_neighbors(pos,'mine')
					

		elif tile['clicked'] == true:
			
			if tile['type'] == 'warning':
				
				var neighbors = MapCalculator.create_neighbors(pos,x_length,y_length,'ALL')
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
			safe_tiles = MapCalculator.check_chunk_boundary(nearest_chunk_pos)
		
			randomize_mine_placement(nearest_chunk_pos)
		if tile_dict[pos]['type'] == 'unknown':
				tile_dict[pos]['type'] = 'safe'

		if tile_dict[pos]['type'] == 'mine':
			var mine_radius = Globals.all_upgrade_data['mine_radius']['current']
			if mine_radius > 0:
				update_neighbors(pos,'mine')
				
	if tile_dict[pos]['type'] == 'safe':
		
		update_neighbors(pos,'safe')					
	
			
#############################################################################	
#############################################################################	
#############################################################################

func update_neighbors(pos,type):	
	var nearest_chunk_pos = MapCalculator.get_nearest(pos, 'chunk')
	
	if chunk_dict[nearest_chunk_pos]['mines'] == false:
		print('o')
		await randomize_mine_placement(nearest_chunk_pos)
	
	var neighbors
	var mine_neighbors
	
	if type == 'safe':
		neighbors = MapCalculator.create_neighbors(pos, x_length, y_length, 'ALL')
		for i in neighbors:
			if tile_dict[i]['clicked'] == false:
				if tile_dict[i]['type'] != 'mine':
					clicked(i) 
	elif type == 'mine':
		mine_neighbors = MapCalculator.create_explosion_radius(pos)
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
	var node_path = "chunk_manager/chunks"
	var chunks = MapCalculator.get_node_from_path(node_path)
	
	
	for chunk in chunks.get_children():		
		for pos in dont_erase:
			if chunk.position == pos:
				chunk_dict[chunk.position]['drawn'] = true
				delete = false
		if delete == true:
			chunk_dict[chunk.position]['drawn'] = false
			chunks_to_move.append(chunk)
		delete = true

	return chunks_to_move

			
func mark(pos,chunk_pos):	
	
	var node_path = 'chunk_manager/chunks/' +  chunk_dict[chunk_pos]['name'] + '/' + tile_dict[pos]['name']
	var tile_node = MapCalculator.get_node_from_path(node_path)
	var tile = tile_dict[pos]
	if tile['clicked'] == false:

		if tile['marked'] == false:
			tile['marked'] = true
			
		elif tile['marked'] == true:
			tile['marked'] = false	

			if tile_node.material != null:
				tile_node.material.set("shader", '')	
	
	
	change_texture(tile_node)
		
func change_tile_sprite(pos):
	
	var nearest_chunk_pos = MapCalculator.get_nearest(pos, 'chunk')
	var node_path = 'chunk_manager/chunks/' +  chunk_dict[nearest_chunk_pos]['name'] + '/' + tile_dict[pos]['name']
	var node = MapCalculator.get_node_from_path(node_path)
	if nearest_chunk_pos in current_neighbors:
		if tile_dict[pos]['type'] == 'mine':
			var sprite_path = $chunk_manager/sprites/mine_scan#.texture
			var sprite = MapCalculator.get_node_from_path(sprite_path).texture
			node.texture = sprite
		else:
			var sprite_path = $chunk_manager/sprites/not_mine_scan#.texture
			var sprite = MapCalculator.get_node_from_path(sprite_path).texture
			node.texture = sprite
	
	if tile_dict[pos]['type'] == 'mine':
		tile_dict[pos]['scan_type'] = 'MINE_SCAN'
	else:
		tile_dict[pos]['scan_type'] = "SAFE_SCAN"
	
