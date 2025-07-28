extends Area2D


signal dialogue_triggered

var has_triggered := false


func _on_body_entered(_body: Node2D) -> void:
	if not has_triggered:
		has_triggered = true
		dialogue_triggered.emit()
