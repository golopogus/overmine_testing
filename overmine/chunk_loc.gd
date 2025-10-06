extends Node2D




func _on_area_2d_mouse_entered() -> void:
	get_parent().get_parent().draw_chunk(position)
