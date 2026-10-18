extends Node2D

#@onready var music_player = $AudioStreamPlayer
#@export var on_load_bgm:AudioStream

func _ready() -> void:
	GameManager.player = get_node("Player")
	GameManager.camera = get_node("Camera2D")
	GameManager.buddy = get_node("CameraHelper")
