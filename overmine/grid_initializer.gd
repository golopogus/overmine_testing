extends Node2D

const grid_size_options = [[8,8]]
var chosen_grid_size = grid_size_options[0]
var tile = prelo
func _ready() -> void:
	spawn_tiles(chosen_grid_size)
	
func spawn_tiles(grid_size):
	
	#first need to calculate positions for each tile
	var x_length = $sprites/hidden_tile.texture.get_width()
	var y_length = $sprites/hidden_tile.texture.get_height() 
	var midpoint = Vector2(x_length,y_length)
	
	
