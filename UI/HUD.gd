extends CanvasLayer

onready var sight_near = $SightNear
onready var sight_far = $SightFar
onready var Hud_Anim = $HudAnim
var camera


# Sights States
#var states = ["IDLE", "CHARGED", "TARGET_ACQUIRED"]
var current_state = null
var sight_far_target = null

# Colors
var green = Color(0.215686, 0.87451, 0.188235)
var yellow = Color(0.929412, 0.929412, 0.094118)
var red = Color(0.921053, 0.097142, 0.097142)

func _ready():
	_update_sight_state("IDLE")
	for node in get_tree().get_nodes_in_group('camera'):
		camera = node
		
	# From the GameNode(PathTest)
func _update_sights(one, two):
	sight_near.position = one
	if sight_far_target != null:
		sight_far.position = camera.unproject_position(sight_far_target.global_transform.origin)
	else:
		sight_far.position = two
	
	# New state is a string from the Player
func _update_sight_state(new_state, target=null):
	sight_far_target = target
	current_state = new_state
	match current_state:
		"IDLE":
			sight_near.modulate = green
			sight_far.modulate = green
			Hud_Anim.play("Idle")
		
		"CHARGED":
			sight_near.modulate = yellow
			sight_far.modulate = red
			Hud_Anim.play("Charged")
		
		"TARGET_ACQUIRED":
			sight_near.modulate = yellow
			sight_far.modulate = red
			if Hud_Anim.current_animation != "Target_Acquired":
				Hud_Anim.play("Target_Acquired")
		