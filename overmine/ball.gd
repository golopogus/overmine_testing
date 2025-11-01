extends Sprite2D

var tile_size
var next_pts
var initial_pos
var current_pt
var next_tile
var current_tile
var radius
var current_pts
var velocity
var flipped = false
var current_tiles
var next_tiles
var speed = 4
var dir = Vector2()

func _ready() -> void:
	
	position = get_global_mouse_position()
	Globals.get_init(self.get_path())
	get_rand_dir()
	velocity = speed * dir
	calculate_pts()
	
func set_init(size,pos):
	
	initial_pos = pos
	tile_size = size
	radius = tile_size.x / 2.0
	
func _process(_delta: float) -> void:
	
	for i in len(current_pts):
		if next_tiles[i] != current_tiles[i]:
			
			if flipped == false:
				
				current_pt = current_pts[i]
				current_tile = current_tiles[i]
				next_tile = next_tiles[i]

				Globals.get_tiles(self.get_path(),[next_tiles[i]],'ball')
		
	velocity = speed * dir
	position += velocity
	calculate_pts()
	flipped = false
	

func set_tiles(tile):
	
	if tile['clicked'] == false:
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
	
	current_pts = []
	current_tiles = []
	next_pts = []
	next_tiles = []
	
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
		
		var next_pt = pts_dict[pt] + velocity
		
		next_pts.append(next_pt)
		next_tiles.append(get_nearest_tile(next_pt))
	
func get_rand_dir():
	
	var angle = deg_to_rad(randi_range(0,360))
	
	dir = (Vector2(1,1) * Vector2(cos(angle),sin(angle))).normalized()

func get_nearest_tile(pos):
	
	var nearest = floor(pos / tile_size) * tile_size + initial_pos
	
	return nearest
	

	
