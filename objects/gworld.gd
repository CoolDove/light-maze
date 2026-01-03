@tool
extends Node2D
class_name GWorld

static var instance : GWorld

# The main tilemap.
@export var tilemap: TileMapLayer

# Executed when enter the room
var sub_tilemaps : Array[TileMapLayer]

@export_tool_button("Toggle World Debug Hud", "GridToggle")
var _editor_btn_toggle_debug_hud = func():
	ProjectSettings.set_setting(projsetting_hide_debug_hud, not _hide_debug_info)

var _hide_debug_info:
	get:
		return ProjectSettings.get_setting(projsetting_hide_debug_hud)

var tile_size:
	get:
		return tilemap.tile_set.tile_size if tilemap != null else Vector2i(16,16)

var objects : Array[GObject]

var editor_hud : Node2D

const projsetting_hide_debug_hud = "rpgfaker/hide_world_debug_hud"

func _ready():
	GWorld.instance = self
	sub_tilemaps.clear()
	for child in get_children():
		if child is TileMapLayer:
			sub_tilemaps.append(child)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if Engine.is_editor_hint():
		ProjectSettings.set_setting(projsetting_hide_debug_hud, false)
		_register_debug_draw()

func _process(delta):
	if Engine.is_editor_hint():
		return
	for obj in objects:
		obj.tile_offset = lerp(obj.tile_offset, Vector2.ZERO, min(delta * 10, 1))
		if obj.tile_offset.length() < 0.01:
			obj.tile_offset = Vector2.ZERO
		obj.position = tpos2local_pos(obj.tile_position) + obj.tile_offset

func add_gobject(obj: GObject):
	objects.append(obj);

func is_tile_walkable(tpos: Vector2i) -> bool:
	if tilemap == null:
		return false
	if !is_tile_walkable_in_tilemap(tilemap, tpos):
		return false
	for map in sub_tilemaps:
		var is_walkable = is_tile_walkable_in_tilemap(map, tpos)
		if !is_walkable:
			return false
	return true

func is_tile_walkable_in_tilemap(layer: TileMapLayer, tpos: Vector2i) -> bool:
	if layer == null:
		return false
	var tdata = layer.get_cell_tile_data(tpos)
	if tdata == null:
		return true
	var is_wall = tdata.get_custom_data("wall") as bool
	return !is_wall

# By default this returns the center point of the tile.
func tpos2local_pos(tpos:Vector2i, offset:=Vector2(0.5, 0.5)) -> Vector2:
	var tsize = tile_size
	return (tpos * tsize) as Vector2 + (tsize as Vector2) * offset

func tpos2global_pos(tpos:Vector2i) -> Vector2:
	return to_global(tpos2local_pos(tpos))

func local_pos2tpos(local_pos:Vector2) -> Vector2i:
	var tsize = tile_size
	var x = local_pos.x / (tsize.x as float)
	x = floori(x)
	var y = local_pos.y / (tsize.y as float)
	y = floori(y)
	return Vector2i(x,y)

func _register_debug_draw():
	var script = GDScript.new()
	script.source_code = """
@tool
extends Node2D
signal on_draw(node:Node2D)
func _draw():
	if Engine.is_editor_hint():
		on_draw.emit(self)
func _process(delta: float):
	queue_redraw()
"""
	script.reload(false)
	editor_hud = Node2D.new()
	editor_hud.set_script(script)
	add_child(editor_hud, false, Node.INTERNAL_MODE_BACK)
	editor_hud.connect("on_draw", _draw_hud)

func _draw_hud(node: Node2D):
	if _hide_debug_info or tilemap == null:
		return
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	node.draw_rect(Rect2(0,0, width, height), Color(0.2,0.8, 0.7, 0.6), false, 1)
	var mpos = get_viewport().get_mouse_position()
	var font = ThemeDB.get_default_theme().default_font
	var mpos_local = global_transform.inverse() * mpos
	var tpos = local_pos2tpos(mpos_local)
	node.draw_string(font, Vector2.ZERO, "%s" % tpos)
	var alpha = abs(sin(Time.get_unix_time_from_system()))
	node.draw_rect(Rect2(tpos.x*tile_size.x, tpos.y*tile_size.y, tile_size.x, tile_size.y),\
			Color(1,1,1,0.2*alpha), false, 1)

func _get_configuration_warnings() -> PackedStringArray:
	if tilemap == null:
		return ["Didn't set the `tilemap`! Create a TileMapLayer and set it."]
	return []
