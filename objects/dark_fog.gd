@tool
extends Node

var fog : Sprite2D

func _ready():
	call_deferred("_initialize")

func _initialize():
	var world = GWorld.instance
	if world != null:
		print("added")
		fog = Sprite2D.new()
		fog.material = ResourceLoader.load("res://resources/materials/dark_fog.material")
		#fog.draw.connect(fog_draw)
		world.add_child(fog, false, Node.INTERNAL_MODE_BACK)
		world.on_light_tiles_updated.connect(on_light_tiles_updated)

func _process(delta):
	if fog != null:
		fog.queue_redraw()

func on_light_tiles_updated():
	var world = GWorld.instance
	var img = Image.create(240, 160, false, Image.FORMAT_RGBA8)
	img.fill(Color(1,1,1, 1.0))
	for l in world.light_tiles:
		var x = l.x * 16
		var y = l.y * 16
		for p in 16*16:
			img.set_pixel(x + p % 16, y + p / 16, Color(1,1,1,0))
	print("update")
	fog.texture = ImageTexture.create_from_image(img)
	fog.offset = Vector2(120, 80)
	fog.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

func fog_draw():
	fog.draw_rect(Rect2(0,0, 240, 160), Color(0,0,0, 0.2))
