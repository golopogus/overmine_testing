extends Sprite2D

var tile_size
var next_pts = []
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
	
var speed = 5
var dir = Vector2()

func _ready() -> void:
	position = get_global_mouse_position()
	Globals.get_init(self.get_path())
	get_rand_dir()
	
	

func set_init(size,pos):
	
	initial_pos = pos
	tile_size = size
	
func _process(_delta: float) -> void:
	
	velocity = speed * dir
	calculate_pts()
	
	#calculate_next_pts()
	
	next_leading_pt = current_pts[0] + velocity
	next_left_pt = current_pts[1] + velocity
	next_right_pt = current_pts[2] + velocity

	
	next_pts = [next_leading_pt,next_left_pt,next_right_pt]
	var next_tiles = []
	for pt in next_pts:
		next_tiles.append(get_nearest_tile(pt))
	
	
	for i in 3:
		if next_tiles[i] != current_tiles[i]:
			if flipped == false:
				current_pt = current_pts[i]
				current_tile = current_tiles[i]
				next_tile = next_tiles[i]

				Globals.get_tiles(self.get_path(),[next_tiles[i]],'ball')
		
		
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
		current_tiles = next_tiles
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
		Globals.click_tile(next_tile)
		flip()
		
	

func flip():
	flipped = true
	
	if get_nearest_tile(current_pt + Vector2(-velocity.x,velocity.y)) != next_tile:
		dir.x *= -1
	elif get_nearest_tile(current_pt + Vector2(velocity.x,-velocity.y)) != next_tile:
		dir.y *= -1
	else: 
		dir *= -1

	
func calculate_pts():
	current_tiles = []
	current_pts = []
	var angle = dir.angle()
	var pts_dict = {
		'pt1': position + radius * dir,
		'pt2': position + radius * Vector2(-dir.y,dir.x),
		'pt3': position + radius * Vector2(dir.y,-dir.x),
		'pt4': position + radius * Vector2.from_angle(angle + PI/4.0),
		'pt5': position + radius * Vector2.from_angle(angle - PI/4.0)
	}
	
	for pt in pts_dict:
		current_pts.append(pts_dict[pt])
		current_tiles.append(get_nearest_tile(pts_dict[pt]))

	
	
func get_rand_dir():
	var angle = deg_to_rad(randi_range(0,360))
	dir = (Vector2(1,1) * Vector2(cos(angle),sin(angle))).normalized()

func get_nearest_tile(pos):
	
	var nearest = floor(pos / tile_size) * tile_size + initial_pos
	
	return nearest
	

	
