extends Node3D

var spawn_speed = 4.4
var size_mult = 1.25
var level = 0
var dmg = 4.0
var dmg_mult = 1.6

const KETCHUP_INST = preload("res://scenes/powers/ketchup_inst.tscn")
@onready var spawn_timer = $spawn_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func first_level():
	spawn_timer.wait_time = spawn_speed
	spawn_timer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_packet():
	var packet = KETCHUP_INST.instantiate()
	get_tree().root.get_child(0).add_child(packet)
	packet.dmg = dmg*pow(dmg_mult,level-1)
	packet.scale = packet.scale*pow(size_mult,level)
	packet.position = global_position
	packet.rotation.y = randf_range(0.0,2*PI)
	
	

func _on_spawn_timer_timeout():
	spawn_timer.wait_time = clamp(spawn_speed-0.1*level,1.0,5.0)
	spawn_timer.start()
	$spawn.play()
	spawn_packet()
