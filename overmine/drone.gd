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
var poss_tiles = []
var checked_tiles = []
var scan_pos
var speed = 1
var tile_info
func _ready() -> void:
	
	$body_animation.play("always")
	x_length = 16
	y_length = 16
	chunk_size = Vector2(chosen_grid_size[0],chosen_grid_size[1]) * Vector2(x_length,y_length)
	

func _process(_delta: float) -> void:
	
	if scanning == false:
		get_scan_loc()
	
	if moving == true:
		var dir = get_dir_to()
		velocity = speed * dir
		
		if (position - scan_pos).length() <= 1:
			velocity = Vector2()
			dir = Vector2()
			position = scan_pos
			#print(position, scan_pos)
			start_scanning()
		
		
	
	move_and_collide(velocity)
		
	

func get_scan_loc():
	
	
	var tiles = get_parent().get_parent().send_dicts()
	#print(tiles)
	for i in tiles:
		if get_parent().get_parent().check_clicked(i,'CLICKED') == false:
			poss_tiles.append(i)
	
	var rand_int = randi() % len(poss_tiles)
	scan_pos = poss_tiles[rand_int] + Vector2(8,8)
	moving = true
	scanning = true
	#est_scan_pos.x = randi_range(scannable_chunk.x,scannable_chunk.x + chunk_size - x_length)
	#est_scan_pos.y = randi_range(scannable_chunk.y,scannable_chunk.y + chunk_size - y_length)
	
func get_dir_to():
		
	var dir = (scan_pos - position).normalized()
	
	return dir

func start_scanning():
	moving = false
	$AnimationPlayer.play("scanning")
	$Timer.start()
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimationPlayer.stop()
	scanning = false
	
	
	
	
	#scanning = false
	


func _on_timer_timeout() -> void:
	get_parent().get_parent().check_clicked(scan_pos - Vector2(8,8),'TYPE')
	$Timer.stop()	
		
	
