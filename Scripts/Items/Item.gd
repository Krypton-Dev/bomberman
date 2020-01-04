extends Node2D

enum ItemType {
	RANDOM,
	BOMB,
	NUKE
}	
export var lifetime = 10
var time_expired = 0
func get_enum_string(type):
	if type == ItemType.RANDOM:
		return "random"
	if type == ItemType.BOMB:
		return "bomb"
	if type == ItemType.NUKE:
		return "nuke"
		
	assert(false)
	

onready var sprite = $Sprite
onready var nm = $"/root/NetworkManager"
export(ItemType) var item_type = ItemType.RANDOM

func _process(delta):
	if not nm.is_network_game or nm.is_server:
		time_expired += delta
		if time_expired >= lifetime:
			rpc("remove")
			remove()

func _ready():
	var path = "res://Assets/Items/item_" + get_enum_string(item_type) + ".png"
	sprite.texture = load(path)
	
func get_enum_by_string (type: String):
	if type.to_lower() == "random":
		return ItemType.RANDOM
	if type.to_lower() == "bomb":
		return ItemType.BOMB
	if type.to_lower() == "nuke":
		return ItemType.NUKE
		
	assert(false)

func set_item_type (type: String):
	self.item_type = get_enum_by_string(type)

func on_item_collect(body):
	if not nm.is_network_game or nm.is_server:
		var gm = get_node("/root/GameManager")
		var item = get_enum_string(item_type)
		if item_type == ItemType.RANDOM:
			item = "bomb" # TODO: Implement
			
		if gm.check_free_space(body.player_id, item):
			gm.give_item(body.player_id, item)
			rpc("remove")
			remove()

remote func remove():
	queue_free()
