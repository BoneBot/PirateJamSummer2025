extends StaticBody2D

# Whether or not the door is currently open
@export var is_open := false

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Label = $Sprite
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	if is_open:
		is_open = false  # Setting to false so open_door() will actually run
		open_door()


func open_door() -> void:
	if is_open:
		return
	is_open = true
	sprite.text = "OPEN"
	collision.disabled = true
	interactable.is_interactable = false


func close_door() -> void:
	if not is_open:
		return
	is_open = false
	sprite.text = "LOCKED"
	collision.disabled = false
	interactable.is_interactable = true
