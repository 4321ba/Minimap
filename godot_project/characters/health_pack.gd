extends StaticBody2D

var heal_percentage = 0.3

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and body.health != body.max_health:
		body.heal(body.max_health * heal_percentage)
		queue_free()
