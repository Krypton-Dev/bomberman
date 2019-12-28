extends Node2D

enum ItemType {
	RANDOM,
	BOMB
}	

func get_enum_string(type):
	if type == ItemType.RANDOM:
		return "random"
	if type == ItemType.BOMB:
		return "bomb"
		
	assert(false)
	

onready var sprite = $Sprite
export(ItemType) var item_type = ItemType.RANDOM

func _ready():
	var path = "res://Assets/Items/item_" + get_enum_string(item_type) + ".png"
	sprite.texture = load(path)
	


func on_item_collect(body):
	var gm = get_node("/root/GameManager")
	var item = get_enum_string(item_type)
	if item_type == ItemType.RANDOM:
		item = "bomb" # TODO: Implement
	
	gm.give_item(body.player_id, item)
	queue_free()
