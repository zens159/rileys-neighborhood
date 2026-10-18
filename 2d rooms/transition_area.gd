extends Area2D

#@onready var shape = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		get_parent()._fade_black()
