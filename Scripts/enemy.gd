extends CharacterBody2D
var DeathIndex = 2 #deprecated (Evan's code)
var max_health = 100
var speed = 200
var stunned = false
var player : Object
var targeting_player = false
var target_player_distance = 1500

func _ready():
	player = get_parent().get_node("Player")

func _process(_delta):
	#position += (Player.position - position) / 50
	#look_at(Player.position)
	if !stunned:
		if targeting_player: set_velocity(Vector2(speed, 0).rotated(get_angle_to(player.position)))
		else: set_velocity(Vector2(speed, 0).rotated(get_angle_to(Vector2.ZERO))) #Garden is at 0,0
		move_and_slide()
		var collision = get_last_slide_collision()
		if collision:
			if collision.get_collider().has_method("touch_zombie"):
				collision.get_collider().call("touch_zombie") 
				stunned = true
				print("Stunned")
				$StunTimer.start()
	$Sprite2D.flip_h = velocity.x > 0
	if player.position.distance_to(position) <= target_player_distance:
		targeting_player = true
	
	
func hit(damage : float):
	max_health -= damage
	if max_health <= 0:
		die()
	$Sprite2D.modulate = Color(1,0,0)
	$FlashColorTimer.start()
	
		
"""
func _on_Area2D_body_entered(body):
	if "Bullet" in body.name:
		DeathIndex -= 1
		
	if DeathIndex == 0:
		queue_free()
"""


func die():
	queue_free()

func _on_flash_color_timer_timeout():
	$Sprite2D.modulate = Color(1,1,1)


func _on_stun_timer_timeout():
	stunned = false
