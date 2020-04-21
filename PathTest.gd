extends Spatial

onready var guide = $Path/Dolly/PositionGuide
onready var player = $Path/Dolly/PlayerOnDolly
onready var camera = $Path/Dolly/Camera
onready var bullet_container = $BulletContainer
onready var hud = $HUD
onready var sight_one = $Path/Dolly/PlayerOnDolly/Sight/One
onready var sight_two = $Path/Dolly/PlayerOnDolly/Sight/Two
onready var radar_position = $Path/Dolly/RadarPosition
onready var radar_camera = $HUD/ViewportContainer/Viewport/RadarCamera

signal update_sights

var dolly_speed = 25

var strafe_speed = 70
var turning_left = false
var turning_right = false

var z_rot = 0.0
var max_z_rotation= 90.0
var barrel_roll = false
var barrel_roll_finished = 0.0
# Radar Stuff


func _ready():
	connect('update_sights', hud, "_update_sights")

func _physics_process(delta):
	$Path/Dolly.offset += delta * dolly_speed
	get_input(delta)
	player_movement(delta)
	camera_movement()
	find_sight_location()
	align_radar()
	

func get_input(delta):
	# Movement
	var velocity = Vector3()
	if Input.is_action_pressed("move_down") or Input.is_action_pressed('ui_up'):
		guide.transform.origin.y += -strafe_speed * delta
	
	if Input.is_action_pressed("move_up")  or Input.is_action_pressed('ui_down'):
		guide.transform.origin.y += strafe_speed * delta
		
	if Input.is_action_pressed("strafe_right") or Input.is_action_pressed('ui_right'):
		guide.transform.origin.x += strafe_speed * delta
		turning_right = true
	else:
		turning_right = false
	
	if Input.is_action_pressed("strafe_left")  or Input.is_action_pressed('ui_left'):
		guide.transform.origin.x += -strafe_speed * delta
		turning_left = true
	else:
		turning_left = false
	# Straighten out Flying if no input
	if !turning_left and !turning_right:
		guide.transform.origin.x = lerp(guide.transform.origin.x, player.transform.origin.x, 0.01)
		guide.transform.origin.y = lerp(guide.transform.origin.y, player.transform.origin.y, 0.01)
		
	guide.transform.origin.y = clamp(guide.transform.origin.y, -70.0, 70.0)
	guide.transform.origin.x = clamp(guide.transform.origin.x, -100.0, 100.0)
	
	# Barrel Roll Input
	if Input.is_action_just_pressed("barrel_roll") and !barrel_roll:
		do_a_barrel_roll()
	
func player_movement(delta):
	#Aim at position Guide
	var desired_rotation = player.transform.looking_at(guide.transform.origin, Vector3(0,1,0))
	var rot = Quat(player.transform.basis.get_rotation_quat()).slerp(desired_rotation.basis.get_rotation_quat(), 0.2)
	# Movement with Collisions
	var velocity = (guide.transform.origin + Vector3(0,0,50)) - player.transform.origin
	velocity = player.move_and_slide(velocity, Vector3(0,1,0))
	player.transform.origin.x = clamp(player.transform.origin.x, -50.0, 50.0)
	player.transform.origin.y = clamp(player.transform.origin.y, -70.0, 70.0)
	player.set_transform(Transform(rot, player.transform.origin))
	# Movement without Collisions
#	var orig = lerp(player.transform.origin, guide.transform.origin + Vector3(0,0,50), 0.05)
#	orig.y = clamp(orig.y, -30.0, 30.0)
#	orig.x = clamp(orig.x, -50.0, 50.0)
#	player.set_transform(Transform(rot, orig))
	
	# Better Rotation Control
	# Rotate z if horizontal movement with extra variable (z_rot) to keep track of rotation
	if !barrel_roll:
		if turning_left and !turning_right:
			z_rot = lerp(z_rot, max_z_rotation, 0.02)
		elif turning_right and !turning_left:
			z_rot = lerp(z_rot, -max_z_rotation, 0.02)
		else:
			z_rot = lerp(z_rot, 0, 0.05)
	else:
		z_rot = lerp(z_rot, barrel_roll_finished, 0.1)
		if z_rot > barrel_roll_finished - 1.0:
			barrel_roll = false
			z_rot = z_rot - 360


	player.rotation_degrees.z = z_rot
	
	# Kind of works for rotation
	# Rotate z if horizontal movement directly
#	if turning_left and !turning_right:
#		player.rotation_degrees.z = lerp(player.rotation_degrees.z, 30.0, 0.15)
#	elif turning_right and !turning_left:
#		player.rotation_degrees.z = lerp(player.rotation_degrees.z, -30.0, 0.15)
#	else:
#		player.rotation_degrees.z = lerp(player.rotation_degrees.z, 0.0, 0.1)
	
func camera_movement():
	var orig = lerp(camera.transform.origin, player.transform.origin + Vector3(0,10,50), 0.04)
	orig.y = clamp(orig.y, -30.0, 30.0)
	orig.x = clamp(orig.x, -50.0, 50.0)
	camera.transform.origin = orig
	
func _on_ActivateEnemies_body_entered(body):
	if body.is_in_group('enemy'):
		if body.has_method('activate'):
			body.activate()

func _on_ActivateEnemies_body_exited(body):
	if body.is_in_group('enemy'):
		if body.has_method('deactivate'):
			body.deactivate()
	
func find_sight_location():
	var one_pos = camera.unproject_position(sight_one.global_transform.origin)
	var two_pos = camera.unproject_position(sight_two.global_transform.origin)
	
	emit_signal("update_sights", one_pos, two_pos)
	
func align_radar():
	radar_camera.global_transform.origin = radar_position.global_transform.origin
	
func _fire_bullet(orig, direction, bullet, target=null):
	var a = bullet.instance()
	if target:
		a.target = target
	a.transform.basis = direction
	a.transform.origin = orig
	bullet_container.add_child(a)
	
func do_a_barrel_roll():
	barrel_roll_finished = z_rot + 360
	barrel_roll = true
	