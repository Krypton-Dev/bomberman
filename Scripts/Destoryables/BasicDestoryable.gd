extends StaticBody2D

func damage(player_id, distance):
	print(distance)
	if(distance <= 1):
		queue_free()