extends Node2D

#notes for changing textures

#need to update draw_chunk, clicked, and marked
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
#var tile_dict = {} # pos = [tile.name, 'unknown' (type), value, true (hidden),marked]
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

var selected_mark = []
var banned_from_summons = Globals.book_ban
#############################################################################	
#############################################################################	
#############################################################################

func _notification(what: int) -> void:
	
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_in = true
	
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_in = false
		
func _ready() -> void:
	
	Globals.connect("shape_guess",create_summon)
	x_length = MapManager.x_length
	y_length = MapManager.y_length
	chunk_size = MapManager.chunk_size
	chunk_split = -floor(num_of_chunks/2)
	initial_chunk_pos = MapManager.initial_chunk_pos
	current_chunk = MapManager.current_chunk
	update_lives(0)
	$Camera2D.position.x = chunk_size.x * num_of_chunks.x/2.0 + chunk_size.x/2.0
	$Camera2D.position.y = chunk_size.y * num_of_chunks.y/2.0 + chunk_size.y/2.0



func _process(delta: float) -> void:
	
	$screen/draw_load.position = get_viewport().get_mouse_position()
	#Globals.custom_time += delta
	$screen/Label.text = str(roundi($game_timer.time_left))
	
	if moveable and mouse_in:
	#if panning and mouse_in:
	
		var difference = local_mous_pos - get_global_mouse_position()
		$Camera2D.position += difference
	
	var nearest_chunk_pos = Vector2()
	
	var chunk_follow_pos = $Camera2D.position

	nearest_chunk_pos = MapCalculator.get_nearest(chunk_follow_pos,'chunk')
	
	
	
	if nearest_chunk_pos != current_chunk:
		current_chunk = nearest_chunk_pos
		MapManager.update_chunk_pos(current_chunk)
		
		#call_deferred('update_chunk_pos',current_chunk)

############################################################################	
#############################################################################	
#############################################################################
	
func _unhandled_input(_event: InputEvent) -> void:
	
	var tile_dict = MapManager.tile_dict
	var mouse_pos = get_global_mouse_position()
	var nearest_tile_pos = MapCalculator.get_nearest(mouse_pos, 'tile')
	var nearest_chunk_pos = MapCalculator.get_nearest(nearest_tile_pos,'chunk')
	
	if Input.is_action_just_pressed("left_click"):
		stored_mous_pos = get_global_mouse_position()
		stored_pos = nearest_tile_pos
		
		if upgrade_in_hand == true:
			if tile_dict[nearest_tile_pos]['clicked'] == true:
				upgrade.place(nearest_tile_pos)
				upgrade_in_hand = false
				upgrade = 'NONE'
		
		#elif check_if_book(nearest_tile_pos):
			#pass
			
		#elif gamestart == true and selected_mark.size() > 0:
				#$draw_load_timers/shader_buffer.start()
				#$draw_load_timers/click_timer.start()
	if Input.is_action_just_pressed("b"):
		Globals.has_book()
		banned_from_summons = false
	if Input.is_action_pressed("left_click"):
			#if drawing == true:
				#$shapes.draw_true()
			var diff = (mouse_pos - stored_mous_pos).length()
			
			#if nearest_tile_pos != stored_pos:
			if diff > 10:
				if moveable == false:
					local_mous_pos = get_global_mouse_position()
				moveable = true
		#if spell == true:
			#$shapes.draw_true()
			
		
	if Input.is_action_just_released("left_click"):
			
			#$draw_load_timers/shader_buffer.stop()
			#$draw_load_timers/click_timer.stop()
			#handle_draw_load(false)
				
			revealed_tiles = []
			if moveable == false:
				if upgrade_in_hand == false:
					if nearest_tile_pos == stored_pos:
							if tile_dict.has(nearest_tile_pos):
								if gamestart == false:
									current_chunk = MapCalculator.get_nearest(nearest_tile_pos,'chunk')
									MapManager.start_game(nearest_tile_pos)
									gamestart = true
									#print('number of safe tiles revealed = ' + str(revealed_tiles.size()))

								else:
									
									if tile_dict[nearest_tile_pos]['marked'] == false:			
										MapManager.clicked(nearest_tile_pos)
										if book_spawned == false and Globals.book_ban == true:
											if revealed_tiles.size() >= 6:
												book_chance()
									elif nearest_tile_pos not in MapManager.used_mark and banned_from_summons == false:
										
										if nearest_tile_pos in selected_mark:
											selected_mark.erase(nearest_tile_pos)
											MapManager.highlight_mark(nearest_tile_pos,nearest_chunk_pos,true)
										else:
											selected_mark.append(nearest_tile_pos)
											MapManager.highlight_mark(nearest_tile_pos,nearest_chunk_pos,false)
									else:
										print(banned_from_summons)
			else:
				#for i in selected_mark:
					#used_mark.append(i)
					#change_texture(get_node_from_pos(i))
					
					
				moveable = false
				#selected_mark = []
					#elif spell == true:
						#if tile_dict[nearest_tile_pos]['marked'] == true:
							#highlight_mark(nearest_tile_pos,nearest_chunk_pos)
			#moveable = false
	if Input.is_action_just_pressed("right_click"):

		if tile_dict.has(nearest_tile_pos):
			if nearest_tile_pos not in MapManager.used_mark:
				MapManager.mark(nearest_tile_pos, nearest_chunk_pos)


				
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	

	if Input.is_action_pressed("pan"):
		if Globals.book_ban == false and selected_mark.size() > 0:
			$shapes.draw_true()
		#if moveable == false:
			#local_mous_pos = get_global_mouse_position()
			#
		#moveable = true
		
	if Input.is_action_just_released("pan"):
		moveable = false
	
	if Input.is_action_just_pressed("add"):
		update_lives(1)
	if Input.is_action_just_pressed("subtract"):
		var ball = ball_load.instantiate()
		add_child(ball)
	
	if Input.is_action_just_pressed("esc"):
		get_tree().change_scene_to_file("res://home.tscn")
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
				$Camera2D.zoom += Vector2(.1,.1)
		
	if _event is InputEventMouseButton:
		if _event.button_index == MOUSE_BUTTON_WHEEL_DOWN and _event.pressed:
			if $Camera2D.zoom.x >= .5 and $Camera2D.zoom.y >= .5:
				$Camera2D.zoom -= Vector2(.1,.1)
		
					
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

	
func book_chance():
	chance -= 1
	var rand_num = randi_range(1,chance)
	if rand_num == chance:
		book_spawned = true
		var rand_pos = randi_range(0,revealed_tiles.size() - 1)
		var book_load = preload("res://book.tscn")
		var book = book_load.instantiate()
		$book.add_child(book)
		book.position = revealed_tiles[rand_pos]
		book.offset = Vector2(x_length,y_length) / 2.0


	


func _on_game_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://home.tscn")
	#$screen/border_in.time_out()

			
func create_summon(shape):
	
	if MapCalculator.check_marks():
		var num_mark = len(selected_mark)
		
		if shape == 'circle':
		#	print(num_mark)
			var ball = ball_load.instantiate()
			add_child(ball)
			upgrade_in_hand = true
			upgrade = ball
			ball.clicked()
		
		if shape == 'square':
			var driller = drill_load.instantiate()
			add_child(driller)
			upgrade_in_hand = true
			upgrade = driller
			driller.clicked()
		
		if shape == 'triangle':
			var drone_base = drone_base_load.instantiate()
			$drones.add_child(drone_base)
			upgrade_in_hand = true
			upgrade = drone_base
			drone_base.clicked()
	
		for i in selected_mark:
			used_mark.append(i)
			MapManager.used_mark = used_mark
			MapManager.change_texture(MapCalculator.get_node_from_pos(i))
	else:
		var temp_mark = []
		for i in selected_mark:
			temp_mark.append(i)
		for i in temp_mark:
			MapManager.highlight_mark(i,MapCalculator.get_nearest(i,'chunk'),true)
		banned_from_summons = true
	
	selected_mark = []

#func _on_click_timer_timeout() -> void:
	#$draw_load_timers/click_timer.stop()
	#handle_draw_load(false)
	#drawing = true

	
func handle_draw_load(vis):
	if vis:
		$screen/draw_load.visible = true
		$screen/draw_load.material.set("shader_parameter/time",Globals.custom_time)
		
	else:
		
		$screen/draw_load.visible = false


func _on_shader_buffer_timeout() -> void:
#	print('hello')	
	$draw_load_timers/shader_buffer.stop()
	handle_draw_load(true)

func check_if_book(pos):
	var book = false
	if $book.get_child_count() > 0:
		if $book.get_child(0).position == pos:
			$book.get_child(0).queue_free()
			banned_from_summons = false
			Globals.has_book()
			
	
	return book
		

func _on_quit_button_pressed() -> void:
	
	get_tree().change_scene_to_file("res://home.tscn")
