extends Path

var speed = 25

func _physics_process(delta):
	for child in get_child_count():
		get_child(child).offset += delta * speed