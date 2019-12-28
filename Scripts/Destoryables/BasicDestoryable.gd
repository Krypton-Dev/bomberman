extends StaticBody2D

enum BlockType {
	DEFAULT
}

export(BlockType) var type = BlockType.DEFAULT
onready var gm = $"/root/GameManager"

func damage(player_id):
	gm.on_destoryable_destroyed(self, player_id)
	queue_free()