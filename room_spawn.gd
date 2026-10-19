extends Node2D

#@onready var music_player = $AudioStreamPlayer
#@export var on_load_bgm:AudioStream

@onready var color_rect = $CanvasLayer/ColorRect
@onready var color_rect2 = $CanvasLayer/ColorRect2 #fading from black to gameplay
@onready var music = $AudioStreamPlayer

func _ready() -> void:
	GameManager.player = get_node("Player")
	GameManager.camera = get_node("Camera2D")
	GameManager.buddy = get_node("CameraHelper")
	
	if name == "2dRoomMaster":
		DialogueManager.show_dialogue_balloon(preload("res://dialogue/room_start.dialogue"), "room_start")
	
	color_rect2.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect2, "modulate:a", 0, 1).from(1)
	await tween.finished
	color_rect2.visible = false

func _fade_black() -> void: # transition from 'tutorial' to town
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1, 0.5).from(0.0)
	await tween.finished
	get_tree().change_scene_to_file("res://2d rooms/2d_town1.tscn")

func _fade_white() -> void: # final transition from 2d to 3d world
	Engine.time_scale = 0.1
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1, 0.5).from(0.0)
	tween.parallel().tween_property(music, "volume_db", -80.0, 0.5)
	await tween.finished
	music.stop()
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://3d rooms/3d_room_test.tscn")
