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
	if Globals.book_ban == false:
		toggle_spells()

func toggle_spells():
	$timer_buy.visible = true
	$ball_buy.visible = true
	$drill_buy.visible = true
	$drone_buy.visible = true
	$bomber_buy.visible = true
	
	for i in Globals.spell_book:
		if Globals.spell_book['drone']['owned'] == 1:
			$drone_add.visible = true
			$drone_speed.visible = true
			$scan_size.visible = true
		
		if Globals.spell_book['driller']['owned'] == 1:
			$drill_dur.visible = true
			$drill_size.visible = true
			$drill_speed.visible = true
			
		if Globals.spell_book['timer']['owned'] == 1:
			$timer_add_time.visible = true
			
		if Globals.spell_book['ball']['owned'] == 1:
			$ball_health.visible = true
			$ball_speed.visible = true
			$ball_split.visible = true
			
		if Globals.spell_book['bomber']['owned'] == 1:
			$bomber_capacity.visible = true
			$bomber_radius.visible = true		
			
	
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
		
func _on_timer_buy_pressed() -> void:
	#Globals.spell_book['timer']['owned'] = 1
	pass

func _on_ball_buy_pressed() -> void:
	Globals.spell_book['ball']['owned'] = 1
	$ball_buy/Label.text = 'bought'

func _on_drill_buy_pressed() -> void:
	Globals.spell_book['driller']['owned'] = 1
	$drill_buy/Label.text = 'bought'

func _on_drone_buy_pressed() -> void:
	Globals.spell_book['drone']['owned'] = 1
	$drone_buy/Label.text = 'bought'

func _on_bomber_buy_pressed() -> void:
	#Globals.spell_book['bomber']['owned'] = 1
	pass
	
## MINE 
func _on_mine_radius_pressed() -> void:
	send_signal('mine_radius')

## DRONE 
func _on_drone_speed_pressed() -> void:
	send_signal('drone_speed')
	

func _on_drone_add_pressed() -> void:
	send_signal('drone_add')
	

func _on_scan_size_pressed() -> void:
	send_signal('scan_size')
	

## DRILL 
func _on_drill_dur_pressed() -> void:
	send_signal('drill_dur')

func _on_drill_speed_pressed() -> void:
	send_signal('drill_speed')

func _on_drill_size_pressed() -> void:
	pass

## HEART
func _on_steel_heart_pressed() -> void:
	pass

## TIMER
func _on_timer_more_pressed() -> void:
	pass # Replace with function body.
	
func _on_timer_add_pressed() -> void:
	pass # Replace with function body.

## BALL
func _on_ball_speed_pressed() -> void:
	send_signal('ball_speed')

func _on_ball_health_pressed() -> void:
	send_signal('ball_health')

func _on_ball_split_pressed() -> void:
	pass # Replace with function body.
	
#BOMBER
func _on_bomber_radius_pressed() -> void:
	pass # Replace with function body.

func _on_bomber_add_pressed() -> void:
	pass # Replace with function body.











## FOR LATER IF I CHOOSE SO
func _on_click_multi_pressed() -> void:
	#send_signal('click_multi')
	pass
func _on_call_it_in_pressed() -> void:
	pass
func _on_mark_pressed() -> void:
	pass

func _on_battery_speed_pressed() -> void:
	#send_signal('battery_speed')
	pass
func _on_battery_plus_pressed() -> void:
	#send_signal('battery_plus')
	pass
func _on_drill_add_pressed() -> void:
	#send_signal('drill_add')
	pass
