extends Node3D

var dmg = 2.0
var dmg_mult = 1.8
var level = 0
var fire_speed = 1.2
var fire_mult = 0.8

const MUSTARD_INST = preload("res://scenes/powers/mustard_inst.tscn")
@onready var spawn_timer = $spawn_timer
@onready var mesh = $mesh
@onready var mesh_scale = mesh.scale
@onready var shoot_scale = mesh_scale*2.0
const LERP_VAL = 0.1
@onready var shoot = $shoot


func _ready():
	pass

func first_level():
	spawn_timer.wait_time = fire_speed
	spawn_timer.start()
	visible = true
	
func spawn_mustard(target):
	look_at(target)
	rotate_y(PI)
	
	var ball = MUSTARD_INST.instantiate()
	get_tree().root.get_child(0).add_child(ball)
	ball.position = mesh.global_position
	ball.rotation = rotation
	ball.velocity = Vector3.FORWARD.rotated(Vector3.UP,rotation.y+PI)*ball.speed
	ball.dmg = dmg*pow(dmg_mult,level-1)
	
	mesh.scale = shoot_scale
	shoot.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mesh.scale = lerp(mesh.scale,mesh_scale,LERP_VAL)

func get_random_enemy(enemies):
	var pick = enemies.pick_random()
	return pick.position
	

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		return null
		
	var nearest_pos = null
	var dist = null
	
	return get_random_enemy(enemies)
	
	for e in enemies:
		if e.hp > 0.0:
			if dist == null or dist > position.distance_to(e.position):
				dist = position.distance_to(e.position)
				nearest_pos = e.position
	return nearest_pos

func _on_spawn_timer_timeout():
	var target = get_nearest_enemy()
	if target:
		spawn_mustard(target)
	spawn_timer.wait_time = fire_speed*pow(fire_mult,level-1)
	spawn_timer.start()
