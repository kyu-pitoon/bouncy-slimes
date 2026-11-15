extends Node2D

var p1: CharacterBody2D # Blue Slime (WASD)
var p2: CharacterBody2D # Red Slime (Arrow Keys)
var camera: Camera2D

var p1_score = 0
var p2_score = 0

var p1_at_top = false
var p2_at_top = false

var time_elapsed = 0.0
var timer_label: Label
var gem_label: Label
var height_label: Label

# Physics constants
const GRAVITY = 1100.0
const MOVE_SPEED = 300.0
const JUMP_FORCE = -520.0

func _ready():
	setup_tower()

func setup_tower():
	for child in get_children():
		child.queue_free()

	p1_score = 0
	p2_score = 0
	p1_at_top = false
	p2_at_top = false
	time_elapsed = 0.0

	# 1. Background (Tall Vertical Shaft)
	var bg = ColorRect.new()
	bg.size = Vector2(1152, 3000)
	bg.position = Vector2(0, -2352)
	bg.color = Color(0.06, 0.06, 0.12)
	add_child(bg)

	# 2. Camera that tracks players upwards
	camera = Camera2D.new()
	camera.position = Vector2(576, 324)
	camera.zoom = Vector2(1.0, 1.0)
	add_child(camera)
	camera.make_current()

	# 3. Canvas Layer for UI (Stays locked on screen while climbing)
	var canvas = CanvasLayer.new()
	add_child(canvas)

	timer_label = Label.new()
	timer_label.position = Vector2(30, 20)
	timer_label.add_theme_font_size_override("font_size", 22)
	timer_label.add_theme_color_override("font_color", Color.CYAN)
	canvas.add_child(timer_label)

	gem_label = Label.new()
	gem_label.position = Vector2(30, 55)
	gem_label.add_theme_font_size_override("font_size", 18)
	gem_label.add_theme_color_override("font_color", Color.GOLD)
	canvas.add_child(gem_label)
	update_ui()

	height_label = Label.new()
	height_label.position = Vector2(900, 20)
	height_label.add_theme_font_size_override("font_size", 22)
	height_label.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	canvas.add_child(height_label)

	var status = Label.new()
	status.text = "P1: WASD (Blue Slime) | P2: ARROWS (Red Slime)\nClimb together to the top of the tower!"
	status.position = Vector2(30, 580)
	status.add_theme_font_size_override("font_size", 15)
	status.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	canvas.add_child(status)

	# 4. Build Tower Architecture
	create_platform(Vector2(576, 620), Vector2(1152, 40), Color(0.2, 0.2, 0.3))

	# Tower Walls
	create_platform(Vector2(20, -1000), Vector2(40, 4000), Color(0.15, 0.15, 0.22))
	create_platform(Vector2(1132, -1000), Vector2(40, 4000), Color(0.15, 0.15, 0.22))

	# --- SECTION 1: Lower Climb ---
	create_platform(Vector2(300, 480), Vector2(250, 22), Color(0.3, 0.25, 0.45))
	create_platform(Vector2(850, 420), Vector2(250, 22), Color(0.3, 0.25, 0.45))
	create_gem(Vector2(300, 430), "p1")
	create_gem(Vector2(850, 370), "p2")

	# --- SECTION 2: Mid Climb ---
	create_platform(Vector2(576, 300), Vector2(200, 22), Color(0.3, 0.25, 0.45))
	create_slime_pad(Vector2(576, 595), Vector2(100, 16), -750)
	create_hazard(Vector2(576, 610), Vector2(300, 20), Color.RED, "lava")

	create_platform(Vector2(250, 150), Vector2(200, 22), Color(0.35, 0.3, 0.5))
	create_platform(Vector2(900, 80), Vector2(200, 22), Color(0.35, 0.3, 0.5))
	create_gem(Vector2(250, 100), "p1")
	create_gem(Vector2(900, 30), "p2")

	# --- SECTION 3: High Climb ---
	create_platform(Vector2(576, -80), Vector2(180, 22), Color(0.4, 0.3, 0.55))
	create_slime_pad(Vector2(576, 95), Vector2(80, 14), -850)

	create_platform(Vector2(300, -250), Vector2(160, 22), Color(0.4, 0.3, 0.55))
	create_platform(Vector2(800, -350), Vector2(160, 22), Color.DARK_VIOLET)
	create_gem(Vector2(300, -300), "p1")
	create_gem(Vector2(800, -400), "p2")

	# --- SECTION 4: Peak (Summit) ---
	create_platform(Vector2(576, -550), Vector2(300, 26), Color.REBECCA_PURPLE)

	create_door(Vector2(516, -610), Color.DODGER_BLUE, "p1")
	create_door(Vector2(636, -610), Color.CRIMSON, "p2")

	# 5. Spawn Players
	p1 = create_slime(Vector2(200, 540), Color.DODGER_BLUE, "BlueSlime", "acid")
	p2 = create_slime(Vector2(300, 540), Color.CRIMSON, "RedSlime", "lava")

func create_slime(pos: Vector2, col: Color, p_name: String, safe_type: String) -> CharacterBody2D:
	var body = CharacterBody2D.new()
	body.name = p_name
	body.position = pos
	body.set_meta("safe_hazard", safe_type)
	add_child(body)

	var rect = ColorRect.new()
	rect.size = Vector2(40, 34)
	rect.position = Vector2(-20, -17)
	rect.color = col
	body.add_child(rect)

	var eye1 = ColorRect.new()
	eye1.size = Vector2(8, 10)
	eye1.position = Vector2(-12, -12)
	eye1.color = Color.WHITE
	body.add_child(eye1)

	var eye2 = ColorRect.new()
	eye2.size = Vector2(8, 10)
	eye2.position = Vector2(4, -12)
	eye2.color = Color.WHITE
	body.add_child(eye2)

	var cshape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 34)
	cshape.shape = shape
	body.add_child(cshape)
	return body

func create_platform(pos: Vector2, size: Vector2, col: Color):
	var wall = StaticBody2D.new()
	wall.position = pos
	add_child(wall)

	var rect = ColorRect.new()
	rect.size = size
	rect.position = -size / 2
	rect.color = col
	wall.add_child(rect)

	var cshape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	cshape.shape = shape
	wall.add_child(cshape)

func create_slime_pad(pos: Vector2, size: Vector2, bounce_power: float):
	var pad = Area2D.new()
	pad.position = pos
	add_child(pad)

	var rect = ColorRect.new()
	rect.size = size
	rect.position = -size / 2
	rect.color = Color.ORANGE
	pad.add_child(rect)

	var cshape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	cshape.shape = shape
	pad.add_child(cshape)

	pad.body_entered.connect(func(body):
		if body is CharacterBody2D:
			body.velocity.y = bounce_power
	)

func create_hazard(pos: Vector2, size: Vector2, col: Color, _h_type: String):
	var haz = Area2D.new()
	haz.position = pos
	add_child(haz)

	var rect = ColorRect.new()
	rect.size = size
	rect.position = -size / 2
	rect.color = col
	haz.add_child(rect)

	var cshape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	cshape.shape = shape
	haz.add_child(cshape)

	haz.body_entered.connect(func(body):
		if body is CharacterBody2D:
			body.position = Vector2(250, 540)
			body.velocity = Vector2.ZERO
	)

func create_gem(pos: Vector2, gem_type: String):
	var gem = Area2D.new()
	gem.position = pos
	add_child(gem)

	var rect = ColorRect.new()
	rect.size = Vector2(22, 22)
	rect.position = Vector2(-11, -11)
	rect.color = Color.DODGER_BLUE if gem_type == "p1" else Color.CRIMSON
	gem.add_child(rect)

	var cshape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(22, 22)
	cshape.shape = shape
	gem.add_child(cshape)

	gem.body_entered.connect(func(body):
		if body == p1 and gem_type == "p1":
			p1_score += 1
			gem.queue_free()
			update_ui()
		elif body == p2 and gem_type == "p2":
			p2_score += 1
			gem.queue_free()
			update_ui()
	)

func create_door(pos: Vector2, col: Color, door_type: String):
	var door = Area2D.new()
	door.position = pos
	add_child(door)

	var rect = ColorRect.new()
	rect.size = Vector2(45, 65)
	rect.position = Vector2(-22.5, -32.5)
	rect.color = col
	door.add_child(rect)

	var cshape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(45, 65)
	cshape.shape = shape
	door.add_child(cshape)

	door.body_entered.connect(func(body):
		if body == p1 and door_type == "p1" and p1_score >= 3:
			p1_at_top = true
		elif body == p2 and door_type == "p2" and p2_score >= 3:
			p2_at_top = true
	)
	door.body_exited.connect(func(body):
		if body == p1 and door_type == "p1": p1_at_top = false
		if body == p2 and door_type == "p2": p2_at_top = false
	)

func _physics_process(delta):
	if not p1 or not p2:
		return

	time_elapsed += delta
	if timer_label:
		timer_label.text = "Time: " + "%.1f" % time_elapsed + "s"

	# Smooth Camera tracking using explicit float values (-500.0 and 324.0)
	var midpoint_y = (p1.position.y + p2.position.y) / 2.0
	camera.position.y = lerp(camera.position.y, float(clamp(midpoint_y, -500.0, 324.0)), delta * 5.0)

	var current_height = max(0, int(540 - (p1.position.y + p2.position.y) / 2))
	if height_label:
		height_label.text = "Height: " + str(current_height) + "m"

	# P1 Controls (WASD)
	var p1_dir = 0
	if Input.is_key_pressed(KEY_A): p1_dir -= 1
	if Input.is_key_pressed(KEY_D): p1_dir += 1
	p1.velocity.x = p1_dir * MOVE_SPEED

	if not p1.is_on_floor():
		p1.velocity.y += GRAVITY * delta
	elif Input.is_key_pressed(KEY_W):
		p1.velocity.y = JUMP_FORCE
	p1.move_and_slide()

	# P2 Controls (Arrows)
	var p2_dir = 0
	if Input.is_key_pressed(KEY_LEFT): p2_dir -= 1
	if Input.is_key_pressed(KEY_RIGHT): p2_dir += 1
	p2.velocity.x = p2_dir * MOVE_SPEED

	if not p2.is_on_floor():
		p2.velocity.y += GRAVITY * delta
	elif Input.is_key_pressed(KEY_UP):
		p2.velocity.y = JUMP_FORCE
	p2.move_and_slide()

	if p1_at_top and p2_at_top:
		var final_score = max(100, 5000 - int(time_elapsed * 20))
		if timer_label:
			timer_label.text = "VICTORY! SCORE: " + str(final_score)
		p1.queue_free()
		p2.queue_free()

func update_ui():
	if gem_label:
		gem_label.text = "Blue Gems: " + str(p1_score) + "/3  |  Red Gems: " + str(p2_score) + "/3"
