extends HBoxContainer

onready var gm = $"/root/GameManager"

export var player_id = 0

func _ready():
	gm.connect("player_inventory_updated", self, "on_inventory_updated")

func on_inventory_updated(player_id):
	if self.player_id != player_id:
		return
	
	for child in get_children():
		child.queue_free()
	
	var inventory = gm.get_inventory(player_id)
	for item_type in inventory.keys():
		if item_type == "bomb":
			continue
		var count = inventory[item_type]
		if count <= 0:
			continue
			
		var texture_rect = TextureRect.new()
		texture_rect.texture = load("res://Assets/UI/" + item_type + ".png")
		texture_rect.expand = true
		texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
		add_child(texture_rect)
		texture_rect.rect_size = Vector2(32, 32)
		texture_rect.rect_min_size = Vector2(32, 32)
	
