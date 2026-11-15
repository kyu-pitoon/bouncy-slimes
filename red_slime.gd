extends CharacterBody2D


const ACCELERATION = 400.0
const JUMP_VELOCITY = -320.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	

	# Handle jump.
	if Input.is_action_just_pressed("jump_red") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left_red", "move_right_red")
	if direction:
		velocity.x += direction * ACCELERATION * delta
	else:
		velocity.x *= 0.8 * delta

	var prev_velocity_x = velocity.x
	var prev_velocity_y = velocity.y
	
	move_and_slide()
	
	if is_on_wall():
		# Reverse the horizontal velocity and apply bounce strength
		velocity.x = -prev_velocity_x * 0.9
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		var collider := collision.get_collider()

		# Check if the surface is a floor (normal points mostly upward)
		# OR if the object hit is another CharacterBody2D
		var is_floor_hit := normal.y < -0.7
		var is_character_hit := collider is CharacterBody2D

		if is_floor_hit or is_character_hit:
			# Only bounce if falling fast enough (prevents micro-bouncing when still)
			if prev_velocity_y > 120:
				velocity.y = -prev_velocity_y * 0.8
				break # Exit loop so multiple simultaneous tile hits don't double-trigger
