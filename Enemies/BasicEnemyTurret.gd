extends KinematicBody

# https://opengameart.org/content/rusted-metal-texture-pack
# https://opengameart.org/content/4096-chrome-peforated-heat-shield-pbr-textures

signal fire_bullet
var enemy_bullet = preload("res://Enemies/EnemyBullet.tscn")
onready var muzzle = $Ball/Muzzle
onready var ball = $Ball
onready var radar_mesh = $RadarMesh
var target


var active = false

var speed = 1500
var velocity = Vector3()

func _ready():
	for node in get_tree().get_nodes_in_group("game"):
		connect("fire_bullet", node, "_fire_bullet")
	var target_array = get_tree().get_nodes_in_group("player")
	target = target_array[0]
		
func _physics_process(delta):
	if active:
		aim()
	# Lock Radar Mesh
	radar_mesh.global_transform.origin = Vector3(global_transform.origin.x, 0.0, global_transform.origin.z) 

func aim():
	var desired_rotation = ball.global_transform.looking_at(target.global_transform.origin, Vector3(0,1,0))
	var a = Quat(ball.global_transform.basis.get_rotation_quat()).slerp(desired_rotation.basis.get_rotation_quat(), 0.02)
	ball.global_transform.basis = Basis(a)
#	set_transform(Transform(a, ball.transform.origin))

func activate():
	$ShootTimer.start()
	active = true
	
func deactivate():
	$ShootTimer.stop()
	active = false
	
func _on_Timer_timeout():
	var orig = muzzle.global_transform.origin
	var direction = muzzle.global_transform.basis
	emit_signal("fire_bullet", orig, direction, enemy_bullet)