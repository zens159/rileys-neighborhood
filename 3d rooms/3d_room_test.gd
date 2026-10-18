extends Node3D

#@onready var music_player = $AudioStreamPlayer
#@export var on_load_bgm:AudioStream

@onready var color_rect = $CanvasLayer/ColorRect #fading from black to gameplay
@onready var music = $AudioStreamPlayer

func _ready() -> void:
	GameManager.player = get_node("Player")
	GameManager.camera = get_node("Camera2D")
	GameManager.buddy = get_node("CameraHelper")
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0, 5).from(1)
	await tween.finished
	$ProtoController.can_move = true
	color_rect.visible = false
