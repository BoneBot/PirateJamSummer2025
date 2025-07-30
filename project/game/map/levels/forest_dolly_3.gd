extends Node2D


@onready var background: Sprite2D = $Background
@onready var player: CharacterBody2D = $Player
@onready var toy: CharacterBody2D = $Toy
@onready var shadow: Node2D = $Shadow
@onready var reset_point: Marker2D = $ResetPoint
@onready var sentry_timer: Timer = $SentryTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	
	for sentry in get_tree().get_nodes_in_group("sentries"):
		sentry.body_entered.connect(_on_sentry_triggered)
	
	# Trigger starting dialogue
	await dialogue_manager.start_dialogue("start", 0)
	
	# Start up level mechanics
	get_tree().call_group("sentries", "show_fov")
	sentry_timer.start()


# Reset the player position to the reset point
func _reset_player() -> void:
	var toy_offset = player.position - toy.position
	# Pause scene
	get_tree().paused = true
	# Fade to black
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	# Change positions
	player.position = reset_point.position
	toy.position = player.position - toy_offset
	# Fade back in
	animation_player.play_backwards("fade_to_black")
	# Unpause scene
	get_tree().paused = false


func _on_sentry_triggered(_body: Node2D) -> void:
	_reset_player()


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	sentry_timer.stop()
	shadow.visible = true
	await dialogue_manager.start_dialogue("exit", 0)
	shadow.visible = false
	level_exited.emit("ending")


func _on_sentry_timer_timeout() -> void:
	get_tree().call_group("sentries", "trigger_turn")
