extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

# Velocidad del jugador
@export var speed := 200.0
var idle = 0
func _process(delta):
	# Movimiento del jugador con input de teclado
	var direction = Vector2.ZERO
	if Input.is_action_pressed("Right"):
		direction.x += 1
	if Input.is_action_pressed("Left"):
		direction.x -= 1
	if Input.is_action_pressed("Down"):
		direction.y += 1
	if Input.is_action_pressed("Up"):
		direction.y -= 1

	# Mover al jugador en la dirección indicada con una velocidad constante
	velocity = direction.normalized() * speed
	move_and_slide()
	
	if direction.x != 0 or direction.y != 0:
		animated_sprite.play()
		if direction.x > 0:
			animated_sprite.animation = "WalkR"
			idle = 0
		elif direction.x < 0:
			animated_sprite.animation = "WalkL"
			idle = 1
		elif direction.y > 0:
			animated_sprite.animation = "WalkD"
			idle = 2
		elif direction.y < 0:
			animated_sprite.animation = "WalkU"
			idle = 3
	else:
		match idle:
			0:
				animated_sprite.animation = "idleRight"
			1:
				animated_sprite.animation = "idleLeft"
			2:
				animated_sprite.animation = "idleDown"
			3:
				animated_sprite.animation = "idleUp"
