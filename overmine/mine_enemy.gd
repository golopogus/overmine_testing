extends Area2D

var end = Vector2()
var speed = 2

func _ready() -> void:
	
	GameManager.connect('send_player_pos',set_player_pos)

func _process(delta: float) -> void:
	GameManager.get_player_position()
	var dir = (end - global_position).normalized()
	var velocity = speed * dir
	position += velocity
	
	

func set_player_pos(pos):
	end = pos
	
	


func _on_area_entered(area: Area2D) -> void:
	queue_free()
