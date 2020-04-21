extends Area

var bullet_speed = 500
var target = null

func _physics_process(delta):
	if is_instance_valid(target):
		aim()
	global_transform.origin += (-global_transform.basis.z * bullet_speed * delta)
	
func aim():
	var desired_rotation = global_transform.looking_at(target.global_transform.origin, Vector3(0,1,0))
	var a = Quat(global_transform.basis.get_rotation_quat()).slerp(desired_rotation.basis.get_rotation_quat(), 0.3)
	global_transform.basis = Basis(a)
	
func _on_Timer_timeout():
	queue_free()

func _on_ChargedBullet_body_entered(body):
	# Destroy body if it is an enemy
	if body.is_in_group('enemy'):
		body.queue_free()
	# If the player is hit
	if body.is_in_group('player'):
		pass
	# Destroy Bullet
	queue_free()
