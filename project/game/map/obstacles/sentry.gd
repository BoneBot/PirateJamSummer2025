extends Area2D


## A sprite representing the sentry's field of view. Its visibility can be toggled and flashed.
@export var field_of_view:Sprite2D
## Whether or not the field of view is visible
@export var fov_visible := false
## The duration, in seconds, it will take for the FOV to fade when flashed
@export var flash_duration := 3.0
## The type of turn movement the sentry makes. 
## None means the sentry will not turn. 
## Alternating means the sentry will sweep back and forth between two positions. 
## Circular means the sentry will continue turning at the Turn Angle in a circular motion. 
@export_enum("None", "Alternating", "Circular") var turn_type := "None"
## How far the sentry will turn, in degrees, when a turn is triggered
@export var turn_angle := 0.0
## Time it takes to complete turn, in seconds
@export var turn_time := 1.0

@onready var sentry: Area2D = $"."
@onready var sprite: AnimatedSprite2D = $Sprite

# Used to flip the turn direction when the turn type is Alternating
var flip_turn := false


func _ready() -> void:
	if field_of_view != null:
		field_of_view.visible = fov_visible


func _process(delta: float) -> void:
	# I couldn't get the sprite to rotate properly. Maybe one day it will. RIP 
	pass
	#var rotation = fmod(rotation_degrees, 360)
	#if rotation < 0:
		#rotation += 360
	#
	#var new_animation = "down"
	#if rotation >= 45 and rotation < 135:
		#new_animation = "left"
	#elif rotation >= 135 and rotation < 225:
		#new_animation = "up"
	#elif rotation >= 225 and rotation < 315:
		#new_animation = "right"
	#else:
		#new_animation = "down"
	#
	#if sprite.animation != new_animation:
		#sprite.play(new_animation)


func show_fov() -> void:
	if field_of_view != null:
		fov_visible = true
		field_of_view.visible = true


func hide_fov() -> void:
	if field_of_view != null:
		fov_visible = false
		field_of_view.visible = false


func flash_fov() -> void:
	if field_of_view != null:
		field_of_view.visible = true
		field_of_view.modulate = Color.WHITE
		var tween = get_tree().create_tween()
		tween.tween_property(field_of_view, "modulate", Color.TRANSPARENT, flash_duration)
		tween.tween_callback(hide_fov)


func trigger_turn() -> void:
	if turn_type == "None":
		return
	
	# Get the turn angle
	var angle
	if turn_type == "Alternating":
		if flip_turn:
			flip_turn = false
			angle = sentry.rotation_degrees - turn_angle
		else:
			flip_turn = true
			angle = sentry.rotation_degrees + turn_angle
	elif turn_type == "Circular":
		angle = sentry.rotation_degrees + turn_angle
	
	# Tween the turn
	var tween = get_tree().create_tween()
	tween.tween_property(sentry, "rotation_degrees", angle, turn_time)
