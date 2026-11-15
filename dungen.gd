extends Node2D

var p1: CharacterBody2D # Green Slime (WASD)
var p2: CharacterBody2D # Pink Slime (Arrows)
var current_level = 1

var p1_score = 0
var p2_score = 0
var p1_target_gems = 3
var p2_target_gems = 3

var p1_at_door = false
var p2_at_door = false

# Timer & Score tracking
var time_elapsed = 0.0
var final_score = 0

var level_label: Label
var gem_label: Label
var timer_label: Label
var status_label: Label

# Physics constants
const GRAVITY = 1150.0
const MOVE_SPEED = 300.0
const JUMP_FORCE = -540.0

func _ready():
	load_level(current_level)

func update_ui_text():
	if gem_label:
		gem_label.text = "Green Gems: " + str(p1_score) + "/" + str(p1_target_gems) + "  |  Pink Gems: " + str(p2_score) + "/" + str(p2_target_gems)

func load_level(lvl):
	for child in get_children():
		child.queue_free()
		
	current_level = lvl
	p1_score = 0
	p2_score = 0
	p1_at_door = false
	p2_at_door = false
	time_elapsed = 0.0
	
	# 1. Dark Temple Background
	var bg = ColorRect.new()
	bg.size = Vector2(1152, 648)
	bg.color = Color.DARK_SLATE_GRAY
	add_child(bg)
	
	# UI Banners
	level_label = Label.new()
	level_label.text = "LEVEL " + str(current_level) + " / 2: TEMPLE SLIME CO-OP"
	level_label.position = Vector2(30, 20)
	level_label.add_theme_font_size_override("font_size", 24)
	level_label.add_theme_color_override("font_color", Color.GOLD)
	add_child(level_label)
	
	gem_label = Label.new()
	gem_label.position = Vector2(30, 55)
	gem_label.add_theme_font_size_override("font_size", 18)
	gem_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(gem_label)
	update_ui_text()
	
	timer_label = Label.new()
	timer_label.position = Vector2(920, 20)
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color.CYAN)
	add_child(timer_label)
	
	status_label = Label.new()
	status_label.text = "P1: WASD (Green Slime) | P2: ARROWS (Pink Slime)\nFast time = Higher Score Bonus! Collect ALL gems to unlock doors."
	status_label.position = Vector2(30, 580)
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	add_child(status_label)

	# 2. Fireboy & Watergirl Style Temple Platforms
	create_temple_platform(Vector2(576, 630), Vector2(1152, 36))
	
	if current_level == 1:
		p1_target_gems = 3
		p2_target_gems = 3
		
		create_temple_platform(Vector2(250, 490), Vector2(220, 24))
		create_temple_platform(Vector2(900, 460), Vector2(260, 24))
		create_temple_platform(Vector2(576, 340), Vector2(280, 24))
		
		create_slime_pad(Vector2(576, 610), Vector2(100, 16), -750)
		
		create_hazard(Vector2(550, 600), Vector2(120, 24), Color.GREEN, "acid")
		create_hazard(Vector2(150, 600), Vector2(100, 24), Color.RED, "lava")
		
		create_gem(Vector2(250, 430), Color.GREEN, "p1")
		create_gem(Vector2(900, 400), Color.MAGENTA, "p2")
		create_gem(Vector2(576, 270), Color.GREEN, "p1")
		create_gem(Vector2(500, 580), Color.MAGENTA, "p2")
		create_gem(Vector2(950, 580), Color.GREEN, "p1")
		create_gem(Vector2(100, 500), Color.MAGENTA, "p2")
		
		create_character_door(Vector2(1050, 530), Color.GREEN, "p1")
		create_character_door(Vector2(980, 530), Color.MAGENTA, "p2")
		
	elif current_level == 2:
		p1_target_gems = 4
		p2_target_gems = 4
		
		create_temple_platform(Vector2(200, 500), Vector2(180, 24))
		create_temple_platform(Vector2(950, 440), Vector2(220, 24))
		create_temple_platform(Vector2(576, 380), Vector2(240, 24))
		create_temple_platform(Vector2(350, 260), Vector2(200, 24))
		
		create_slime_pad(Vector2(576, 610), Vector2(120, 16), -800)
		
		create_hazard(Vector2(600, 600), Vector2(250, 24), Color.GREEN, "acid")
		create_hazard(Vector2(200, 600), Vector2(120, 24), Color.RED, "lava")
		
		create_gem(Vector2(200, 440), Color.GREEN, "p1")
		create_gem(Vector2(950, 380), Color.MAGENTA, "p2")
		create_gem(Vector2(576, 310), Color.GREEN, "p1")
		create_gem(Vector2(350, 200), Color.MAGENTA, "p2")
		create_gem(Vector2(1000, 580), Color.GREEN, "p1")
		create_gem(Vector2(100, 550), Color.MAGENTA, "p2")
		create_gem(Vector2(500, 550), Color.GREEN, "p1")
		create_gem(Vector2(700, 550), Color.MAGENTA, "p2")
		
		create_character_door(Vector2(1050, 370), Color.GREEN, "p1")
		create_character_door(Vector2(980, 370), Color.MAGENTA, "p2")

	# 3. Spawn Slimes with Eyes
	p1 = create_slime_character(Vector2(70, 540), Color.GREEN, "GreenSlime", "acid")
	p2 = create_slime_character(Vector2(120, 540), Color.MAGENTA, "PinkSlime", "lava")

func create_slime_character(pos: Vector2, col: Color, p_name: String, safe_type: String) -> CharacterBody2D:
	var body = CharacterBody2D.new()
	body.name = p_name
	body.position = pos
	body.set_meta("safe_hazard", safe_type)
	add_child(body)
	
	var rect = ColorRect.new()
	rect.size = Vector2(40, 36)
	rect.position = Vector2(-20, -18)
	rect.color = col
	body.add_child(rect)
	
	# Left Eye
	var eye_l = ColorRect.new()
	eye_l.size = Vector2(8, 10)
	eye_l.position = Vector2(-12, -12)
	eye_l.color = Color.WHITE
	body.add_child(eye_l)
	
	var pupil_l = ColorRect.new()
	pupil_l.size = Vector2(4, 5)
	pupil_l.position = Vector2(-10, -10)
	pupil_l.color = Color.BLACK
	body.add_child(pupil_l)
	
	# Right Eye
	var eye_r = ColorRect.new()
	eye_r.size = Vector2(8, 10)
	eye_r.position = Vector2(4, -12)
	eye_r.color = Color.WHITE
	body.add_child(eye_r)
	
	var pupil_r = ColorRect.new()
	pupil_r.size = Vector2(4, 5)
	pupil_r.position = Vector2(6, -10)
	pupil_r.color = Color.BLACK
	body.add_child(pupil_r)
	
	var cshape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 36)
	cshape.shape = shape
	body.add_child(cshape)
	return body

func create_temple_platform(pos: Vector2, size: Vector2):
	var wall = StaticBody2D.new()
	wall.position = pos
	add_child(wall)
	
	var rect = ColorRect.new()
	rect.size = size
	rect.position = -size / 2
	rect.color = Color.DARK_VIOLET
	wall.add_child(rect)
	
	var top_line = ColorRect.new()
	top_line.size = Vector2(size.x, 5)
	top_line.position = Vector2(-size.x / 2, -size.y / 2)
	top_line.color = Color.REBECCA_PURPLE
	wall.add_child(top_line)
	
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

func create_hazard(pos: Vector2, size: Vector2, col: Color, h_type: String):
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
			var safe = body.get_meta("safe_hazard")
			if h_type != safe:
				body.position = Vector2(70, 540)
				body.velocity = Vector2.ZERO
	)

func create_gem(pos: Vector2, col: Color, gem_type: String):
	var gem = Area2D.new()
	gem.position = pos
	add_child(gem)
	
	var rect = ColorRect.new()
	rect.size = Vector2(22, 22)
	rect.position = Vector2(-11, -11)
	rect.color = col
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
			update_ui_text()
		elif body == p2 and gem_type == "p2":
			p2_score += 1
			gem.queue_free()
			update_ui_text()
	)

func create_character_door(pos: Vector2, col: Color, door_type: String):
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
		if body == p1 and door_type == "p1" and p1_score >= p1_target_gems:
			p1_at_door = true
		elif body == p2 and door_type == "p2" and p2_score >= p2_target_gems:
			p2_at_door = true
	)
	
	door.body_exited.connect(func(body):
		if body == p1 and door_type == "p1":
			p1_at_door = false
		elif body == p2 and door_type == "p2":
			p2_at_door = false
	)

func _physics_process(delta):
	if not p1 or not p2:
		return
		
	time_elapsed += delta
	if timer_label:
		timer_label.text = "Time: " + "%.1f" % time_elapsed + "s"
		
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

	if p1_at_door and p2_at_door:
		var level_score_bonus = max(100, 2000 - int(time_elapsed * 25))
		final_score += level_score_bonus
		
		current_level += 1
		if current_level > 2:
			level_label.text = "VICTORY! FINAL SCORE: " + str(final_score)
			timer_label.text = "COMPLETE!"
			p1.queue_free()
			p2.queue_free()
		else:
			load_level(current_level)
