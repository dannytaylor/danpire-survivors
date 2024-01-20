extends Node3D

var dmg = 2.0
var speed = 12.0
var velocity = Vector3.FORWARD*speed
@onready var timer = $timer
@onready var ball = $mustard_ball2
@onready var ball_scale = ball.scale

# Called when the node enters the scene tree for the first time.
func _ready():
	ball.scale = ball_scale/4.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ball.scale = lerp(ball.scale,ball_scale,0.06)
	
func _physics_process(delta):
	position += velocity * delta


func _on_hit_box_body_entered(body):
	if 'enemy' in body.get_groups():
		# print('mustard hit')
		if body.hp > 0.0:
			body.take_dmg(dmg)
			$hit.play()
			$hit_box.monitoring = false
			$hit_box.monitorable = false
			visible = false


func _on_timer_timeout():
	queue_free()


func _on_hit_finished():
	queue_free()
