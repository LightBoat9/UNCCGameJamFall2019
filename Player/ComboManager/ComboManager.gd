extends Node

enum Combo {
	BOOSTHIT,
}

var _combo_log = []
var combo_points = 0

func add_combo(i: int) -> void:
	_combo_log.append(i)
	var size = len(_combo_log)
	$AnimationPlayer.play("combo_grow")
	combo_points += size
	get_owner().combo_label.text = "Combo *%d" % size
	get_owner().combo_points_label.text = str(combo_points)

func reset_combo() -> void:
	if _combo_log:
		_combo_log.clear()
		get_owner().collectables += combo_points
		combo_points = 0
		get_owner().combo_label.text = "Combo *%d" % len(_combo_log)
		get_owner().combo_points_label.text = str(combo_points)
