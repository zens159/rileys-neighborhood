extends Node

@export var dialogue_title: String

const DIALOGUE_LIST = {
	"room_start": preload("res://dialogue/room_start.dialogue"),
	"elliot_talk": preload("res://dialogue/elliot_talk.dialogue"),
	"cat_get": preload("res://dialogue/cat_get.dialogue"),
	"mark_talk": preload("res://dialogue/mark_talk.dialogue"),
	"nick_talk": preload("res://dialogue/nick_talk.dialogue"),
	"dog_talk": preload("res://dialogue/dog_talk.dialogue"),
	"august_talk": preload("res://dialogue/august_talk.dialogue"),
	"final": preload("res://dialogue/final.dialogue")
}

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if dialogue_title:
			if is_in_group("npc"):
				$PanelContainer.visible = true
				body.interactable_npc = self
			else:
				DialogueManager.show_dialogue_balloon(DIALOGUE_LIST[dialogue_title], dialogue_title)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		$PanelContainer.visible = false
