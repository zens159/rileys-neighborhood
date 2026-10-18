extends Camera2D

@export var randomStrength: float = 20.0
@export var shakeFade: float = 15.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func apply_shake(strength: float = randomStrength):
	shake_strength = strength

var follow_speed: float = 4.0
var zoom_speed: float = 12.0

func process_shake(delta: float):
	# Camera shake
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)

func _physics_process(delta: float) -> void:
	if GameManager.buddy:
		global_position = lerp(global_position, GameManager.buddy.global_position, follow_speed * delta)
		global_position.x = max(390, global_position.x)
		zoom = lerp(zoom, GameManager.buddy.zoom, zoom_speed * delta)
		
	process_shake(delta)
	
	offset = randomOffset()

func randomOffset():
	return Vector2(rng.randf_range(-shake_strength,shake_strength)/2, rng.randf_range(-shake_strength,shake_strength))
