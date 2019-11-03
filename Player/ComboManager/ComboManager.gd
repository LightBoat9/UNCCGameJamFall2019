extends Node

enum Combo {
	BOOSTHIT,
}

var _combo_log = []
var combo_points = 0 setget set_combo_points

func add_combo(i: int) -> void:
	_combo_log.append(i)
	var size = len(_combo_log)+1
	$AnimationPlayer.play("combo_grow")
	self.combo_points += 1
	get_owner().combo_label.text = "Combo *%d" % size

func set_combo_points(to: int) -> void:
	combo_points = to
	get_owner().combo_points_label.text = str(combo_points)

func reset_combo() -> void:
	if combo_points > 0:
		get_owner().collectables += (combo_points * (len(_combo_log)+1))
		_combo_log.clear()
		self.combo_points = 0
		get_owner().combo_label.text = "Combo *%d" % (len(_combo_log)+1)
