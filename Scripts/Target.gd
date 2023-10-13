extends StaticBody2D


func hit(damage : float):
	print("target hit for " + str(damage) + " damage")
	$Sprite2D.modulate = Color(1,0,0)
	$FlashColorTimer.start()


func _on_flash_color_timer_timeout():
	$Sprite2D.modulate = Color(1,1,1)
