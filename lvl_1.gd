extends Node3D
# if the current plane is the parallel or not
var turned : bool = false
# time for interpolation purposes
var t : float
# tell _process if the level is rotating
var rotating : bool = false
# rotation speed of the level when jumping between parallels
var rotationspeed : float = 100
# if the level is rotated or not
var rotated : bool = false
# if this is the player's first jump
var firstjump : bool = true
# add the parallel level
var parallelscene = preload("res://lvl1parallel.tscn")
var parallel = parallelscene.instantiate()
# start the jump process
var jumpstarted : bool
# runs at start
func _ready():
	# capture mouse for camera movement purposes
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# make label invisible
	$impossibility.visible = false
# runs continuously
func _process(delta):
	# for interpolation purposes
	t += delta
	# rotate the level
	# if the level is currently rotated (parallel), slowly increment to the level rotation until it's 180
	if rotated and $level.rotation_degrees.z <= 180 and rotating:
		$level.rotation_degrees.z += delta * rotationspeed
	# if the level is currently not rotated, slowly decrement to the level rotation until it's 0
	if !rotated and $level.rotation_degrees.z >= 0 and rotating:
		$level.rotation_degrees.z -= delta * rotationspeed
	# only show label if player near and on first jump
	for x in $impossibility/Area3D.get_overlapping_bodies():
		if x.name == "player" and !jumpstarted:
			$impossibility.visible = true
	# set engine physics and functions and player gravity back to regular values after jump
	if jumpstarted and $player.is_on_floor() and $Timer.is_stopped():
		Engine.time_scale = 1
		$player.gravity = .2
	# once jump started, slowly increment until it's fully bright
	if jumpstarted and $WorldEnvironment.get_environment().background_energy_multiplier <= 1: 
		$WorldEnvironment.get_environment().background_energy_multiplier += delta/2
# runs on user input
func _input(event):
	# activate 4D teleportation
	if event is InputEventKey:
		# when user presses J key
		if Input.is_action_just_pressed("jump"):
			# if the level isn't already in parallel
			if !rotated:
				# the level is now current
				rotated = true
				# debug purposes
				print("tping to parallel")
				# add upwards velocity to player so that when the rotation is done, player actually lands on the platform, not the void
				$player.velocity.y += 10
			# and if the level is in parallel
			elif rotated:
				# set level to current
				rotated = false
				# debug purposes
				print("tping back")
				# add more upwards velocity, because apparently counterclockwise rotation angle is different
				$player.global_transform.origin.y += 20
			# debug purposes
			print("rotating")
			# tell the functions in the _process(delta) that the level is undergoing rotation
			rotating = true
		# the first jump
		if Input.is_action_just_pressed("jump") and firstjump:
			# instantiate the parallel universe
			$level.add_child(parallel)
			# place it above
			parallel.transform.origin.y = 5
			# tell the level that the jump has started
			jumpstarted = true
			# play music
			$Choraleplayer.play()
			# find the J label and remove it
			for x in get_children():
				if "Label3D2" in x.name:
					x.free()
			# start the timeout timer
			$Timer.start()
			# set the phyiscs and processes speed to be 20x slower 
			Engine.time_scale = 0.05
			# set player gravity to be 20x less
			$player.gravity = 0.01
			# set the world to be dark
			$WorldEnvironment.get_environment().background_energy_multiplier = 0.01
			# hide the "make no attempt to solve" label
			$impossibility.visible = false
