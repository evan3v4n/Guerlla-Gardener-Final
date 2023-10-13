extends CharacterBody2D
#hello
@export var speed : int
@export var camera_smooth_speed : int = 5 #px/s
var direction_facing
var move_input = Vector2.ZERO
var bullet = preload("res://Scenes/bullet.tscn")
var current_accuracy = 10
var muzzle_speed = 1600
var muzzle_global_position : Vector2
var gun_on_left_side : bool
#Gun stuff:
var max_ammo = 20
var ammo_left : int
var fire_time : float = 0.1 #Seconds
var fire_time_left : float = 0 #Time until the next round can be fired
var reloading = false
var reload_time : float = 2
var reload_time_left : float = 0

var sprint_multiplier = 4.5
var sprint_time = 0.35
var sprint_time_left : float = 0 
var sprinting = false
var sprint_direction = Vector2.ZERO
var sprint_cooldown = 1.5
var sprint_cooldown_left : float = 0
var health = 100

func _ready():
	$Camera2D.position_smoothing_speed = camera_smooth_speed
	ammo_left = max_ammo
	$SprintProgressBar.max_value = sprint_cooldown

func point_gun(): 
	direction_facing = get_angle_to(get_global_mouse_position())
	$Gun.rotation = direction_facing
	gun_on_left_side = abs(direction_facing) > PI/2
	$Gun/GunSprite.flip_v  = gun_on_left_side
	$PlayerSprite.flip_h = !gun_on_left_side
	
func get_movement_input():
	move_input.x = Input.get_axis("ui_left", "ui_right") #Each return a value from -1 to 1
	move_input.y = Input.get_axis("ui_up", "ui_down")
	if move_input.length() > 1:  move_input = move_input.normalized() #makes it a unit vector (the if is in case we use analog inputs and the move_input vector.length() < 1)
	if Input.is_action_just_pressed("sprint") and move_input != Vector2.ZERO and sprint_cooldown_left <= 0:
		sprint_direction = move_input.normalized()
		if sprint_time_left <= 0:
			sprinting = true
			$SprintTimer.start(sprint_time)
			sprint_cooldown_left = sprint_cooldown
	if sprinting:
		set_velocity(sprint_direction*sprint_multiplier*speed)
	else:
		set_velocity(move_input*speed)
		
	$SprintProgressBar.value = sprint_cooldown_left
	$SprintProgressBar.visible = sprint_cooldown_left > 0
		
	
func fire():
	$GunShotSound.play()
	ammo_left -= 1
	fire_time_left = fire_time
	var new_bullet = bullet.instantiate()
	new_bullet.position = $Gun/GunSprite/MuzzleFlipped.global_position if gun_on_left_side else $Gun/GunSprite/Muzzle.global_position
	if randi()%2: #flip a coin (to add or subtract angle for accuracy)
		new_bullet.rotation = direction_facing + randf() / current_accuracy #random integer divided by accuracy score
	else:
		new_bullet.rotation = direction_facing - randf() / current_accuracy
	new_bullet.speed = muzzle_speed
	get_parent().add_child(new_bullet)
	update_ammo_count_label()

func pull_trigger(): #What happens when trigger pulled (check if firing is possible)
	if ammo_left <= 0: 
		if !reloading: $PressRLabel.visible = true
		return #Maybe add a 'click' sound effect here
	if fire_time_left > 0: return
	if reloading: return
	fire()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fire_time_left = max(fire_time_left-delta, 0) #Decrease fire_time_left and reload_time_left to zero
	reload_time_left = max(reload_time_left-delta, 0)
	$ReloadingLabel.visible = reloading
	if reload_time_left <= 0 and reloading:
		reloading = false
		ammo_left = max_ammo
		update_ammo_count_label()
	$Camera2D.position = get_local_mouse_position() / 4
	point_gun() #towards mouse
	get_movement_input() #also sets velocity
	move_and_slide() #Inherited from KinematicBody2D
	if Input.is_action_pressed("fire_primary"):
		pull_trigger()
	if Input.is_action_just_pressed("reload"):
		reload()
	
	sprint_cooldown_left = max(sprint_cooldown_left - delta, 0)
		
func reload():
	reloading = true
	reload_time_left = reload_time 
	$PressRLabel.visible = false

func update_ammo_count_label():
	$AmmoCountLabel.text = "{0}/{1}".format([str(ammo_left), str(max_ammo)])


func _on_sprint_timer_timeout():
	sprinting = false
	
func touch_zombie():
	health -= 15
	if health <= 0:
		print("GAME OVER")
