extends Node

#load obstacles before game starts

var stump_scene = preload("res://background/scenes/stump.tscn")
var rock_scene =  preload("res://background/scenes/rock.tscn")
var chicken_scene = preload("res://background/scenes/chicken_leg.tscn")
var barrel_scene = preload("res://background/scenes/barrel.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array = []
var chicken_heights := [200, 390]

# FIXED INTERNAL RESOLUTION (prevents distortion)
const GAME_WIDTH := 1280
const GAME_HEIGHT := 720

# game variables
const DUCK_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var difficulty
const MAX_DIFFCULTY : int = 2

var score : int = 0
var speed : float = 0.0
const SCORE_MODIFIER : int = 10
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var ground_height : float
var game_running : bool = false
var last_obs = null

var screen_size : Vector2

func _ready() -> void:
	screen_size = Vector2(GAME_WIDTH, GAME_HEIGHT)

	# FIXED: calculate true ground bottom Y
	var ground_sprite = $ground.get_node("Sprite2D")
	ground_height = $ground.position.y + (ground_sprite.texture.get_height() * ground_sprite.scale.y / 2)

	new_game()


func new_game():
	score = 0
	game_running = false
	show_score()
	difficulty = 0

	$duck.position = DUCK_START_POS
	$duck.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0, 0)

	$hud/startlabel.show()
	$hud/scorelabel.show()


func _process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED

		adjust_difficulty()
		generate_obs()

		$duck.position.x += speed
		$Camera2D.position.x += speed

		score += speed
		show_score()

		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.5:
			$ground.position.x += screen_size.x

		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$hud/startlabel.hide()


func generate_obs():
	if obstacles.is_empty() or (last_obs != null and last_obs.position.x < score + randi_range(300, 500)):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1

		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale

			var obs_x : int = screen_size.x + score + 100 + (i * 100)

			# FIXED: place obstacle exactly on the ground
			var obs_y : float = ground_height - (obs_height * obs_scale.y / 2)

			last_obs = obs
			add_obs(obs, obs_x, obs_y)

		if (randi() % 2) == 0:
			obs = chicken_scene.instantiate()
			var obs_x : int = screen_size.x + score + 100
			var obs_y : int = chicken_heights[randi() % chicken_heights.size()]
			add_obs(obs, obs_x, obs_y)


func add_obs(obs, x, y):
	obs.position = Vector2(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)


func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)


func hit_obs(body):
	if body.name == "duck":
		game_over()


func show_score():
	$hud/scorelabel.text = "SCORE: " + str(score / SCORE_MODIFIER)


func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFCULTY:
		difficulty = MAX_DIFFCULTY


func game_over():
	get_tree().paused = true
	game_running = false
