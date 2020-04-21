extends KinematicBody

signal fire_bullet
var basic_bullet = preload("res://Player/Weapons/BasicBullet.tscn")

var ready_to_shoot = true

###### Movement ########
var mouse_position
var screen_size

var target_transform

var turn_right = false
var turn_left = false

var going_up = false
var going_down = false

var base_speed = 2000
var forward_speed = base_speed
var strafe_speed = 3500  # movement speed

var rot_x = 0.0
var rot_y = 180.0
var rot_z = 0.0

var velocity = Vector3()
onready var movement_guide = $MovementGuide

var camera_angle

func _ready():
	for node in get_tree().get_nodes_in_group("game"):
		connect("fire_bullet", node, "_fire_bullet")
	camera_angle = $CameraRig.global_transform.basis.rotated(Vector3(0,1,0), PI)
	screen_size = OS.window_size
	rotation_degrees.y = 180.0

func _physics_process(delta):
	get_input(delta)
	#Rising/Falling rotation
	if going_up:
		rot_x += 0.5
	elif rot_x > 0:
		rot_x -= 0.5
	if going_down:
		rot_x -= 0.5
	elif rot_x < 0:
		rot_x += 0.5
		
	rot_x = clamp(rot_x, -25.0, 25)
	
	# Turning rotation
	if turn_right:
		rot_z -= 0.5
	elif rot_z < 0:
		rot_z += 0.5
	if turn_left:
		rot_z += 0.5
	elif rot_z > 0:
		rot_z -= 0.5
		
	rot_z = clamp(rot_z, -25.0, 25)
	velocity = Vector3()
	velocity += -transform.basis.z * forward_speed * delta
	velocity = move_and_slide(velocity, Vector3.UP)
#	$CameraRig.rotation_degrees.z = -rotation_degrees.z
	$CameraRig.global_transform.basis = camera_angle

func get_input(delta):
	if InputEventMouseMotion:
		mouse_position = get_viewport().get_mouse_position()
		var a = mouse_position / screen_size
		target_transform = Transform(transform.basis, transform.origin + Vector3(100 + -175 * a.x, 100 + -175* a.y, 150))
		var desired_rotation = transform.looking_at(target_transform.origin, Vector3(0,1,0))
		var b = Quat(transform.basis.get_rotation_quat()).slerp(desired_rotation.basis.get_rotation_quat(), 0.2)
		set_transform(Transform(b, transform.origin))
		
		transform.origin.linear_interpolate(target_transform.origin, 1)
	
	if Input.is_action_just_pressed("boost"):
		print(transform.origin)
		print(target_transform.origin)
	
	
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


