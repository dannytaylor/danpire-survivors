extends CharacterBody3D

var hp_max = 5
var hp = hp_max
var speed = 1.0
var dmg = 5.0
var xp = 25.0

var player = null
@onready var body_mat = $pentagram/Plane.get_surface_override_material(0).duplicate()
@onready var dog_hit = $dog

# Called when the node enters the scene tree for the first time.[
func _ready():
	$pentagram/Plane.set_surface_override_material(0,body_mat)
	
func initialize(start_position, p,h,s,d,x):
	player = p
	
	hp_max *= h
	hp = hp_max
	speed *= s
	dmg *= d
	xp *= x
	
	var hp_tex = $hp_bar.get_texture().duplicate()
	$hp_bar.set_texture(hp_tex)
	var hp_grad = hp_tex.get_gradient().duplicate()
	hp_tex.set_gradient(hp_grad)
		
	position = start_position
	look_at_from_position(start_position, p.position, Vector3.UP)
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	body_mat.albedo_color = lerp(body_mat.albedo_color,Color.WHITE,0.1)
	
func _physics_process(_delta):
	if hp>0.0:
		if player:
			look_at(player.position)
			rotation = rotation*Vector3.UP
			velocity = Vector3.FORWARD * speed
			velocity = velocity.rotated(Vector3.UP, rotation.y)
		move_and_slide()
	else:
		position.y -= 0.02
	
func die():
	#print('pow ded')
	player.gain_xp(xp)
	#var main = get_tree().get_nodes_in_group('main')[0]	
	# main.wave_kill()
	$hp_bar.visible = false
	var audio = [$death1,$death1,$death1,$death2].pick_random()
	audio.play()
	$hurt_zone.monitoring = false
	$hurt_zone.monitorable = false

var alive = true
func take_dmg(dmg):
	hp -= dmg
	$hp_bar.texture.get_gradient().set_offset(1,clamp(hp/hp_max,0.0001,100.0))
	body_mat.albedo_color = Color.RED
	if hp <= 0.0 and alive:
		die()
		alive = false


func _on_hurt_zone_body_entered(body):
	if 'player' in body.get_groups():
		player.take_dmg(dmg)


func _on_death_finished():
	queue_free()
func _on_death_2_finished():
	queue_free()
