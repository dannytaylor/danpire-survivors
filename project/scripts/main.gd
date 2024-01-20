extends Node3D

@onready var player = $player
@onready var xp_bar = $ui/xp_bar
@onready var wave_bar = $ui/wave_bar
@onready var wave_label = $ui/wave_bar/Label
@onready var game_timer = $ui/timer
var game_time = 0.0

var spawn_rate = 5.0 # every x sec
var spawn_mult = 0.80
var wave_proj = 0
var wave_max = 6
var wave_mult = 1.5
var wave = 1

var hp_mult = 1.2
var speed_mult = 1.05
var dmg_mult = 1.2
var xp_mult = 0.85

@export var enemy_scene: PackedScene
@onready var spawn_timer = $floor/spawn_path/spawn_timer
@onready var spawn_loc = $floor/spawn_path/spawn_loc

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.wait_time = spawn_rate
	spawn_timer.start()
	get_tree().paused = true


func _unhandled_input(event):	
	if Input.is_action_just_pressed("debug3"):
		spawn_enemy()
			

#func new_wave():
	#spawn_rate *= 1.2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	xp_bar.value = player.xp
	$ui/xp_bar/Label.text = 'level ' + str(player.level)
	game_timer.text = "%0.1f"%game_time
	game_time+=delta

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	spawn_loc.progress_ratio = randf()
	var level = player.level
	enemy.initialize(spawn_loc.position, player,
		pow(hp_mult,level-1),pow(speed_mult,level-1),pow(dmg_mult,level-1),pow(xp_mult,level-1))
	add_child(enemy)
	
	spawn_timer.wait_time = spawn_rate*pow(spawn_mult,player.level)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	spawn_enemy()
	
var powers_text = {
	'dog': '+1 orbiting dogs, increased damage',
	'mustard': 'shoot mustard; increase shoot rate and damage, +1 shooter per 4 levels',
	'ketchup': 'drop ketchup pack mines; increase dmg and aoe, reduce cooldown',
	'dash': 'quick dash (spacebar), reduce cooldown'
}
@onready var level_ui = $ui/level_up
@onready var opt1_title = $ui/level_up/opt1/title
@onready var opt1_level = $ui/level_up/opt1/level
@onready var opt1_descr = $ui/level_up/opt1/descr
@onready var opt2_title = $ui/level_up/opt2/title
@onready var opt2_level = $ui/level_up/opt2/level
@onready var opt2_descr = $ui/level_up/opt2/descr
var opt1
var opt2
@onready var you_won = $ui/you_won

func level_up():
	if player.level == 10:
		you_won.visible = true
	level_ui.visible = true
	xp_bar.value = 0
	$ui/xp_bar/Label.text = 'level ' + str(player.level)
	
	var options = powers_text.keys()
	options.shuffle()
	opt1 = options.pop_at(0)
	opt2 = options.pop_at(0)
	
	opt1_title.text = opt1
	opt1_level.text = 'level '+str(player.power_levels[opt1]+1)
	opt1_descr.text = powers_text[opt1]
	opt2_title.text = opt2
	opt2_level.text = 'level '+str(player.power_levels[opt2]+1)
	opt2_descr.text = powers_text[opt2]
	
	get_tree().paused = true
	print('level up')

func wave_inc():
	wave += 1
	wave_proj = wave_proj%wave_max
	wave_max = int(wave_max*1.5)
	wave_label.text = "wave " + str(wave)
	spawn_rate = spawn_mult*spawn_rate
	
func wave_kill():
	wave_proj += 1
	if wave_proj >= wave_max:
		wave_inc()
	wave_bar.value = float(wave_proj)/float(wave_max)


@onready var upgrade = $ui/level_up/upgrade
func choose_power(opt):
	level_ui.visible = false
	get_tree().paused = false
	player.power_level(opt)
	upgrade.play()
	
@onready var game_over = $ui/game_over
func end_game():
	game_over.visible = true
	get_tree().paused = true
	
func _on_lvl_btn_1_button_up():
	choose_power(opt1)
func _on_lvl_btn_2_button_up():
	choose_power(opt2)
