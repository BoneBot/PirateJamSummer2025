# interactable.gd
## An interactable area.
class_name Interactable
extends Area2D

@export var is_interactable := true

var interact: Callable = func():
	pass
