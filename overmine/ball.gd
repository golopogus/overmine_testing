extends Sprite2D

var tile_size
var next_pts

var current_pt
var next_tile
var current_tile
var radius
var health = 1
var current_pts
var velocity
var flipped = false
var current_tiles
var next_tiles
var speed = 1
var click = false
var dir = Vector2()
enum tile_types {UNKNOWN,SAFE,WARNING,MINE}
enum states {SELECTED,IDLE,MOVING,ATTACKING,DEAD}
var state = states.SELECTED: set = set_state
enum mark_states {UNMARKED,MARKED,SELECTED,USED}
var num_split


func _ready() -> void:
	
	initialize_stats()
	position = get_global_mouse_position()

func initialize_stats():
	
	
	
	speed = GameManager.all_upgrade_data['roller_speed']['current'] + 1
	health = GameManager.all_upgrade_data['roller_health']['current'] + 1
	num_split = GameManager.all_upgrade_data['roller_split']['current'] + 1
	tile_size = Vector2(MapManager.x_length,MapManager.y_length)
	radius = tile_size.x / 2.0
	
func _process(delta: float) -> void:
	
	if state == states.SELECTED:
		position = get_global_mouse_position()
	elif state == states.MOVING:
		rotation_degrees += 1000 * delta
		for i in len(current_pts):
			if next_tiles[i] != current_tiles[i]:
				
				if flipped == false:
					
					current_pt = current_pts[i]
					current_tile = current_tiles[i]
					next_tile = next_tiles[i]
					
					set_tiles(MapManager.tile_dict[next_tile])
			
		velocity = speed * dir
		position += velocity
		calculate_pts()
		flipped = false
		
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
		current_tiles.append(MapCalculator.get_nearest(pts_dict[pt],'tile'))
		
		var next_pt = pts_dict[pt] + velocity
		next_pts.append(next_pt)
		next_tiles.append(MapCalculator.get_nearest(next_pt,'tile'))
		
func set_tiles(tile):

	if tile['clicked'] == false:
		if tile['type'] == tile_types.MINE and tile['mark_state'] == mark_states.UNMARKED:
			health -= 1
		if tile['mark_state'] == mark_states.UNMARKED:
			var nearest_chunk = MapCalculator.get_nearest(next_tile,'chunk')
			MapManager.clicked(next_tile,nearest_chunk)

		flip()
		
	if health == 0:
		split()
		queue_free()

func place(pos):
	
	get_rand_dir()
	velocity = speed * dir
	calculate_pts()
	position = pos
	state = states.MOVING
	
func set_state(new_state):
	state = new_state	

func flip():
	
	flipped = true
	if MapCalculator.get_nearest(current_pt + Vector2(-velocity.x,velocity.y),'tile') != next_tile:
		dir.x *= -1
	elif MapCalculator.get_nearest(current_pt + Vector2(velocity.x,-velocity.y),'tile') != next_tile:
		dir.y *= -1
	else: 
		dir *= -1

func get_rand_dir():
	
	var angle = deg_to_rad(randi_range(0,360))
	dir = (Vector2(1,1) * Vector2(cos(angle),sin(angle))).normalized()

func split():
	
	get_parent().spawn_balls(num_split,position)
	
	



	

	
