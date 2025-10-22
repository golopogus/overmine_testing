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
var checked_tiles = []
var scan_pos
var speed
var tile_info
var search_area = []
var battery
var g_pos = Vector2()
var is_tiles = true
#signal send_node_info(path)

func _ready() -> void:
	
	#Globals.send_drone_signal(self.get_path())
	$body_animation.play("always")
	x_length = 16
	y_length = 16
	chunk_size = Vector2(chosen_grid_size[0],chosen_grid_size[1]) * Vector2(x_length,y_length)
	check_possible_tiles()

func _process(_delta: float) -> void:
	
	if battery > 0:
		if scanning == false:
			#get_scan_loc()
			Globals.get_possible_tiles(self.get_path())
		if moving == true:
			var dir = get_dir_to()
			velocity = speed * dir
			
			if (global_position - scan_pos).length() <= 1:
				velocity = Vector2()
				dir = Vector2()
				global_position = scan_pos
				#print(position, scan_pos)
				start_scanning(1)
	
	else:
		return_to_charge()
		#var dir = (get_parent().position - global_position).normalized()
		#velocity = speed * dir 
		#
		#if (global_position - get_parent().position).length() <= 1:
			#get_parent().charging()
		
		
		
	
	move_and_collide(velocity)
		
func set_unclicked_tiles(unclicked_tiles):
	
	possible_tiles = unclicked_tiles
	if len(possible_tiles) > 0:
		
		var rand_int = randi() % len(possible_tiles)
		scan_pos = possible_tiles[rand_int] + Vector2(8,8)
		moving = true
		scanning = true

#func get_scan_loc(tiles):
	#
	###FIX DROONES TO UPDATE WHEN LEAVING CHUNK
	#
	#
	#for i in tiles:
		#if get_parent().get_parent().get_parent().check_clicked(i,'CLICKED') == false:
			#poss_tiles.append(i)
	#
	#if len(poss_tiles) > 0:
		#
		#var rand_int = randi() % len(poss_tiles)
		#scan_pos = poss_tiles[rand_int] + Vector2(8,8)
		#moving = true
		#scanning = true
	#
	#else:
		#pass
		
func get_dir_to():
		
	var dir = (scan_pos - global_position).normalized()
	
	return dir

func start_scanning(instance):
	Globals.check_tile(scan_pos-Vector2(8,8),self.get_path(),instance)


func set_tile(can_scan):
	if can_scan == true:
		moving = false
		$AnimationPlayer.play("scanning")
		$Timer.start()
	else:
		scanning = false

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	$AnimationPlayer.stop()
	scanning = false
	battery -= 1
	
	
func initialize_values(drone_speed,scan_size,battery_size):
	speed = 1 + drone_speed * .333
	battery = 1 + battery_size
	
func update_upgrade(upgrade,val):
	
	if upgrade == 'battery_size':
		battery += val
	if upgrade == 'scan_size':
		pass
	if upgrade == 'drone_speed':
		speed += val * .333
	


func _on_timer_timeout() -> void:
	#get_parent().get_parent().get_parent().check_clicked(scan_pos - Vector2(8,8),'TYPE')
	start_scanning(2)

	$Timer.stop()	
	
func return_to_charge():
		var dir = (get_parent().position - global_position).normalized()
		velocity = speed * dir 
		
		if (global_position - get_parent().position).length() <= 1:
			get_parent().charging()

func check_possible_tiles():
	pass
	
	
