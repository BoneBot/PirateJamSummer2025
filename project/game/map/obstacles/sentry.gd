extends Area2D


@export var field_of_view:Sprite2D
@export var fov_visible := false


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
