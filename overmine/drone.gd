extends CharacterBody2D

var moving = false
var scanning = false
var scannable_chunk
var x_length
var y_length
var chunk_size
const grid_size_options = [[20,20],[50,50],[4,4]]
var chosen_grid_size = grid_size_options[0]
var scanning_tile = Vector2()
var possible_tiles = []
var scan_speed = 1
var checked_tiles = []
var initial_scan_time = 4.8
var scan_pos
var speed
var scan = []
var area_2_scan
var tile_info
var search_area = []
var battery
var going_home = false
var g_pos = Vector2()
var is_tiles = true
var initialized = false

func _ready() -> void:
	
	$body_animation.play("always")
	x_length = 16
	y_length = 16
	chunk_size = Vector2(chosen_grid_size[0],chosen_grid_size[1]) * Vector2(x_length,y_length)

func _process(_delta: float) -> void:
	
	if battery > 0 and going_home == false:
		if scanning == false and initialized == true:
			Globals.get_tiles(self.get_path(),scan,'drone')
		if moving == true:
			var dir = get_dir_to()
			velocity = speed * dir
			
			if (global_position - scan_pos).length() <= 1:
				velocity = Vector2()
				dir = Vector2()
				global_position = scan_pos
				start_scanning(1)
	
	elif battery == 0:
		return_to_base('battery')
	
	elif going_home == true:
		return_to_base('no_tiles')

	move_and_collide(velocity)
		
func set_tiles(unclicked_tiles):

	possible_tiles = unclicked_tiles
	if len(possible_tiles) > 0:
		
		var rand_int = randi() % len(possible_tiles)
		scan_pos = possible_tiles[rand_int]
		initialized = true
		moving = true
		scanning = true
	
	else:
		going_home = true
	
func get_dir_to():
		
	var dir = (scan_pos - global_position).normalized()
	
	return dir

func start_scanning(instance):
	Globals.check_tile(scan_pos,self.get_path(),instance)


func set_tile(can_scan):
	
	if can_scan == true:
		
		moving = false
		$AnimationPlayer.play("scanning")
		$AnimationPlayer.speed_scale = scan_speed
		$Timer.wait_time = initial_scan_time - (initial_scan_time * (scan_speed - 1)/2.0)
		$Timer.start()
	else:
		scanning = false
		Globals.get_tiles(self.get_path(),scan,'drone')

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	$AnimationPlayer.stop()
	scanning = false
	battery -= 1
	
	
func initialize_values(drone_speed,scan_size,battery_size):
	speed = 1.0/pow(0.8,drone_speed)
	scan_speed = 1.0/pow(0.8,drone_speed)
	battery = 1 + battery_size
	var convert_scan_size = 6 * scan_size + 7
	area_2_scan = get_grid(convert_scan_size)
	

func get_grid(scan_area):
	
	var center_pos = get_parent().position
	var away_from_center = (scan_area - 1)/2.0
	var start = center_pos - Vector2(away_from_center,away_from_center) * 32
	scan = []
	var tile_pos
	for x in scan_area:
		for y in scan_area:
			tile_pos = start + Vector2(32,32) * Vector2(x,y)
			scan.append(tile_pos)
	
	Globals.get_tiles(self.get_path(),scan,'drone')
	
func update_upgrade(upgrade,val):
	
	if upgrade == 'battery_size':
		battery += val
	if upgrade == 'scan_size':
		var convert_scan_size = 6 * val + 7
		area_2_scan = get_grid(convert_scan_size)
	if upgrade == 'drone_speed':
		speed *= (1.0/0.8)
		scan_speed *= (1.0/0.8)
		
	


func _on_timer_timeout() -> void:
	start_scanning(2)

	$Timer.stop()	
	
func return_to_base(reason):
		
		var dir = (get_parent().position - global_position).normalized()
		
		velocity = speed * dir 
		
		if (global_position - get_parent().position).length() <= 1:
			
			if reason == 'battery':
				get_parent().charging(self.get_path())
			elif reason == 'no_tiles':
				get_parent().waiting(self.get_path())

				

	
	
