extends CharacterBody2D

@export var target: CharacterBody2D			# Target for the toy to follow
@export var follow_distance:float = 40		# Distance from the target the toy will follow at (px)
@export var follow_speed:float = 200		# Speed of the toy (px/s)


func _physics_process(_delta: float) -> void:
	if (target.position - position).length() > follow_distance:
		velocity = (target.position - position).normalized() * follow_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
