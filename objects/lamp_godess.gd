@tool
extends GObject
class_name LampGodess

var _tpos_last

func on_ready():
	_tpos_last = tile_position

func on_process(delta: float):
	if tile_position != _tpos_last:
		GWorld.instance.queue_update_light_tiles()
		_tpos_last = tile_position
