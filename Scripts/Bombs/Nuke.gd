extends Bomb

onready var icon = $NukeIcon

var exploded = false

func _ready():
	._ready()
	lifetime = 15

func _process(delta):
	._process(delta)
	
	icon.rotation_degrees += delta * 180

func sort_positions(pos_a, pos_b):
	if Vector2.ZERO.distance_to(pos_a) < Vector2.ZERO.distance_to(pos_b):
		return true
	return false

func explode():	
	if exploded:
		return
		
	hide()
		
	exploded = true
	var positions = gm.get_map_tiles()
	var rel_positions = []
	for pos in positions:
		var rel_grid_pos = ((pos / grid_size) - (position / grid_size).floor()).floor()
		rel_positions.push_back(rel_grid_pos)
		
	rel_positions.sort_custom(self, "sort_positions")
	
	for rel_pos in rel_positions:
		if explodeIfSpace(rel_pos) != ExplosionStatus.STOP:
			yield(get_tree().create_timer(0.01), "timeout")
	
	queue_free()
