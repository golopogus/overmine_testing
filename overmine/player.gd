extends Area2D

var speed = 2
var current_tile_pos = Vector2()
var x_length = 64
var y_length = 64
var bounds = Rect2(Vector2(),Vector2())
	
func _process(delta: float) -> void:
	
	var x_value = Input.get_axis('move_left','move_right')
	var y_value = Input.get_axis('move_up','move_down')
	
	var velocity = Vector2(x_value,y_value).normalized() * speed
	
	var new_possible_pos = position + velocity
	
	if velocity != Vector2():
		if bounds.abs().has_point(new_possible_pos):
		
			position += velocity
		else:
			find_next_tile(new_possible_pos)

	
func find_next_tile(pos):
	var next_tile = MapCalculator.get_nearest(pos,'tile')
	
	if MapManager.tile_dict[next_tile]['clicked'] == true:
		
		var initial_pos = next_tile
		var size = Vector2(x_length,y_length)
		bounds = Rect2(initial_pos,size)
		get_parent().draw_recti(bounds)
		position = pos
	
	
