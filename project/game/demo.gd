extends Node2D

@export var player: CharacterBody2D
@export var speed = 200
@export var angular_speed = PI

@onready var goal_sfx = $DemoGoal/Ding

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		player.rotation -= angular_speed * delta
	if Input.is_action_pressed("ui_right"):
		player.rotation += angular_speed * delta
	if Input.is_action_pressed("ui_up"):
		player.position += Vector2.UP.rotated(player.rotation) * speed * delta


func _on_demo_goal_body_entered(body: Node2D) -> void:
	goal_sfx.play()
