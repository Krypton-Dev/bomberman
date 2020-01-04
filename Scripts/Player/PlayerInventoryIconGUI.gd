extends HBoxContainer

export var empty_icon: Texture = null
export var filled_icon: Texture = null
export var item_name = ""
export var player_id = -1

var icons = []
var gm = null
onready var nm = $"/root/NetworkManager"

func _ready():
	for icon in get_children():
		icons.push_back(icon)
		icon.texture = empty_icon
		
	gm = get_node("/root/GameManager")
	gm.connect("player_inventory_updated", self, "on_player_inventory_update")
	nm.connect("refresh_inventory", self, "on_player_inventory_update")
	
	on_player_inventory_update(player_id)
	
	
func on_player_inventory_update(player_id):
	if player_id != self.player_id:
		return
		
	var count = gm.get_item_count(player_id, item_name)
	
	for i in range(icons.size()):
		if count - 1 >= i:
			icons[i].texture = filled_icon
		else:
			icons[i].texture = empty_icon
