extends Node2D

var click = false
var drone_speed
var scan_size
var battery_size
var child
var num_drones = 0
var charging_timer = 3
var first = true
var scan_scale = 1

func _process(_delta: float) -> void:

	if click == true:
		if get_child_count() > 1:
			for i in range(1,get_children().size()):
				get_child(i).queue_free()
		for i in $self/timers.get_children():
			i.queue_free()
		position = get_global_mouse_position() - Vector2(8,8)
	

func clicked():
	click = true
	update_area()

	
	
func place(pos):
	click = false
	position = pos
	if first == true:
		num_drones += 1
		first = false
	await get_tree().create_timer(.5).timeout
	for i in num_drones:
		spawn_drone()

func charging(node):
	get_node(node).queue_free()
	var timer = Timer.new()
	$self/timers.add_child(timer)
	timer.wait_time = charging_timer
	timer.one_shot = true
	timer.timeout.connect(timer_timeout.bind(timer.get_path()))
	timer.start()

func waiting(node):
	get_node(node).queue_free()
	for i in $self/timers.get_children():
		i.queue_free()
	

func timer_timeout(path):
	get_node(path).queue_free()
	spawn_drone()

func new_spawn():
	num_drones += 1
	spawn_drone()
	
func spawn_drone():
	
	var drone_load = preload("res://drone.tscn")
	var drone = drone_load.instantiate()
	add_child(drone)
	drone.initialize_values(drone_speed,scan_size,battery_size)
	#child = drone

func get_initial_upgrades(upgrades):
	
	drone_speed = upgrades['drone_speed']['current']
	scan_size = upgrades['scan_size']['current']
	battery_size = upgrades['battery_plus']['current']
	var charging_speed = upgrades['battery_speed']['current']
	
	update_charging_speed(charging_speed)
	update_scan_size(scan_size)
	
func update_upgrade(upgrade,val):
	if upgrade == 'battery_speed':
		update_charging_speed(val)

	elif get_child_count() > 1:
		for i in range(1,get_children().size()):
			get_child(i).update_upgrade(upgrade,val)
			store_drone_upgrade(upgrade,val)
	else:
		store_drone_upgrade(upgrade,val)
	
	if upgrade == 'scan_size':
		update_scan_size(val)
			
func store_drone_upgrade(upgrade,val):
	if upgrade == 'drone_speed':
		drone_speed = val
	if upgrade == 'scan_size':
		scan_size = val
	if upgrade == 'battery_plus':
		battery_size = val
	
func update_charging_speed(val):
	charging_timer = 3 - (.5 * val)

func update_scan_size(val):
	scan_scale = 6 * val + 7
	update_area()

func update_area():
	$self/base_sprite/area.scale = Vector2(1,1) * scan_scale
	$self/base_sprite/area.visible = true
	


	
		
	
