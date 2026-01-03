@tool
extends GObject
class_name Boy

func on_ready():
	pass

var input_interval = 0
func on_process(delta: float):
	if Engine.is_editor_hint():
		return
	var direction = Vector2i.ZERO
	if input_interval <= 0:
		if Input.is_action_pressed("up"):
			direction.y -= 1
		if Input.is_action_pressed("down"):
			direction.y += 1
		if Input.is_action_pressed("left"):
			direction.x -= 1
		if Input.is_action_pressed("right"):
			direction.x += 1

	var move = direction != Vector2i.ZERO
	if move:
		input_interval = 0.2

	if input_interval > 0:
		input_interval -= delta
		if input_interval <= 0:
			input_interval = 0
	if !move:
		return

	var world = GWorld.instance
	if direction != Vector2i.ZERO:
		var target = tile_position + direction
		if world.is_tile_walkable(target):
			tile_position = target
			tile_offset = -(direction as Vector2) * world.tile_size.x
		else:
			tile_offset = (direction as Vector2) * world.tile_size.x * 0.5
