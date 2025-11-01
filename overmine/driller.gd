extends Sprite2D

var drilling = false

var speed = 0

var dir = Vector2.LEFT
var next_pos = Vector2()
var reade = false
var click = false
var health = 3
var first_check
func _process(_delta: float) -> void:

	if position == next_pos and reade == true:
		drill_block()
	if click == false:
		if drilling == false:
			speed = 1
		
		position.x += speed * dir.x
		position.y += speed * dir.y

	if click == true:
		position = get_global_mouse_position() - Vector2(8,8)
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
		
func set_tiles(pos_dict):
	print(pos_dict)
	if pos_dict['clicked'] == false:
		drilling = true
		reade = false
		speed = 0
		await Globals.click_tile(next_pos)
		if pos_dict['type'] == 'mine':
			health -= 1
			if health == 0:
				queue_free()
		$Timer.start()
		
func drill_block():
	next_pos = position + dir * 32
	Globals.get_tiles(self.get_path(),[next_pos],'drill')

func clicked():
	click = true
	
func place(pos):
	click = false
	position = pos
	drill_block()
	reade = true


func _on_timer_timeout() -> void:
	drilling = false
	reade = true
