extends Area

var bullet_speed = 600

func _physics_process(delta):
	transform.origin += (-transform.basis.z * bullet_speed * delta)
	
func _on_BasicBullet_body_entered(body):
	# Destroy body if it is an enemy
	if body.is_in_group('player'):
		print('hit')
	# Destroy Bullet
	queue_free()
