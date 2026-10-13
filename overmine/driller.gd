extends Sprite2D

var drilling = false

var speed = 0
var move_speed = 0

var dir = Vector2.LEFT
var next_pos = Vector2()
var reade = false
var click = false
var health = 1
var first_check
enum tile_types {UNKNOWN,SAFE,WARNING,MINE}
enum states {SELECTED,CHECKING,MOVING,ATTACKING,DEAD}
var state = states.SELECTED: set = set_state
enum mark_states {UNMARKED,MARKED,SELECTED,USED}

func _ready() -> void:
	initialize_stats()
func initialize_stats():
	move_speed = GameManager.all_upgrade_data['driller_speed']['current'] + 1
	health = GameManager.all_upgrade_data['driller_dur']['current'] + 1
	
func _process(_delta: float) -> void:
	
	if state == states.SELECTED:
		position = get_global_mouse_position() - Vector2(16,16)
		if Input.is_action_just_pressed("rotate"):
			rotation_degrees += 90
			if dir == Vector2.LEFT:
				dir = Vector2.UP
			elif dir == Vector2.UP:
				dir = Vector2.RIGHT
			elif dir == Vector2.RIGHT:
				dir = Vector2.DOWN
			elif dir == Vector2.DOWN:
				dir = Vector2.LEFT
		
	elif state == states.MOVING:
		speed = move_speed
		position.x += speed * dir.x
		position.y += speed * dir.y
	
	if position == next_pos:
		state = states.CHECKING
		

func check_block():
	next_pos = position + dir * 32
	if MapManager.tile_dict[next_pos]['clicked'] == false:
		state = states.ATTACKING
		speed = 0
		var nearest_chunk = MapCalculator.get_nearest(next_pos,'chunk')
		MapManager.clicked(next_pos,nearest_chunk)
		if MapManager.tile_dict[next_pos]['type'] == tile_types.MINE:
			health -= 1
			if health == 0:
				queue_free()
		$Timer.start()
	else:
		state = states.MOVING
	
func set_state(new_state):
	state = new_state
	if state == states.CHECKING:
		check_block()
	
func place(pos):
	
	state = states.MOVING
	position = pos
	check_block()
	



func _on_timer_timeout() -> void:
	state = states.MOVING
