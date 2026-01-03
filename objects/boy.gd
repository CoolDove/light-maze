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
			#set_facing_direction(FacingDirection.Left)
		if Input.is_action_pressed("right"):
			direction.x += 1
			#set_facing_direction(FacingDirection.Right)

	if direction != Vector2i.ZERO:
		input_interval = 0.2

	if input_interval > 0:
		input_interval -= delta
		if input_interval <= 0:
			input_interval = 0

	if direction != Vector2i.ZERO:
		var target = tile_position + direction
		tile_position = target
		tile_offset = -(direction as Vector2) * GWorld.instance.tile_size.x
