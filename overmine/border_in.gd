extends Node2D
var closing = false
var radius = 1.1
var mat = load('res://border_in.gdshader')
func _ready() -> void:
	Globals.get_timer(self.get_path())
	
	$ColorRect.material = ShaderMaterial.new()
	$ColorRect.material.set("shader", mat)
	#$border_timer.wait_time = 5
	#$border_timer.start()

func time_out():
	
	closing = true

func _process(delta: float) -> void:
	if closing == true:
		print(radius)
		radius -= .005 * delta
		$ColorRect.material.set("shader_parameter/radius",radius)
		
		
