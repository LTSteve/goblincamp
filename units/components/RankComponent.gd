extends Node3D

class_name RankComponent

@export var rank_stars: Array[Node3D]

var _rank: int = 0
var _score_to_next_rank:float = 1

func _on_get_kill(value: float):
	_score_to_next_rank -= value
	if _score_to_next_rank <= 0:
		rank_up()

func rank_up():
	_rank = clampi(_rank + 1, 0, 4)
	_set_needed_score()
	_render_rank()

func rank_down():
	_rank = clampi(_rank - 1, 0, 4)
	_set_needed_score()
	_render_rank()

func _set_needed_score():
	_score_to_next_rank = maxf(_rank * 2, 1)

func _render_rank():
	for i in rank_stars.size():
		rank_stars[i].visible = i < _rank
