extends CharacterBody2D


const GRAVITY = 4200
const JUMP_SPEED = -1800

func _physics_process(delta):
	velocity.y+= GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$runcol.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y=JUMP_SPEED
			
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("duck")
				$runcol.disabled = true
			else:
				$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")
		
	move_and_slide()
