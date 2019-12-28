extends Node2D
export var lifetime = 2
var elapsed = 0
var explosion = preload("res://Scripts/Bombs/Explosion.tscn")
var explosion_range = 3
export var grid_size = 128

var player_id = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	if elapsed >= lifetime:
		explode()

func explode():
	for x in range(0, explosion_range):
		if not explodeIfSpace(Vector2(-x, 0)):
			break
	
	for x in range(1, explosion_range):
		if not explodeIfSpace(Vector2(x, 0)):
			break
			
	for y in range(0, explosion_range):
		if not explodeIfSpace(Vector2(0, y)):
			break
			
	for y in range(1, explosion_range):
		if not explodeIfSpace(Vector2(0, -y)):
			break
			
	queue_free()	
	
	
func checkForCollision(layer, abs_pos):	
	var collisions = get_world_2d().direct_space_state.intersect_point(abs_pos, 1, [], layer)
	return len(collisions) > 0
	
func spawnExplosion(abs_pos):
	var explosionInstance = explosion.instance()
	explosionInstance.position = abs_pos
	explosionInstance.player_id = player_id
	get_parent().add_child(explosionInstance)
	
func explodeIfSpace(rel_pos):
	var new_pos = position + rel_pos * grid_size
	var collisionLayerBorders = 1	
	if checkForCollision(collisionLayerBorders, new_pos):
		return false
	if checkForCollision(4, new_pos):
		print("explosion collision w/ block @", new_pos)
		spawnExplosion(new_pos)
		return false
	spawnExplosion(new_pos)
	return true