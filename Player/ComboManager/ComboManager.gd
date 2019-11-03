extends Node

enum Combo {
	BOOSTHIT,
}

var _combo_log = []

func add_combo(i: int) -> void:
	_combo_log.append(i)
	var size = len(_combo_log)
	get_owner().combo_label.text = "Combo *%d" % size
	$AnimationPlayer.play("combo_grow")
	get_owner().collectables += size

func reset_combo() -> void:
	_combo_log.clear()
	get_owner().combo_label.text = "Combo *%d" % len(_combo_log)
