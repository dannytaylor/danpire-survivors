extends Area3D

var armed = false
var dmg

# Called when the node enters the scene tree for the first time.
func _ready():
	var mat = $expl.get_surface_override_material(0).duplicate()
	$expl.set_surface_override_material(0,mat)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_armed():
	armed = true

func explode_finish():
	var aoe = $expl_area
	var bodies = aoe.get_overlapping_bodies()
	for body in bodies:
		if 'enemy' in body.get_groups():
			body.take_dmg(dmg)	
	queue_free()


func _on_body_entered(body):
	if armed:
		if 'enemy' in body.get_groups():
			$expl.visible = true
			$expl/AnimationPlayer.play('explode')
			$expl/AudioStreamPlayer.play()
