@tool
extends Node3D

const base_damage = 1.0
var rot_speed = 1.0
var orbit_rad = 2.0
var level = 1

var dmg = 1.0
var dmg_mult = 1.4

const DOG_INST = preload("res://scenes/powers/dog_inst.tscn")
var dogs = []


func _ready():
	spawn_dog(2.5)
	spawn_dog(-2.5)

func spawn_dog(orbit=randf_range(orbit_rad-0.5,orbit_rad+1.5)):
	var dog = DOG_INST.instantiate()
	dog.get_child(0).position.x = orbit
	dogs.append(dog)
	add_child(dog)
	level += 1
	dmg *= dmg_mult

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for d in dogs:
		d.rotation_degrees.y += rot_speed
