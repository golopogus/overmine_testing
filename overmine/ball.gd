extends Sprite2D

var tile_size
var initial_pos
var current_pt
var next_leading_pt
var next_left_pt
var next_right_pt
var leading_tile
var left_tile
var right_tile
var next_tile
var current_tile
var radius = 8
var leading_pt
var left_pt
var current_pts = []
var velocity = 0
var right_pt 
var flipped = false
var current_tiles = []
#		'tile':nearest = floor(pos / Vector2(x_length,y_length)) * Vector2(x_length,y_length) + initial_pos
	
var speed = 1
var dir = Vector2()

func _ready() -> void:
	position = get_global_mouse_position()
	Globals.get_init(self.get_path())
	get_rand_dir()
	leading_pt = position + radius * dir 
	left_pt = position + Vector2(dir.y,-dir.x) * radius
	right_pt = position + Vector2(-dir.y,dir.x) * radius
	current_pts.append(leading_pt)
	current_pts.append(left_pt)
	current_pts.append(right_pt)
	leading_tile = get_nearest_tile(leading_pt)
	left_tile = get_nearest_tile(left_pt)
	right_tile = get_nearest_tile(right_pt)
	current_tile = get_nearest_tile(position)
	current_tiles.append(leading_tile)
	current_tiles.append(left_tile)
	current_tiles.append(right_tile)
	

func set_init(size,pos):
	
	initial_pos = pos
	tile_size = size
	
func _process(_delta: float) -> void:
	
	velocity = speed * dir
	leading_pt = position + radius * dir 
	left_pt = position + Vector2(dir.y,-dir.x) * radius
	right_pt = position + Vector2(-dir.y,dir.x) * radius
	current_pts.append(leading_pt)
	current_pts.append(left_pt)
	current_pts.append(right_pt)
	
	leading_tile = get_nearest_tile(leading_pt)
	left_tile = get_nearest_tile(left_pt)
	right_tile = get_nearest_tile(right_pt)
	current_tiles.append(leading_tile)
	current_tiles.append(left_tile)
	current_tiles.append(right_tile)
	
	next_leading_pt = leading_pt + velocity
	next_left_pt = left_pt + velocity
	next_right_pt = right_pt + velocity

	
	var next_pts = [next_leading_pt,next_left_pt,next_right_pt]
	var next_tiles = []
	for pt in next_pts:
		next_tiles.append(get_nearest_tile(pt))
	
	
	for i in 3:
		if next_tiles[i] != current_tiles[i]:
			if flipped == false:
				current_pt = current_pts[i]
				current_tile = current_tiles[i]
				next_tile = next_tiles[i]
				Globals.get_tiles(self.get_path(),[nearest_tiles[i]],'ball')
		
		
	#for pt in next_pts:
		#var nearest = get_nearest_tile(pt)
		#for j in current_tiles:
			#if j != i:
				#if flipped == false:
					#current_tile = j
					#next_tile = i
					#Globals.get_tiles(self.get_path(),[i],'ball')
				

	
	#if flipped == true:
		#print(dir)
	velocity = speed * dir
	position += velocity
	if flipped == false:
		current_tiles = nearest_tiles
	elif flipped == true:
		current_tiles = []
		leading_pt = position + radius * dir 
		left_pt = position + Vector2(dir.y,-dir.x) * radius
		right_pt = position + Vector2(-dir.y,dir.x) * radius

		leading_tile = get_nearest_tile(leading_pt)
		left_tile = get_nearest_tile(left_pt)
		right_tile = get_nearest_tile(right_pt)
		current_tiles.append(leading_tile)
		current_tiles.append(left_tile)
		current_tiles.append(right_tile)
	flipped = false
		
	#current_tile = get_nearest_tile(position)
	

func set_tiles(tile):
	
	if tile['clicked'] == true:
		pass
	else:
		print("before flip: ", dir)
		flip()
		print("after flip: ", dir)
		
	

func flip():
	flipped = true
	
	if 
		print('sure')
	else:
		print('wrong')
	#elif get_nearest_tile(current_pt + Vector2(velocity.x,-velocity.y)) != next_tile:
		#dir.y *= -1
	
	#var tile_dir = next_tile - current_tile
	#
	#if tile_dir.x == 0:
	#
		#dir.y *= -1
	#elif tile_dir.y == 0: 
		#dir.x *= -1
	#
	#else:
		#tile_dir = next_tile + Vector2(8,8) - position
		#if abs(tile_dir.x) < abs(tile_dir.y):
			#dir.y *= -1
			#
		#else:
			#dir.x *= -1
			
		
	
	
	#else:
		#dir *= -1
	
	
	
	
func get_rand_dir():
	var angle = deg_to_rad(randi_range(0,360))
	dir = (Vector2(1,1) * Vector2(cos(angle),sin(angle))).normalized()

func get_nearest_tile(pos):
	
	var nearest = floor(pos / tile_size) * tile_size + initial_pos
	
	return nearest
	

	
