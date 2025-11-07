extends Node2D

signal drone_ready
signal drill_ready
signal ready_to_click
signal drone_ready_for_check
signal ball_ready
signal ball_pls
signal timer_for_border
signal shape_guess
var all_upgrade_data

func _ready() -> void:
	initialize_upgrade_data()

func get_tiles(data,grid,type):
	if type == 'drone':
		emit_signal("drone_ready",data,grid,type)
	elif type == 'drill':
		emit_signal("drill_ready",data,grid,type)
	elif type == "ball":
		emit_signal("ball_pls",data,grid,type)

func check_tile(pos,path,instance):
	emit_signal("drone_ready_for_check",pos,path,instance)
	
func get_init(path):
		emit_signal("ball_ready",path)

func click_tile(pos):
	emit_signal('ready_to_click',pos)

func get_timer(path):
	emit_signal('timer_for_border',path)

func send_shape(shape):
	emit_signal('shape_guess',shape)
	
func handle_upgrades(upgrade_data):
	
	all_upgrade_data[upgrade_data]['current'] += 1
	
	#if upgrade_data == 'drone_add':
		#Globals.connect("drone_ready", send_tiles)
		#Globals.connect("drone_ready_for_check",check_tile_for_drone)
	#
	#if upgrade_data == 'drill_add':
		#Globals.connect("drill_ready", send_tiles)
		
	#
	#if all_upgrade_data[upgrade_data]['owner'] == 'drone':
		#for drone_base in $drones.get_children():
			#drone_base.update_upgrade(upgrade_data, all_upgrade_data[upgrade_data]['current'])
	#

func get_upgrade_data(upgrade):
	
	return all_upgrade_data[upgrade]['current']
	
func initialize_upgrade_data():
	
	#MINE_DATA
	all_upgrade_data = {
		'mine_radius': {
			'name': 'Mine Radius',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'mine'
		},
	
	#DRONE_DATA
		'drone_speed': {
			'name': 'Drone Speed',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drone'
		},
		'scan_size': {
			'name': 'Scanner Size',
			'description': '',
			'current': 0,
			'max': 10,
			'cost': 10,
			'owner': 'drone'
		},
		'drone_add': {
			'name': 'Add Drone',
			'description': '',
			'current': 0,
			'max': 1,
			'cost': 10,
			'owner': 'none'
		},
		'battery_speed': {
			'name': 'Battery Recharge Speed',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drone'
		},
		'battery_plus': {
			'name': 'Battery Size',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drone'
		},
	
	#DRILL_DATA
		'drill_size': {
			'name': 'Drill Size',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drill'
		},
		'drill_speed': {
			'name': 'Drill Speed',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drill'
		},
		'drill_dur': {
			'name': 'Drill Durability',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'drill'
		},
		'drill_add': {
			'name': 'Add Drill',
			'description': '',
			'current': 0,
			'max': 1,
			'cost': 10,
			'owner': 'none'
		},
	
	#CLICK_DATA

		'click_multi': {
			'name': 'Click Multiplier',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'none'
		},
		
	# MARK DATA
		'mark': {
			'name': 'Mark',
			'description': '',
			'current': 0,
			'max': 1,
			'cost': 10,
			'owner': 'none'
		},
		'call_it_in': {
			'name': 'Call It In',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'none'
			
		},
	#HEART DATA
		'steel_heart': {
			'name': 'Steel Heart',
			'description': '',
			'current': 0,
			'max': 1,
			'cost': 10,
			'owner': 'none'
		}
	} 
	

	
