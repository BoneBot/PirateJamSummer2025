# demo.gd
extends Node2D

@export var player: CharacterBody2D

@onready var goal_sfx = $DemoGoal/Ding

const SPEED := 200		# Max walking speed (px/s)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	# Handle walking
	var h_speed := Input.get_axis("left", "right") * SPEED
	var v_speed := Input.get_axis("up", "down") * SPEED
	player.position += Vector2(h_speed, v_speed).normalized() * SPEED * delta


func _on_demo_goal_body_entered(_body: Node2D) -> void:
	goal_sfx.play()
