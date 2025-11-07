extends ColorRect

#signal update_upgrades(upgrade_data)

#var upgrade_data
var list_of_upgrades

var max_mine_radius
var current_mine_radius

var max_drone_add
var current_drone_add

var max_drill_add
var current_drill_add


func _ready() -> void:
	list_of_upgrades = Globals.all_upgrade_data
	initialize_upgrade_tree()
	
func _on_close_pressed() -> void:
	#queue_free()
	visible = false

#func get_upgrade_list(list):
#
	#initialize_upgrade_tree()
	
func initialize_upgrade_tree():
	for i in list_of_upgrades:
		update_text(i)
		
func update_text(upgrade):
	var current_value = list_of_upgrades[upgrade]['current']
	var max_value = list_of_upgrades[upgrade]['max']
	var i_name = list_of_upgrades[upgrade]['name']
	var node_path = upgrade + '/text'
	get_node(node_path).text = i_name + ' (' + str(current_value) + '/' + str(max_value) +')'

	
func send_signal(upgrade_data):
	
	var current_upgrade = list_of_upgrades[upgrade_data]['current']
	var max_upgrade = list_of_upgrades[upgrade_data]['max']
	

	if current_upgrade < max_upgrade:
		current_upgrade += 1
		Globals.handle_upgrades(upgrade_data)
		#emit_signal("update_upgrades",upgrade_data)
		update_text(upgrade_data)
## MINE 



func _on_mine_radius_pressed() -> void:
	send_signal('mine_radius')

## DRONE 

func _on_drone_speed_pressed() -> void:
	#send_signal('drone_speed')
	pass

func _on_drone_add_pressed() -> void:
	#send_signal('drone_add')
	pass

func _on_scan_size_pressed() -> void:
	#send_signal('scan_size')
	pass

## DRILL 
func _on_drill_add_pressed() -> void:
	#send_signal('drill_add')
	pass

func _on_drill_dur_pressed() -> void:
	pass

func _on_drill_speed_pressed() -> void:
	pass

func _on_drill_size_pressed() -> void:
	pass

## DRONE BATTERY 
func _on_battery_speed_pressed() -> void:
	#send_signal('battery_speed')
	pass
	
func _on_battery_plus_pressed() -> void:
	#send_signal('battery_plus')
	pass

## MARK
func _on_call_it_in_pressed() -> void:
	pass

func _on_mark_pressed() -> void:
	pass

## HEART
func _on_steel_heart_pressed() -> void:
	pass

func _on_click_multi_pressed() -> void:
	#send_signal('click_multi')
	pass
