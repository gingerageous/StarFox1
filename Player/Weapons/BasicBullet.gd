extends Area

var bullet_speed = 500

func _physics_process(delta):
	transform.origin += (-transform.basis.z * bullet_speed * delta)

func _on_BasicBullet_body_entered(body):
	# Destroy body if it is an enemy
	if body.is_in_group('enemy'):
		body.queue_free()
	# If the player is hit
	if body.is_in_group('player'):
		pass
	# Destroy Bullet
	queue_free()

func _on_Timer_timeout():
	queue_free()
