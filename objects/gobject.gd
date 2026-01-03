@tool
@abstract
extends Sprite2D
class_name GObject

var tile_position : Vector2i
var tile_offset : Vector2

enum FacingDirection { Left, Right }

var world : GWorld

func _ready():
	if world != null:
		world.add_gobject(self)
		assert(get_parent() == world, "The GObject should be the world's child.")
	else:
		print("The gworld doesn't exist.")
		push_error("The gworld doesn't exist.")
	if not Engine.is_editor_hint():
		on_ready()

var _locked : bool
var _lock_wait : int
var _last_position
func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
		if _locked:
			if _last_position != position:
				_locked = false
		else:
			if _last_position != position:
				_lock_wait = 3
			else:
				_lock_wait -= 1
			if _lock_wait <= 0 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				print("lock!")
				_locked = true
				_lock_position()
		_last_position = position
	else:
		on_process(delta)

func _enter_tree() -> void:
	var node = self
	while (node is not GWorld):
		var parent = node.get_parent()
		if parent == null:
			printerr("Should have a GWorld in parent!")
			return
		node = parent
	world = node
	_lock_position()
	tile_position = world.local_pos2tpos(position)

func set_facing_direction(facing: FacingDirection):
	match facing:
		FacingDirection.Left:
			flip_h = true
		FacingDirection.Right:
			flip_h = false

func get_facing_direction() -> FacingDirection:
	return FacingDirection.Left if flip_h else FacingDirection.Right

func _lock_position() -> void:
	position = world.tpos2local_pos(world.local_pos2tpos(position))

@abstract func on_ready()
@abstract func on_process(delta: float)
