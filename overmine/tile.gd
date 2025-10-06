extends Sprite2D

var danger = false
var value
var state_changed = false

#func change_state(new_state, warning_num):
	##$sprites/hidden.visible = false
	#match new_state:
		#'safe':
			#state = new_state
			#danger = false
			##$sprites/safe.visible = true
			#
		#'mine':
			#state = new_state
			#danger = true
			##$sprites/safe.visible = true
		#'warning':
			#state = new_state
			#danger = false
			#value = warning_num
		
func clicked(array):
	if state_changed == false:
		$sprites/hidden.visible = false
	
		match array[1]:
			'safe':
				$sprites/safe.visible = true
			
			'mine': 
				$sprites/mine_clicked.visible = true
				
			'warning':
				var node_path = 'sprites/' + str(array[2])
				get_node(node_path).visible = true
		
		state_changed = true	
			

	
		
