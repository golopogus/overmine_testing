extends Sprite2D

var click = false

func _process(_delta: float) -> void:

	if click == true:
		position = get_global_mouse_position()
		
func clicked():
	click = true
	
func place(pos):
	click = false
	position = pos
	spawn_drone()


func charging():
	get_child(1).queue_free()
	$Timer.start()
	
func spawn_drone():
	var drone_load = preload("res://drone.tscn")
	var drone = drone_load.instantiate()
	add_child(drone)

func _on_timer_timeout() -> void:
	$Timer.stop()
	spawn_drone()
