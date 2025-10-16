extends Sprite2D

var drilling = false

var speed = 0

var dir = Vector2.LEFT
var next_pos = Vector2()
var reade = false
var click = false
func _process(_delta: float) -> void:

	if position == next_pos and reade == true:
		drill_block(position)
	if click == false:
		if drilling == false:
			speed = 1
		
		position.x += speed * dir.x
		position.y += speed * dir.y

	if click == true:
		position = get_global_mouse_position()
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
		
	
func drill_block(pos):
	next_pos = pos + dir * 16
	#print(get_parent().check_clicked(pos,'DRILL'))
	if get_parent().check_clicked(next_pos,'DRILL') == false:
		print('yay')
		drilling = true
		reade = false
		speed = 0
		position = pos
		await get_parent().clicked(next_pos - Vector2(8,8))
		#if get_parent().check_clicked(next_pos,'WHAT') == 'mine':
			#queue_free()
		#else:
			#$Timer.start()
		$Timer.start()

	
		

func clicked():
	click = true
	
func place(pos):
	click = false
	position = pos + Vector2(8,8)
	next_pos = position + dir * 16
	if get_parent().check_clicked(next_pos,'DRILL') == false:
		drill_block(position)
	
	reade = true


func _on_timer_timeout() -> void:
	drilling = false
	reade = true
