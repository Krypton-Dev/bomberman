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
	
func get_enum_by_string (type: String):
	if type.to_lower() == "random":
		return ItemType.RANDOM
	if type.to_lower() == "bomb":
		return ItemType.BOMB
		
	assert(false)

func set_item_type (type: String):
	self.item_type = get_enum_by_string(type)

func on_item_collect(body):
	var gm = get_node("/root/GameManager")
	var item = get_enum_string(item_type)
	if item_type == ItemType.RANDOM:
		item = "bomb" # TODO: Implement
		
	if gm.check_free_space(body.player_id, item):
		gm.give_item(body.player_id, item)
		queue_free()
