extends CharacterBody3D
# wasd / joystick
var inputvec : Vector2
# player speed
var speed : float = 3
# mouse movement
var mousevec : Vector2
# mouse sensitivity
var mousesens : float = 0.2
# if game is paused
var paused : bool = false
# acceleration due to gravity
var gravity : float = .2
var jumpheight : float = 8
# runs continuously
func _process(delta):
	playermovement()
	pause()
	jumper()
# movement code
func playermovement():
	# if the game isn't paused
	if !paused:
		# capture w, a, s, d or joysticks
		inputvec = Input.get_vector("left", "right", "forward", "back")
		# translate the captured direction to the proper axis of player
		var direction = (transform.basis * Vector3(inputvec.x, 0, inputvec.y)).normalized()
		# move sideways
		velocity.x = direction.x * speed
		# move forward and back
		velocity.z = direction.z * speed
		# when space is pressed and the player is on something
		if Input.is_action_just_pressed("up") and is_on_floor():
			# jump
			velocity.y += gravity + jumpheight
		# if the player is floating
		if !is_on_floor():
			# fall
			velocity.y -= gravity
		# tell godot to use the velocity vector to interpolate player motion
		move_and_slide()
# runs on input
func _input(event):
	# camera movement with mouse
	if event is InputEventMouseMotion and !paused:
		# rotate the player left and right
		rotate_y(-deg_to_rad(event.relative.x) * mousesens)
		# rotate camera up and down
		$view.rotate_x(-deg_to_rad(event.relative.y) * mousesens)
		# make sure player doesn't break their neck (rotating over 90 degrees)
		$view.rotation_degrees.x = clamp($view.rotation_degrees.x, -90, 90)
	# camera movement with joystick
# pausing the game
func pause():
	# when esc pressed
	if Input.is_action_just_pressed("pause"):
		# tell the player the game is paused
		paused = true
		# release the mouse cursor
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# if player clicks on window again while paused
	if paused and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# tell player game is unpaused
		paused = false
		# capture the mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# debug purposes
func jumper():
	if Input.is_action_just_pressed("jump"):
		print(position)
