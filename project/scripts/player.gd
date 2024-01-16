extends CharacterBody3D

var level = 1
var xp = 0
var hp = 100
var hp_max = 100

const SPEED = 8.0
const JUMP_VELOCITY = 4.5
const LERP_VAL = 0.10

@onready var dogger = $dogger
@onready var body_mat = $dogger/skeleton/Skeleton3D/body.get_surface_override_material(0)

@onready var foot_target_r = $dogger/skeleton/foot_target_r
@onready var foot_target_l = $dogger/skeleton/foot_target_l
@onready var foot_ik_r = $dogger/skeleton/Skeleton3D/foot_ik_r
@onready var foot_ik_l = $dogger/skeleton/Skeleton3D/foot_ik_l
@onready var active_ik = foot_target_r
@onready var inactive_ik = foot_target_l
const IK_MAX_DIST = 0.8
const FOOT_OFFSET = Vector3(0.2,0.5,0.0)

@onready var hand_ik_r = $dogger/skeleton/Skeleton3D/hand_ik_r
@onready var hand_ik_l = $dogger/skeleton/Skeleton3D/hand_ik_l
const HAND_INTERP_MAX = 0.2

@onready var head_ik = $dogger/skeleton/Skeleton3D/head_ik
const HEAD_INTERP_MAX = 0.02
const MOVE_TILT = -12.0
@onready var skeleton = $dogger/skeleton

@onready var hp_grad = $hp_bar.texture.get_gradient()
@onready var powers = $powers

var power_levels = {'dog':1,'mustard':0,'ketchup':0,'dash':0}

@onready var oof = $oof
@onready var death = $death

var enemies = []

@onready var main = get_tree().get_nodes_in_group('main')[0]	

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_dashing = false
var can_dash = true
var dash_invinc = false
var dash_cooldown = 3.0
var dash_mult = 0.8
var dash_invinc_time = 0.3
var dash_duration = 0.1
var dash_speed_mult = 2.0
@onready var dash_timer = $powers/dash_timer
@onready var dash_timeout = $powers/dash_timer/dash_timeout
@onready var dash_invinc_timer = $powers/dash_timer/dash_invinc

@onready var woosh = $woosh
@onready var footsteps = $footsteps

func _unhandled_input(event):
	if Input.is_action_just_pressed("debug1"):
		powers.get_child(0).spawn_dog()
		# xp+=50
	if Input.is_action_just_pressed("debug2"):
		take_dmg(50.0)
	
	if Input.is_action_just_pressed("space"):
		if power_levels['dash'] >= 1 and can_dash:
			woosh.play()
			body_mat.albedo_color = Color.GREEN_YELLOW
			is_dashing = true
			can_dash = false
			dash_invinc = true
			dash_timer.start(dash_duration)
			dash_invinc_timer.start(dash_duration+dash_invinc_time)
			dash_timeout.start(clamp(dash_cooldown*pow(dash_mult,power_levels['dash']),0.5,3.0))

func move_feet(direction):
	if not footsteps.playing:
		footsteps.play()

	foot_ik_r.interpolation = 1.0
	foot_ik_l.interpolation = 1.0
	var ik_dist = position.distance_to(active_ik.position)
	#var direction = Vector3.BACK.rotated(Vector3.UP,dogger.rotation.y)*IK_MAX_DIST
	var target_pos = position+direction*IK_MAX_DIST
	var foot_check  = target_pos.distance_to(inactive_ik.position)
	if ik_dist > IK_MAX_DIST and foot_check > IK_MAX_DIST:
		target_pos.y = 0.0
		active_ik.position = target_pos
		var new_ik = inactive_ik
		inactive_ik = active_ik
		active_ik = new_ik

func _physics_process(delta):
	# Add the gravity.
	body_mat.albedo_color = lerp(body_mat.albedo_color,Color.WHITE,LERP_VAL/2.0)
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_dashing:
		var dir = Vector3.FORWARD.rotated(Vector3.UP,dogger.rotation.y+PI)
		velocity.x = dir.x * SPEED * dash_speed_mult
		velocity.z = dir.z * SPEED * dash_speed_mult*1.5
		#print(velocity)
	elif direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED,LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED,LERP_VAL)
		dogger.rotation.y = lerp_angle(dogger.rotation.y, atan2(velocity.x,velocity.z), LERP_VAL*2)
		
		hand_ik_l.interpolation = lerp(hand_ik_l.interpolation,HAND_INTERP_MAX,LERP_VAL)
		hand_ik_r.interpolation = lerp(hand_ik_r.interpolation,HAND_INTERP_MAX,LERP_VAL)
		head_ik.interpolation = lerp(head_ik.interpolation,HEAD_INTERP_MAX,LERP_VAL)
		skeleton.rotation_degrees.x = lerp(skeleton.rotation_degrees.x,MOVE_TILT,LERP_VAL)
		
		move_feet(direction)
	else:
		velocity.x = lerp(velocity.x, 0.0,LERP_VAL*2)
		velocity.z = lerp(velocity.z, 0.0,LERP_VAL*2)
		
		hand_ik_l.interpolation = lerp(hand_ik_l.interpolation,0.0,LERP_VAL*2)
		hand_ik_r.interpolation = lerp(hand_ik_r.interpolation,0.0,LERP_VAL*2)
		head_ik.interpolation = lerp(head_ik.interpolation,0.0,LERP_VAL*2)
		skeleton.rotation_degrees.x = lerp(skeleton.rotation_degrees.x,0.0,LERP_VAL*2)
		
		
		#var offset = FOOT_OFFSET.rotated(Vector3.UP,dogger.rotation.y)
		#foot_target_l.position = position + offset
		#foot_target_r.position = position - offset
		foot_ik_r.interpolation = 0.1
		foot_ik_l.interpolation = 0.1
		
		if footsteps.playing:
			footsteps.stop()

	move_and_slide()

func gain_xp(x):
	xp += x
	if xp >= 100.0:
		level += 1
		xp = int(xp)%100
		main.level_up()

func die():
	print('ur ded')
	main.end_game()
	death.play()	
	
func take_dmg(dmg):
	if not dash_invinc:
		hp -= dmg
		hp_grad.set_offset(1,clamp(hp/100.0,0.0001,100.0))
		if dmg > 0.0:
			oof.play()
			body_mat.albedo_color = Color.RED
			if hp <= 0.0:
				die()
		
@onready var dog = $powers/dog
@onready var mustard = $powers/mustard
@onready var ketchup = $powers/ketchup
func power_level(pow):
	power_levels[pow] += 1
	if pow == 'dog':
		dog.spawn_dog()
	elif pow == 'mustard':
		mustard.level += 1
		if power_levels[pow] == 1:
			mustard.first_level()
	elif pow == 'ketchup':
		ketchup.level += 1
		if power_levels[pow] == 1:
			ketchup.first_level()
		
func _on_dash_timer_timeout():
	is_dashing = false
	dash_timer.stop()
func _on_dash_timeout_timeout():
	can_dash = true
	dash_timeout.stop()
func _on_dash_invinc_timeout():
	dash_invinc = false
	dash_invinc_timer.stop()
