extends Area2D


## A sprite representing the sentry's field of view. Its visibility can be toggled and flashed.
@export var field_of_view:Sprite2D
## Whether or not the field of view is visible
@export var fov_visible := false
## The duration, in seconds, it will take for the FOV to fade when flashed
@export var flash_duration := 3.0


func _ready() -> void:
	if field_of_view != null:
		field_of_view.visible = fov_visible


func _on_body_entered(_body: Node2D) -> void:
	#print("Player detected!")
	pass


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
