extends CharacterBody2D

var speed : int
var damage : float = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	set_velocity(Vector2(speed,0).rotated(rotation))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(velocity*delta)
	if collision:
		if collision.get_collider().has_method("hit"):
			collision.get_collider().call("hit", damage)
		explode()
			
func explode():
	queue_free()
