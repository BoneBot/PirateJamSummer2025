# interactable.gd
## An interactable area.
class_name Interactable
extends Area2D

## Whether or not the interactable can currently be used
@export var is_interactable := true

var interact: Callable = func():
	pass
