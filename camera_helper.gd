extends Node2D

@export var zoom = Vector2(1.5, 1.5)
@export var follow_player : bool = true

func _process(_delta: float) -> void:
	if not GameManager.player: return
	if follow_player:
		global_position.x = GameManager.player.global_position.x
		global_position.y = GameManager.player.global_position.y - 10
