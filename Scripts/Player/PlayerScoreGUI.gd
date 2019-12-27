extends HSplitContainer

export var player_index = 0

onready var score = $Score
var gm = null

func _ready():
	gm = get_node("/root/GameManager")
	gm.connect("player_score_updated", self, "player_score_updated")

func player_score_updated():
	print("update player score ", player_index)
	var scoreValue = gm.get_score(player_index)
	score.text = str(scoreValue)