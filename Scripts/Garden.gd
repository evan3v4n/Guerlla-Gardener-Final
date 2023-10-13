extends StaticBody2D
var health = 500

func touch_zombie():
	health -= 15
	if health <= 0:
		print("GAME OVER")
