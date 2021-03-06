extends KinematicBody2D


export var ACCELERATION = 600
export var MAX_SPEED = 750
export var ROLL_SPEED = 100
export var FRICTION = 1


enum {
	MOVE,
	FALL,
	ATTACK,
	HIT
}

var hearts = 4

var i = 0

var state = ATTACK
var velocity2 = Vector2.ZERO
var roll_vector = Vector2.DOWN
var init = false

onready var nav = $Engine/NavTerm
onready var player1 = $Engine/Player1
onready var player2 = $Engine/Player2
onready var engine = $Engine
onready var timer = $Timer
onready var gun = $Engine/Down
onready var animationPlayer = $Engine/Visible/AnimationPlayer
onready var animationPlayer2 = $Engine/Visible2/AnimationPlayer
var workable = false
var working = false
var prefix = ""

func _ready():
	randomize()



func _physics_process(delta):
	gun.getRotation(rad2deg(engine.transform.get_rotation()))
	if timer.is_stopped():
		init = true
	
	if workable:
		if !working && Input.is_action_just_pressed(prefix+"_swing"):
			working = true
			state = MOVE
			
		elif working && Input.is_action_just_pressed(prefix+"_swing"):
			state = ATTACK
			working = false
			nav.crash()
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		
	
func move_state(delta):
	if working:
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength(prefix+"_left") - Input.get_action_strength(prefix+"_right")
		input_vector.y = Input.get_action_strength(prefix+"_up") - Input.get_action_strength(prefix+"_down")

		input_vector = input_vector.normalized()

		
		if input_vector != Vector2.ZERO:
			##print(velocity2)
			###print(rad2deg(input_vector.angle()))
			animationPlayer.play("Pulse")
			animationPlayer2.play("Pulse")
			if rad2deg(engine.transform.get_rotation()) >= rad2deg(input_vector.angle()) - 4 && rad2deg(engine.transform.get_rotation()) <= rad2deg(input_vector.angle())+ 4:
				pass
				###print(rad2deg(input_vector.angle()))
			else:
				
				if rad2deg(input_vector.angle()) > rad2deg(engine.transform.get_rotation()):
					engine.rotate(.07)
					player1.rotate(-.07)
					player2.rotate(-.07)
					nav.rotate(-.07)
				elif rad2deg(engine.transform.get_rotation()) > 170 && rad2deg(input_vector.angle()) < -80:
					engine.rotate(.07)
					player1.rotate(-.07)
					player2.rotate(-.07)
					nav.rotate(-.07)
				else:
					engine.rotate(-.07)
					player1.rotate(.07)
					player2.rotate(.07)
					nav.rotate(.07)
			
			roll_vector = input_vector
			###print("Vector2" , input_vector, ",")
			velocity2 = velocity2.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
			#state = ROLL
		else:
			animationPlayer.play("StopStart")
			animationPlayer2.play("StopStart")
			###print("Vector2" , input_vector, ",")
			

			velocity2 = velocity2.move_toward(Vector2.ZERO, FRICTION * delta)
			#state = ATTACK
		
		move()
	else: 
		state = ATTACK
	

func attack_state(delta):
	velocity2 = velocity2
	velocity2 = velocity2.move_toward(Vector2.ZERO, FRICTION * delta)
	animationPlayer.play("StopStart")
	animationPlayer2.play("StopStart")
	move()

func move():
	##print(velocity2)
	velocity2 = move_and_slide(velocity2)

func crash():
	player1.crash()
	nav.crash()
	workable = false
	working = false
	state = ATTACK
	#print("crash")

func _on_Helm_area_entered(area):
	workable = true
	#print("helm on")
	if !working:
		prefix = area.name


func _on_Helm_area_exited(area):
	#print("turn off heml")
	workable = false


func _on_RightBounds_area_entered(area):
	if init:
		velocity2 = Vector2(-689.617432, 0)
		move()
		crash()
		#print(area)


func _on_LeftBounds_area_entered(area):
	if init:
		##print(area)
		velocity2 = Vector2(689.617432, 0)
		move()
		crash()
		#print(area)


func _on_TopBounds_area_entered(area):
	if init:
		velocity2 = Vector2(0, 689)
		move()
		crash()
		#print(area)


func _on_BottomBounds_area_entered(area):
	if init:
		velocity2 = Vector2(0, -689)
		move()
		crash()
		#print(area)

