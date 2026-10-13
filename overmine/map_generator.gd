extends Node2D

# used for creating initial map

var chunk_split
var initial_pos = Vector2(0,0)
var chunk_size = Vector2()
var x_length
var y_length
var chunk_dict = {}
var initial_chunk_pos 
var num_of_chunks = MapManager.num_of_chunks
var tile_dict = {}
var tile_load = preload("res://tile.tscn")
var chunk_load = preload("res://chunk_loc.tscn")
var chosen_grid_size = MapManager.chosen_grid_size
enum mark_states {UNMARKED, MARKED, SELECTED, USED}
var mark_state = mark_states.UNMARKED
enum tile_types {UNKNOWN,SAFE,WARNING,MINE}

	
func _ready() -> void:

	x_length = $sprites/new_sprites/hidden/hidden1.texture.get_width()
	MapManager.x_length = x_length
	
	y_length = $sprites/new_sprites/hidden/hidden1.texture.get_height()
	MapManager.y_length = y_length
	
	
	chunk_size = Vector2(chosen_grid_size[0],chosen_grid_size[1]) * Vector2(x_length,y_length)
	MapManager.chunk_size = chunk_size
	MapCalculator.create_bounds(initial_pos,chunk_size,num_of_chunks)
	
	
	chunk_split = -floor(num_of_chunks/2)
	MapManager.chunk_split = chunk_split
	
	initial_chunk_pos = MapCalculator.get_nearest(Vector2(chunk_size.x * num_of_chunks.x/2.0 + chunk_size.x/2.0,chunk_size.y * num_of_chunks.y/2.0 + chunk_size.y/2.0),'chunk')
	MapManager.initial_chunk_pos = initial_chunk_pos
	initialize_textures()
	place_chunk_loc()
	place_tile_loc()

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
	
func place_tile_loc():
	
	var start_pos = Vector2()  
	var x_tiles = chosen_grid_size[0] * num_of_chunks.x
	var y_tiles = chosen_grid_size[1] * num_of_chunks.y
	var tile_pos = Vector2()

	for x in x_tiles:
		for y in y_tiles:
			tile_pos = start_pos + Vector2(x_length,y_length) * Vector2(x,y)
			if MapCalculator.check_in_bounds(tile_pos):
			#if tile_dict.has(tile_pos) == false:
				
				tile_dict[tile_pos] = {
					'name': 'none',
					'type': tile_types.UNKNOWN,
					'value': 0,
					'clicked': false,
					'mark_state': mark_state,
					'scan_type': 'NONE'	
				}
					
	draw_initial_chunks(initial_chunk_pos)

func draw_initial_chunks(pos):
	
	MapManager.tile_dict = tile_dict
	MapManager.chunk_dict = chunk_dict
	var current_neighbors = MapCalculator.create_neighbors(pos,chunk_size.x,chunk_size.y, 'ALL')
	current_neighbors.append(pos)
	
	for i in current_neighbors:
		
		var chunk = chunk_load.instantiate()

		$chunks.add_child(chunk)
		chunk_dict[i]['name'] = chunk.name
		chunk_dict[i]['drawn'] = true
		chunk.position = i

		for x in chosen_grid_size[0]:
			for y in chosen_grid_size[1]:
			
				var tile = tile_load.instantiate()
				var global_pos = Vector2(x,y) * Vector2(x_length, y_length) + initial_pos + i
				
				chunk.add_child(tile)
				tile.global_position = global_pos
				tile_dict[tile.global_position]['name'] = tile.name	
				tile.texture = MapManager.texture_dict['hidden']['hidden1']
	
	MapManager.tile_dict = tile_dict
	MapManager.chunk_dict = chunk_dict

func initialize_textures():
		MapManager.texture_dict = {
		'mark' = {
			'mark0' = $sprites/new_sprites/mark/mark0.texture,
			'mark1' = $sprites/new_sprites/mark/mark1.texture,
			'mark2' = $sprites/new_sprites/mark/mark2.texture,
			'mark3' = $sprites/new_sprites/mark/mark3.texture,
			'mark4' = $sprites/new_sprites/mark/mark4.texture
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

	
