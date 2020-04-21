extends Spatial

onready var bullet_container = $BulletContainer
# Enemy
var basic_enemy = preload("res://Enemies/BasicEnemy.tscn")
onready var enemy_container = $EnemyContainer
# Enemy Bullet
var enemy_bullet = preload("res://Enemies/EnemyBullet.tscn")

enum ground_tiles {grass, dirt, snow_cap, water}

var ground_size = Vector2(20, 40)
var next_chunk_coord = Vector3(0,0,0)
var noise

onready var map = $World/Ground
onready var player = $Player

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 10
	
	create_chunk(ground_size.x, ground_size.y)
	$EnemyContainer/SpawnEnemy.start()
	
func _physics_process(delta):
	var next_trigger = (next_chunk_coord.z * 10) - (ground_size.y * 10)
	if player.translation.z > next_trigger:
		create_chunk(ground_size.x, ground_size.y)
		
func create_chunk(chunk_width, chunk_length):
	for x in chunk_width:
		for z in chunk_length:
			var final = 0
			var y = 1
			var a = noise.get_noise_2d(x,z + next_chunk_coord.z)
			if a < 0.04:
				final = ground_tiles.water
			elif a >= 0.04 and a < 0.3:
				final = ground_tiles.grass
				y = 2
			elif a >= 0.3 and a < 0.6:
				final = ground_tiles.dirt
				y = 3
			else:
				final = ground_tiles.snow_cap
				y = 4
			for num in y:
				map.set_cell_item(x, y, z + next_chunk_coord.z, final)

	next_chunk_coord.z += chunk_length
	
func _fire_bullet(orig, direction, bullet):
	var a = bullet.instance()
	a.transform.basis = direction
	a.transform.origin = orig
	bullet_container.add_child(a)

func _on_SpawnEnemy_timeout():
	var a = basic_enemy.instance()
	var num_x = rand_range(0.0, ground_size.x)
	var num_z = rand_range(-5.0, 5.0)
	a.transform.origin = Vector3(next_chunk_coord.x + num_x, next_chunk_coord.y + 5, next_chunk_coord.z + num_z) * 10
	enemy_container.add_child(a)