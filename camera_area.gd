extends Area2D

@export var zoom : Vector2 = Vector2(2,2)
@export var camera_follow : bool = false

func _on_body_entered(body: CharacterBody2D) -> void:
	if not body.is_in_group("player"): return
	GameManager.set_zoom(zoom)
	GameManager.buddy.follow_player = camera_follow
	if not camera_follow:
		var areas = get_overlapping_areas()
		for area in areas:
			if area.is_in_group("camera point"):
				GameManager.buddy.global_position = area.global_position

func _on_body_exited(body: CharacterBody2D) -> void:
	if not body.is_in_group("player"): return
	var outer_camera_area = get_overlapping_areas() 
	
	for area in outer_camera_area:
		if area.is_in_group("camera area") and area.overlaps_body(body):
			area._on_body_entered(body)
