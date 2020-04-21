extends KinematicBody

signal fire_bullet
var basic_bullet = preload("res://Player/Weapons/BasicBullet.tscn")

var ready_to_shoot = true

###### Movement ########
var turn_right = false
var turn_left = false

var going_up = false
var going_down = false

var base_speed = 2000
var forward_speed = base_speed
var strafe_speed = 4500  # movement speed

var rot_x = 0.0
var rot_y = 0.0
var rot_z = 0.0

var velocity = Vector3()
onready var movement_guide = $MovementGuide

# Camera info
var camera_pos_1 = "Upper"
var camera_pos_2 = "Right"

var lower_camera_height_default = -10.0

# Sight colors
var yes_enemy_material = preload("res://Player/Assets/SightShaderEnemyInSight.tres")

func _ready():
	for node in get_tree().get_nodes_in_group("game"):
		connect("fire_bullet", node, "_fire_bullet")
		
func _physics_process(delta):
	get_input(delta)
	#Rising/Falling rotation
	if going_up:
		rot_x += 0.3
	elif rot_x > 5:
		rot_x -= 0.7
	if going_down:
		rot_x -= 0.3
	elif rot_x < -5:
		rot_x += 0.7
		
	rot_x = clamp(rot_x, -25.0, 25)
	
	# Rolling rotation
	if turn_right:
		rot_z -= 0.3
	elif rot_z < 0:
		rot_z += 0.3
	if turn_left:
		rot_z += 0.3
	elif rot_z > 0:
		rot_z -= 0.3
	# Turning rotation done seperately to give better aiming feel
	if turn_right:
		rot_y -= 0.3
	elif rot_y < -5:
		rot_y += 0.3
	if turn_left:
		rot_y += 0.3
	elif rot_y > 5:
		rot_y -= 0.3
	
	rot_y = clamp(rot_z, -25.0, 25)
	rot_z = clamp(rot_z, -25.0, 25)
	
	velocity += movement_guide.transform.basis.z * forward_speed * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	$CameraRig.global_transform.basis = Basis(Vector3(-1, 0, 0),Vector3(0, 1, 0), Vector3(0,0,-1))
	
	# Adjust Camera position
	if going_up:
		camera_pos_1 = "Lower"

	if going_down:
		camera_pos_1 = "Upper"

	if turn_left:
		camera_pos_2 = "Right"
	
	if turn_right:
		camera_pos_2 = "Left"
		
	# Position Camera
	$CameraRig/Camera.translation = (lerp($CameraRig/Camera.translation, $CameraRig.get_node(camera_pos_1 + camera_pos_2).translation, 0.014))
	# Aim Camera At Sights
	var desired_rotation = $CameraRig/Camera.transform.looking_at($Sight/Two.transform.origin, Vector3(0,1,0))
	var a = Quat($CameraRig/Camera.transform.basis.get_rotation_quat()).slerp(desired_rotation.basis.get_rotation_quat(), 1)
	$CameraRig/Camera.transform.basis = Basis(a)
	# Turn Sights Red if going to hit an enemy
	if $Sight/RayCast.is_colliding():
		$Sight/One.material_override = yes_enemy_material
		$Sight/Two.material_override = yes_enemy_material
	else:
		$Sight/One.material_override = null
		$Sight/Two.material_override = null
		
	# Stop Camera from clipping into the ground
	if $CameraRig/Camera/GroundCheck.is_colliding():
		var ground_pos = $CameraRig/Camera/GroundCheck.get_collision_point()
		var distance_to_ground = ground_pos.y - $CameraRig/Camera.global_transform.origin.y
		$CameraRig/LowerLeft.transform.origin.y = lower_camera_height_default + (10 - distance_to_ground)
		$CameraRig/LowerRight.transform.origin.y = lower_camera_height_default + (10 - distance_to_ground)
#
func get_input(delta):
	
	velocity = Vector3()
	if Input.is_action_pressed("move_up") or Input.is_action_pressed('ui_up'):
		velocity += movement_guide.transform.basis.y * strafe_speed * delta
		going_up = true
		
	elif rot_x > 0.0:
		going_up = false
	if Input.is_action_pressed("move_down")  or Input.is_action_pressed('ui_down'):
		velocity += -movement_guide.transform.basis.y * strafe_speed * delta
		going_down = true
	elif rot_x < 0.0:
		going_down = false
	if Input.is_action_pressed("strafe_right") or Input.is_action_pressed('ui_right'):
		velocity += -movement_guide.transform.basis.x * strafe_speed * delta
		turn_right = true
	elif rot_z < 0.0:
		turn_right = false
		
	if Input.is_action_pressed("strafe_left")  or Input.is_action_pressed('ui_left'):
		velocity += movement_guide.transform.basis.x * strafe_speed * delta
		turn_left = true
	elif rot_z > 0.0:
		turn_left = false
	
	rotation_degrees.x = rot_x
	rotation_degrees.y = rot_y + 180
	rotation_degrees.z = rot_z
	
	if Input.is_action_pressed("boost"):
		forward_speed = base_speed * 3
	else:
		forward_speed = base_speed
		
	if Input.is_action_pressed("shoot"):
		if ready_to_shoot:
			ready_to_shoot = false
			$GunContainer/GunTimer.start()
			# Tell Root node where to add bullets
			var orig = $GunContainer/MuzzleRight.global_transform.origin
			var direction = transform.basis
			emit_signal("fire_bullet", orig, direction, basic_bullet)
			orig = $GunContainer/MuzzleLeft.global_transform.origin
			direction = transform.basis
			emit_signal("fire_bullet", orig, direction, basic_bullet)
	
func _on_GunTimer_timeout():
	ready_to_shoot = true
