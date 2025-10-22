extends Sprite2D

var click = false
var drone_speed
var scan_size
var battery_size
var charging_speed
var child

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
	drone.initialize_values(drone_speed,scan_size,battery_size)
	child = drone

func _on_timer_timeout() -> void:
	$Timer.stop()
	spawn_drone()

func get_initial_upgrades(upgrades):
	
	drone_speed = upgrades['drone_speed']['current']
	scan_size = upgrades['scan_size']['current']
	battery_size = upgrades['battery_plus']['current']
	charging_speed = upgrades['battery_speed']['current']
	
	
	update_charging_speed(charging_speed)
	
func update_upgrade(upgrade,val):
	if upgrade == 'charging_speed':
		update_charging_speed(val)
		
	elif get_child_count() > 1:
		print(get_children())
		child.update_upgrade(upgrade,val)
		store_drone_upgrade(upgrade,val)
	else:
		store_drone_upgrade(upgrade,val)
			
		
		
func store_drone_upgrade(upgrade,val):
	if upgrade == 'drone_speed':
		drone_speed = val
	if upgrade == 'scan_size':
		scan_size = val
	if upgrade == 'battery_plus':
		battery_size = val
	
func update_charging_speed(val):
	
	$Timer.wait_time = val + 1

	
		
	
