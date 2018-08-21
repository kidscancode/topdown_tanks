extends Area2D

enum Items {health, ammo}

export (Items) var type = Items.health
export (Vector2) var amount = Vector2(10, 25)


func _on_Pickup_body_entered(body):
	match type:
		Items.health:
			if body.has_method('heal'):
				print("healing")
				body.heal(int(rand_range(amount.x, amount.y)))
		Items.ammo:
			pass
	queue_free()