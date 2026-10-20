extends Node2D

#notes for changing textures

var flag_correct = true
var lives = 1
var test
var panning = false
var drawing = false
var chance = 5
var stored_mous_pos = Vector2()
var round_points = 0
var total_clicked = 0
var hold_chunks =[]
var all_upgrade_data = {}
var all_store_data = {}
var upgrade
var timer = 5
var offset_amount = Vector2()
var used_mark = []
var num_of_chunks
var chunk_size
var x_length
var y_length
var gamestart = false
var initial_chunk_pos 
var moveable = false
var local_mous_pos
var stored_pos = Vector2()
var current_chunk = Vector2()
var ball_load = preload("res://ball.tscn")
var mat = load('res://mark.gdshader')
var mat2 = load("res://load.gdshader")
var drill_load = preload('res://driller.tscn')
var drone_load = preload('res://drone.tscn')
var ball_split_load = preload("res://ball_split.tscn")
var mouse_in = true
var custom_time = 0.0
enum states {HOVERING, HOLDING, DRAWING, CLICKING, PANNING}
var state: states = states.HOVERING: set = set_state
var book_spawned = false
var mark_selected = false
var banned_from_summons = false


func _notification(what: int) -> void:
	
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_in = true
	
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_in = false
		
func _ready() -> void:
	
	GameManager.connect("shape_guess",create_summon)
	x_length = MapManager.x_length
	y_length = MapManager.y_length
	chunk_size = MapManager.chunk_size
	current_chunk = MapManager.current_chunk
	num_of_chunks = MapManager.num_of_chunks
	update_lives(0)

	$Camera2D.position.x = chunk_size.x * num_of_chunks.x/2.0 + chunk_size.x/2.0
	$Camera2D.position.y = chunk_size.y * num_of_chunks.y/2.0 + chunk_size.y/2.0
	


func _process(delta: float) -> void:
	


	if state == states.PANNING:
		var difference = local_mous_pos - get_global_mouse_position()
		$Camera2D.position += difference

	var nearest_chunk_pos = Vector2()
	
	var chunk_follow_pos = $Camera2D.position

	nearest_chunk_pos = MapCalculator.get_nearest(chunk_follow_pos,'chunk')
	
	
	if nearest_chunk_pos != current_chunk:
		current_chunk = nearest_chunk_pos
		MapManager.update_chunk_pos(current_chunk)
		
	
func _unhandled_input(_event: InputEvent) -> void:

	var tile_dict = MapManager.tile_dict
	var mouse_pos = get_global_mouse_position()
	var nearest_tile_pos = MapCalculator.get_nearest(mouse_pos, 'tile')
	var nearest_chunk_pos = MapCalculator.get_nearest(nearest_tile_pos,'chunk')
	
	if Input.is_action_just_pressed("left_click"):
		stored_mous_pos = get_global_mouse_position()
		stored_pos = nearest_tile_pos
		
		if GameManager.book_collected == false:
			check_if_book(nearest_tile_pos)
			
		if state == states.HOLDING:
			if tile_dict[nearest_tile_pos]['clicked'] == true:
				upgrade.place(nearest_tile_pos)
				upgrade = 'NONE'
				state = states.HOVERING
			
	if Input.is_action_just_pressed("b"):
		GameManager.collect_book()
	
	if Input.is_action_pressed("left_click"):

		if (banned_from_summons == false 
		and MapManager.selected_mark.size() > 0
		and GameManager.book_collected == true):
			var diff = (mouse_pos - stored_mous_pos).length()
			if diff > 10:
				state = states.DRAWING
				$shapes.draw_true()

				
	if Input.is_action_just_released("left_click"):
		if state == states.HOVERING:
			if nearest_tile_pos == stored_pos:
				if gamestart == false:
					MapManager.first_click(nearest_tile_pos,nearest_chunk_pos)
					gamestart = true
				else:
					MapManager.clicked(nearest_tile_pos,nearest_chunk_pos)
					if GameManager.book_collected == false and book_spawned == false:
						if MapManager.revealed_tiles.size() >= 6:
							book_chance()
			MapManager.revealed_tiles = []
		
	if Input.is_action_just_pressed("right_click"):
		
		MapManager.change_mark_state(nearest_tile_pos, nearest_chunk_pos,'flip')

	if Input.is_action_just_pressed("restart"):
		
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("pan"):
		
		if state == states.HOVERING:
			state = states.PANNING
			local_mous_pos = get_global_mouse_position()

	if Input.is_action_just_released("pan"):
		
		if state == states.PANNING:
			state = states.HOVERING
	
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
		var rand_pos = randi_range(0,MapManager.revealed_tiles.size() - 1)
		var book_load = preload("res://book.tscn")
		var book = book_load.instantiate()
		$book.add_child(book)
		book.position = MapManager.revealed_tiles[rand_pos]
		book.offset = Vector2(x_length,y_length) / 2.0

func _on_game_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://home.tscn")
		
func create_summon(shape):
	
	if MapCalculator.check_marks():

		if shape == 'circle':
			var ball = ball_load.instantiate()
			add_child(ball)
			state = states.HOLDING
			upgrade = ball
			
		if shape == 'square':
			var driller = drill_load.instantiate()
			add_child(driller)
			state = states.HOLDING
			upgrade = driller
		
		if shape == 'triangle':
			var drone = drone_load.instantiate()
			add_child(drone)
			state = states.HOLDING
			upgrade = drone
			#drone.clicked()
		
	else:
		banned_from_summons = true
	
	var selected_mark = MapManager.selected_mark.duplicate()
	
	for i in selected_mark:
		var nearest_chunk_pos = MapCalculator.get_nearest(i, 'chunk')
		MapManager.change_mark_state(i,nearest_chunk_pos,'use')

	
func handle_draw_load(vis):
	if vis:
		$screen/draw_load.visible = true
		$screen/draw_load.material.set("shader_parameter/time",GameManager.custom_time)
		
	else:
		
		$screen/draw_load.visible = false


func _on_shader_buffer_timeout() -> void:
	$draw_load_timers/shader_buffer.stop()
	handle_draw_load(true)

func check_if_book(pos):
	if $book.get_child_count() > 0:
		if $book.get_child(0).position == pos:
			$book.get_child(0).queue_free()
			GameManager.collect_book()
		
func set_state(new_state):
	state = new_state

		
func _on_quit_button_pressed() -> void:
	
	get_tree().change_scene_to_file("res://home.tscn")

func spawn_balls(num_of_spawn,pos):
	
	for i in num_of_spawn:
		var ball_split = ball_split_load.instantiate()
		add_child(ball_split)
		ball_split.place(pos)
	
	
