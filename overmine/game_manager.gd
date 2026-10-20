extends Node2D

signal eye_ready
signal drill_ready
signal ready_to_click
signal eye_ready_for_check
signal timer_for_border
signal shape_guess
var all_upgrade_data
var spell_book
var shape_dict
var banned_from_summons = false
var book_collected = false
var custom_time = 0.0
var game_started = false


func _ready() -> void:
	initialize_upgrade_data()
	initialize_spell_book_data()
	initialize_shape_dict()
	
func _process(delta: float) -> void:
	custom_time += delta
	
func get_tiles(data,grid,type):
	if type == 'eye':
		emit_signal("eye_ready",data,grid,type)
	elif type == 'drill':
		emit_signal("drill_ready",data,grid,type)


func check_tile(pos,path,instance):
	emit_signal("eye_ready_for_check",pos,path,instance)

func click_tile(pos):
	emit_signal('ready_to_click',pos)

#func get_timer(path):
	#emit_signal('timer_for_border',path)

func send_shape(shape):
	for i in spell_book:
		if spell_book[i]['shape'] == shape and spell_book[i]['owned'] == 1:
			emit_signal('shape_guess',shape)
	
func handle_upgrades(upgrade_data):
	
	all_upgrade_data[upgrade_data]['current'] += 1
	
func collect_book():
	book_collected = true
	

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
	
	#CIRCLE
		'roller_health': {
			'name': 'Roller Health',
			'description': '',
			'current': 2,
			'max': 3,
			'cost': 10,
			'owner': 'roller'
		},
		'roller_speed': {
			'name': 'Roller Speed',
			'description': '',
			'current': 1,
			'max': 3,
			'cost': 10,
			'owner': 'roller'
		},
		'roller_split': {
			'name': 'Roller Split',
			'description': '',
			'current': 3,
			'max': 3,
			'cost': 10,
			'owner': 'roller'
		},
		'roller_split_health': {
			'name': 'Roller Split Health',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'roller'
		},
	#homing_DATA
		'homing_capacity': {
			'name': 'Homing Capacity',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'homing'
		},
		'homing_radius': {
			'name': 'Homing Radius',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'homing'
		},
	
	#TIMER_DATA
		'timer_add_time': {
			'name': 'Add Time',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'timer'
		},
	#eye_DATA
		'eye_speed': {
			'name': 'Eye Speed',
			'description': '',
			'current': 5,
			'max': 3,
			'cost': 10,
			'owner': 'eye'
		},
		'eye_size': {
			'name': 'Eye Size',
			'description': '',
			'current': 1.0,
			'max': 10,
			'cost': 10,
			'owner': 'eye'
		},
		'eye_add': {
			'name': 'Add Eye',
			'description': '',
			'current': 0,
			'max': 15,
			'cost': 10,
			'owner': 'none'
		},
	
	#DRILL_DATA
		'driller_size': {
			'name': 'Driller Size',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'driller'
		},
		'driller_speed': {
			'name': 'Driller Speed',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'driller'
		},
		'driller_dur': {
			'name': 'Driller Durability',
			'description': '',
			'current': 0,
			'max': 3,
			'cost': 10,
			'owner': 'driller'
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
	

	

func initialize_spell_book_data():
	spell_book = {
	'eye': {
		'owned' = 1,
		'shape' = 'triangle'
		},
	'homing': {
		'owned' = 0,
		'shape' = 'upside_down_triangle'
		},
	'roller': {
		'owned' = 1,
		'shape' = 'circle'
		},
	'timer': {
		'owned' = 0,
		'shape' = 'diamond'
		},
	'driller': {
		'owned' = 1,
		'shape' = 'square'
		},
}

func initialize_shape_dict():
	shape_dict = {	
	'circle' = {
		'all_pts' = [Vector2()],
		'avg_dist' = 0,
		'lines' = {
			
			}
		},	
	'square' = {
		'all_pts' = [],
		'avg_dist' = 0,
		'lines' = {
			'line1' = {
				'pts': 0,
				'slope': 0
				},
			'line2' = {
				'pts': 0,
				'slope': 0
				},
			'line3' = {
				'pts': 0,
				'slope': 0
				},
			'line4' = {
				'pts': 0,
				'slope': 0
				}
			}
		},
	'triangle' = {
		'all_pts' = [],
		'avg_dist' = 0,
		'lines' = {
			'line1' = {
				'pts': 0,
				'slope': 0
				},
			'line2' = {
				'pts': 0,
				'slope': 0
				},
			'line3' = {
				'pts': 0,
				'slope': 0
				}
			}
		},
	'diamond' = {
		'all_pts' = [],
		'avg_dist' = 0,
		'lines' = {
			'line1' = {
				'pts': 0,
				'slope': 0
				},
			'line2' = {
				'pts': 0,
				'slope': 0
				},
			'line3' = {
				'pts': 0,
				'slope': 0
				},
			'line4' = {
				'pts': 0,
				'slope': 0
				}
			}
		},
	'upside_down_triangle' = {
		'all_pts' = [],
		'avg_dist' = 0,
		'lines' = {
			'line1' = {
				'pts': 0,
				'slope': 0
				},
			'line2' = {
				'pts': 0,
				'slope': 0
				},
			'line3' = {
				'pts': 0,
				'slope': 0
				}
			}
		}
	}
		
