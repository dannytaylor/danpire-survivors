extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	start_screen.visible = true
	
@onready var level_ui = $level_up
@onready var start_screen = $start_screen
@onready var game_over = $game_over
@onready var main = $".."
@onready var player = $"../player"

func _unhandled_input(event):	
	if Input.is_action_just_pressed("tilde"):
		get_tree().quit()
	if Input.is_action_just_pressed("esc"):
		get_tree().reload_current_scene()
		player.hp = player.hp_max
		player.take_dmg(0.0)
		
		
	if Input.is_action_just_pressed("space"):
		if start_screen.visible:
			start_screen.visible = false
			get_tree().paused = false
	
	if level_ui.visible:
		if Input.is_action_just_pressed("q"):
			main._on_lvl_btn_1_button_up()
		if Input.is_action_just_pressed("e"):
			main._on_lvl_btn_2_button_up()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
