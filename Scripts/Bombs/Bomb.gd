extends Node2D

var elapsed = 0
var explosion = preload("res://Scripts/Bombs/Explosion.tscn")
var explosion_range = 3
var player_id = -1

onready var sprite = $AnimatedSprite
onready var gm = $"/root/GameManager"

export var grid_size = 128
export var lifetime = 2

func _ready():
	sprite.playing = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	var progress = elapsed / lifetime
	var animation_speed = pow(progress + 1, 3)
	sprite.speed_scale = animation_speed
	#var animation_speed = -pow(progress, 3) + 1
	#modulate = Color(1,1,1, alpha)
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
	
func spawnExplosion(abs_pos):
	var explosionInstance = explosion.instance()
	explosionInstance.position = abs_pos
	explosionInstance.player_id = player_id
	get_parent().add_child(explosionInstance)
	
func explodeIfSpace(rel_pos):
	var new_pos = position + rel_pos * grid_size
	# check for static walls
	var collisionLayerBorders = 1	
	if gm.check_for_collision(collisionLayerBorders, new_pos):
		return false # stop spreading
		
	spawnExplosion(new_pos)
		
	# check for pickable items
	var collisionLayerItems = 2	
	var items = gm.get_collisions(collisionLayerItems, new_pos, true, false, 5)
	if not items.empty():
		for item in items:
			item["collider"].queue_free()
		return true # continiue spreading
	
	# check for destroyables
	if gm.check_for_collision(4, new_pos):
		print("explosion collision w/ block @", new_pos)		
		return false # stop spreading
	
	return true