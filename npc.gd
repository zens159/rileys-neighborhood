extends Area2D

@onready var shape = $CollisionShape2D
@onready var player_detection = $PlayerDetection

@onready var key = $PanelContainer

@onready var sprite: Sprite2D = $Sprite2D

@onready var highlight: AnimatedSprite2D = $Highlight

@export var dialogue_title: String

var img = null
var flash_tween:Tween

var timetodie = false

func _ready() -> void:
	sprite.play(dialogue_title)
	highlight.play(dialogue_title)

func _physics_process(_delta: float) -> void:
	var distance: float = global_position.distance_to(GameManager.player.global_position)
	GameManager.npc_distances[dialogue_title] = distance
	
	if timetodie:
		highlight.visible = false
		if flash_tween: flash_tween.kill()
		GameManager.npc_distances.erase(dialogue_title)
		#if img: img.queue_free()
		await get_tree().create_timer(1).timeout
		GameManager.player.finished_dialogue = false
		queue_free()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.interacted_npc = self
		key.visible = true
		highlight.visible = true
		
		highlight.scale = Vector2(1.4, 1.4)
		
		#var sprite_frames = sprite.sprite_frames
		#var current_animation = sprite.animation
		#var current_frame_index = sprite.frame
		#var active_texture = sprite_frames.get_frame_texture(current_animation, current_frame_index)
		#
		#img = Sprite2D.new()
		#img.texture = active_texture
		#img.global_position = global_position - Vector2(0, 10)
		#img.flip_h = sprite.flip_h
		#img.scale = sprite.scale
		#img.modulate = Color(0.5, 0.8, 1.0, 0.8) # Optional tint
		#
		#get_tree().current_scene.add_child(img)
		#
		#img.z_index = z_index - 1
		
		await get_tree().create_timer(0.2).timeout 
		if not is_instance_valid(img):
			return
		flash_tween = create_tween()
		flash_tween.set_loops(-1)
		flash_tween.pause()
		# Fade out
		flash_tween.tween_property(highlight, "modulate:a", 0.0, 1).from(1.0)
		#flash_tween.parallel().tween_property(color_rect, "scale", Vector2(0,0), 1).from(Vector2(1,1))
		# Fade in
		flash_tween.tween_property(highlight, "modulate:a", 1.0, 1)
		#flash_tween.parallel().tween_property(color_rect, "scale", Vector2(1,1), 1)
		flash_tween.play()


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "player":
		body.interacted_npc = null
		if flash_tween: flash_tween.kill()
		#if img: img.queue_free()
		key.visible = false
		highlight.visible = false
