extends CharacterBody2D

var moving = false
var scanning = false
var scannable_chunk
var x_length
var y_length
var chunk_size
var home_pos
const grid_size_options = [[20,20],[50,50],[4,4]]
var chosen_grid_size = grid_size_options[0]
var scanning_tile = Vector2()
var possible_tiles = []
var scan_speed = 1
var checked_tiles = []
var initial_scan_time = 4.8
var scan_pos
var speed
var scan_area
var scan = []
var area_2_scan
var tile_info
var search_area = []
var battery
var going_home = false
var g_pos = Vector2()
var is_tiles = true
var initialized = false
enum tile_types {UNKNOWN,SAFE,WARNING,MINE}
enum states {SELECTED,IDLE,MOVING,SCANNING,DEAD}
var state = states.SELECTED: set = set_state
var diff = Vector2()

func _ready() -> void:
	set_area_size()
	$body_animation.play("always")
	x_length = 0
	y_length = 0
	chunk_size = Vector2(chosen_grid_size[0],chosen_grid_size[1]) * Vector2(x_length,y_length)

func _process(_delta: float) -> void:
	
	if state == states.SELECTED:
		position = get_global_mouse_position() - diff
	
	elif state == states.MOVING:
		var dir = get_dir_to()
		velocity = speed * dir
		if (global_position - scan_pos).length() <= 3:
			
			velocity = Vector2()
			dir = Vector2()
			global_position = scan_pos
			state = states.SCANNING
			#start_scanning()
			
	move_and_collide(velocity)
		
func set_state(new_state):
	state = new_state
	if state == states.SCANNING:
		start_scanning()
	if state == states.IDLE:
		get_grid()
	if  state == states.SELECTED:
		$area.visible = true
	else:
		$area.visible = false
	
func send_diff(mouse_diff):
	diff = mouse_diff
func start_scanning():
	
	if MapManager.check_scan([scan_pos]):
		
		$AnimationPlayer.play("scanning")
		$AnimationPlayer.speed_scale = scan_speed
	else:
		state = states.IDLE
		#$Timer.wait_time = initial_scan_time - (initial_scan_time * (scan_speed - 1)/2.0)
		#$Timer.start()
	#if battery > 0 and going_home == false:
		#if scanning == false and initialized == true:
			#GameManager.get_tiles(self.get_path(),scan,'eye')
		#if moving == true:
			#var dir = get_dir_to()
			#velocity = speed * dir
			#
			#if (global_position - scan_pos).length() <= 1:
				#velocity = Vector2()
				#dir = Vector2()
				#global_position = scan_pos
				#start_scanning(1)
	


		
#func set_tiles(unclicked_tiles):
#
	#possible_tiles = unclicked_tiles
	#if len(possible_tiles) > 0:
		#
		#var rand_int = randi() % len(possible_tiles)
		#scan_pos = possible_tiles[rand_int]
		#initialized = true
		#moving = true
		#scanning = true
	#
	#else:
		#going_home = true
	
func get_dir_to():
		
	var dir = (scan_pos - global_position).normalized()
	
	return dir

#func start_scanning(instance):
	#GameManager.check_tile(scan_pos,self.get_path(),instance)


#func set_tile(can_scan):
	#
	#if can_scan == true:
		#
		#moving = false
		#$AnimationPlayer.play("scanning")
		#$AnimationPlayer.speed_scale = scan_speed
		#$Timer.wait_time = initial_scan_time - (initial_scan_time * (scan_speed - 1)/2.0)
		#$Timer.start()
	#else:
		#scanning = false
		#GameManager.get_tiles(self.get_path(),scan,'eye')

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	$AnimationPlayer.stop()
	scan_tile()
	
func scan_tile():
	var nearest_chunk = MapCalculator.get_nearest(scan_pos,'chunk')
	MapManager.change_mark_state(scan_pos,'flip')
	state = states.IDLE
	
	
#func initialize_values(eye_speed,scan_size,battery_size):
	#speed = 1.0/pow(0.8,eye_speed)
	#scan_speed = 1.0/pow(0.8,eye_speed)
	#battery = 1 + battery_size
	#var convert_scan_size = 6 * scan_size + 7
	#area_2_scan = get_grid(convert_scan_size)


func set_area_size():
	scan_area = 2 * GameManager.all_upgrade_data['eye_size']['current'] + 3#6 * GameManager.all_upgrade_data['eye_size']['current'] + 7
	update_area(scan_area)
	
func initialize_values():
	speed = 1.0/pow(0.8,GameManager.all_upgrade_data['eye_speed']['current'])
	scan_speed = 1.0/pow(0.8,GameManager.all_upgrade_data['eye_speed']['current'])
	get_grid()
	
	

func get_grid():
	
	var center_pos = home_pos
	var away_from_center = (scan_area - 1)/2.0
	var start = center_pos - Vector2(away_from_center,away_from_center) * 64
	scan = []
	var tile_pos
	for x in scan_area:
		for y in scan_area:
			tile_pos = start + Vector2(64,64) * Vector2(x,y)
			scan.append(tile_pos)
	
	var tiles = MapManager.check_scan(scan)
	find_scan_tile(tiles)

func find_scan_tile(tiles):
	
	
	if len(tiles) > 0:
		
		var rand_int = randi() % len(tiles)
		scan_pos = tiles[rand_int]
		state = states.MOVING
	else:
		queue_free()
	
	
	#GameManager.check_tiles(scan)
	
#func update_upgrade(upgrade,val):
	#
	#if upgrade == 'battery_size':
		#battery += val
	#if upgrade == 'scan_size':
		#var convert_scan_size = 6 * val + 7
		#area_2_scan = get_grid(convert_scan_size)
	#if upgrade == 'eye_speed':
		#speed *= (1.0/0.8)
		#scan_speed *= (1.0/0.8)
		
	


func _on_timer_timeout() -> void:

	$Timer.stop()	
	

func place(pos):
	home_pos = pos
	state = states.DEAD
	position = pos
	$body.offset = Vector2(32,32)
	$scanner.offset = Vector2(32,32)
	initialize_values()
	
	

func update_area(scan_scale):
	$area.scale = (Vector2(1,1) * scan_scale) * 2
	$area.visible = true

				

	
	
