extends CharacterBody2D

enum State { IDLE, RUN, JUMP, FALL, WALLSLIDE }

@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer

var current_state = State.IDLE
var facing_right = true
var save_scale : Vector2
var save_facing_right = true # for wall jumps
var control_stasis = false

var gravity = 650.0
const JUMP_VELOCITY = -400.0
const RUN_SPEED = 250.0 #250.0
const GROUND_ACCELERATION = 800.0
const GROUND_FRICTION = 400.0

const AIR_ACCELERATION = 0.5
const AIR_DRAG = 150.0

func _ready() -> void:
	save_scale = scale

func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#print(current_state)
	
	match current_state:
		State.IDLE:
			_handle_idle_state(delta)
		State.RUN:
			_handle_movement_state(delta)
		State.JUMP, State.FALL, State.WALLSLIDE:
			_handle_air_state(delta)
	
	if Input.is_action_just_pressed("jump"):
		_try_jump()
		
	_handle_movement_state(delta)
	
	# Smoothly return to normal shape after a jump (meant to be sprite.scale)
	scale.x = lerp(scale.x, save_scale.x, 10 * delta)
	scale.y = lerp(scale.y, save_scale.y, 10 * delta)
	
	move_and_slide()

func _handle_movement_state(delta: float) -> void:
	var direction = Input.get_axis("left", "right")
	if control_stasis:
		direction = 0
	
	var speed = RUN_SPEED
	
	if !is_zero_approx(direction):
		# Accelerate towards target speed (preserves existing momentum)
		velocity.x = move_toward(velocity.x, direction * speed, GROUND_ACCELERATION * delta)
		
		facing_right = direction > 0
		#sprite.flip_h = !facing_right
		
		#if is_on_floor():
			#sprite.play("run")
	else: # No input
		# Apply friction when no input
		if is_on_floor():
			#sprite.play("run")
			velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION * delta)
			if is_zero_approx(velocity.x):
				_change_state(State.IDLE)
				
	#sprite.speed_scale = remap(abs(velocity.x), 0, 200, 0.5, 1.5)
	
	if not is_on_floor():
		_handle_air_state(delta)
	elif !is_zero_approx(direction):
		_change_state(State.IDLE)
		
	if is_on_floor() and not jump_buffer_timer.is_stopped():
		_jump()

func _change_state(new_state: State) -> void:
	var old_state = current_state
	current_state = new_state
	
	if new_state == State.WALLSLIDE:
		print("sliding")
	
	# Coyote Time
	if old_state != State.JUMP and new_state == State.FALL:
		coyote_timer.start()
	
	# Coyote Time
	if old_state == State.WALLSLIDE and (new_state == State.FALL):
		coyote_timer.start()

func _handle_idle_state(_delta):
	#sprite.play("idle")
	if is_on_floor():
		if Input.get_vector("left", "right", "up", "down").x != 0:
			_change_state(State.RUN)

func _handle_air_state(delta: float) -> void:
	var speed = RUN_SPEED
	gravity = 650
	
	if current_state == State.JUMP:
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y /= 2
		#sprite.play("jump")
	#elif current_state == State.FALL:
		#sprite.play("fall")
	#elif current_state == State.LEDGEDASH:
		#sprite.play("dash")
	
	var direction = Input.get_axis("left", "right")
	
	if control_stasis:
		direction = 0
	
	# Apply input acceleration (Conserves momentum by adding to velocity)
	if !is_zero_approx(direction):
		velocity.x = move_toward(velocity.x, direction * speed, AIR_ACCELERATION * delta)
		facing_right = direction > 0
		#sprite.flip_h = !facing_right
	else:
		# Apply air drag (Always applied to simulate wind resistance)
		velocity.x = move_toward(velocity.x, 0, AIR_DRAG * delta)

	if is_on_floor():
		if is_zero_approx(velocity.x):
			_change_state(State.IDLE)
		else:
			_change_state(State.RUN)
	elif is_on_wall_only() and velocity.y > -100: # wall slide and jump
		if current_state != State.WALLSLIDE:
			save_facing_right = facing_right
			_change_state(State.WALLSLIDE)
		if velocity.y > 0:
			gravity = 400
	elif velocity.y > 0 and current_state == State.JUMP:
		_change_state(State.FALL)
	elif velocity.y < 0:
		_change_state(State.JUMP)

func _try_jump() -> void:
	if is_on_floor() or current_state == State.WALLSLIDE:
		_jump()
	
	# Jump Buffer
	if not is_on_floor() and current_state != State.WALLSLIDE:
		jump_buffer_timer.start()
		
	# Coyote Time leniency
	if not coyote_timer.is_stopped():
		_jump()

func _jump() -> void:
	#_play_sound(sound_jump)
	velocity.y = JUMP_VELOCITY
	if current_state == State.WALLSLIDE:
		velocity.x = 300 if !save_facing_right else -300
		_set_control_stasis(0.3)
	_change_state(State.JUMP)
	jump_buffer_timer.stop()
	# this should be sprite.scale
	scale.x = scale.x / 1.3
	scale.y = scale.x * 1.3
	#sprite.play("jump")

func _set_control_stasis(stasis_time: float) -> void:
	control_stasis = true
	await get_tree().create_timer(stasis_time).timeout
	control_stasis = false
