extends KinematicBody

signal fire_bullet
# Sends a HUD STATE STRING [IDLE, CHARGED, TARGET_ACQUIRED]
signal update_sights_state
# Nodes
onready var charge_timer = $GunContainer/ChargeTimer
onready var radar_mesh = $RadarMesh
# Scenes
var basic_bullet = preload("res://Player/Weapons/BasicBullet.tscn")
var charged_bullet = preload("res://Player/Weapons/ChargedBullet.tscn")

# States
var charged = false
var ready_to_shoot = true
var target = null


func _ready():
	for node in get_tree().get_nodes_in_group("game"):
		connect("fire_bullet", node, "_fire_bullet")
	for node in get_tree().get_nodes_in_group("HUD"):
		connect("update_sights_state", node, "_update_sight_state")

func _physics_process(delta):
	get_input()
	if charged and target == null:
		check_sights()
	
	# Lock Radar Mesh
#	radar_mesh.global_transform.origin = Vector3(global_transform.origin.x, 0.0, global_transform.origin.z) 
	
func get_input():
	if Input.is_action_just_pressed('shoot'):
		charge_timer.start()
	
	if Input.is_action_just_released("shoot"):
		charge_timer.stop()
		if ready_to_shoot:
			ready_to_shoot = false
			$GunContainer/GunTimer.start()
			# Tell Root node where to add bullets
			var right_orig = $GunContainer/MuzzleRight.global_transform.origin
			var right_direction = transform.basis
			var left_orig = $GunContainer/MuzzleLeft.global_transform.origin
			var left_direction = transform.basis
			if charged:
				emit_signal("fire_bullet", right_orig, right_direction, charged_bullet, target)
				emit_signal("fire_bullet", left_orig, left_direction, charged_bullet, target)
				charged = false
				target = null
				emit_signal("update_sights_state", "IDLE")
			else:
				emit_signal("fire_bullet", right_orig, right_direction, basic_bullet)
				emit_signal("fire_bullet", left_orig, left_direction, basic_bullet)
	
func check_sights():
	if $Sight/RayCast.is_colliding():
		target = $Sight/RayCast.get_collider()
		emit_signal("update_sights_state", "TARGET_ACQUIRED", target)

func _on_GunTimer_timeout():
	ready_to_shoot = true

func _on_ChargeTimer_timeout():
	charged = true
	emit_signal("update_sights_state", "CHARGED")
